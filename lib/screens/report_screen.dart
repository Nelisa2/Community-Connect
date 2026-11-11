import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import 'my_reports_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String selectedCategory = 'Pothole';

  List<File> selectedImages = [];
  Position? currentPosition;
  String currentAddress = '';

  final TextEditingController titleController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  final TextEditingController wardController =
      TextEditingController();

  bool isSubmitting = false;

  final String cloudName = 'i01kxo0c';
  final String uploadPreset = 'community_connect_reports';

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();

    final List<XFile> images =
        await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        selectedImages =
            images.map((image) => File(image.path)).toList();
      });
    }
  }

  Future<List<String>> uploadImagesToCloudinary() async {
    List<String> imageUrls = [];

    for (File image in selectedImages) {
      final Uri uploadUrl = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest(
        'POST',
        uploadUrl,
      );

      request.fields['upload_preset'] = uploadPreset;

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          image.path,
        ),
      );

      final response = await request.send();

      final responseBody =
          await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(responseBody);

        final String? imageUrl =
            data['secure_url'];

        if (imageUrl != null) {
          imageUrls.add(imageUrl);
        }
      } else {
        throw Exception(
          'Failed to upload image to Cloudinary.',
        );
      }
    }

    return imageUrls;
  }

  Future<void> captureLocation() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Checking location permission...',
        ),
      ),
    );

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (!mounted) return;

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();

      if (!mounted) return;

      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission denied.',
            ),
          ),
        );
        return;
      }
    }

    if (permission ==
        LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location permission is permanently denied.',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Permission allowed. Getting location...',
        ),
      ),
    );

    Position position;

    try {
      position =
          await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(
        const Duration(seconds: 15),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not get your location. Please try again.',
          ),
        ),
      );

      return;
    }

    if (!mounted) return;

    List<Placemark> placemarks =
        await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (!mounted) return;

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;

      setState(() {
        currentPosition = position;

        currentAddress =
            '${place.street}, '
            '${place.subLocality}, '
            '${place.locality}, '
            '${place.postalCode}, '
            '${place.country}';
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Location captured successfully!',
        ),
      ),
    );
  }

  Future<void> submitReport() async {
    if (titleController.text.trim().isEmpty ||
        wardController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        currentAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please complete all required fields and capture your location.',
          ),
        ),
      );

      return;
    }

    User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please log in before submitting a report.',
          ),
        ),
      );

      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      List<String> imageUrls = [];

      if (selectedImages.isNotEmpty) {
        imageUrls =
            await uploadImagesToCloudinary();
      }

      await FirebaseFirestore.instance
          .collection('reports')
          .add({
        'userId': user.uid,
        'category': selectedCategory,
        'title': titleController.text.trim(),
        'ward': wardController.text.trim(),
        'description':
            descriptionController.text.trim(),
        'address': currentAddress,
        'status': 'Submitted',
        'imageUrls': imageUrls,
        'createdAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Report submitted successfully',
          ),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const MyReportsScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to submit report. Please try again.',
          ),
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      isSubmitting = false;
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    wardController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report an Issue'),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 10),

              const Center(
                child: Icon(
                  Icons.report_problem,
                  size: 70,
                ),
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  'Report a Community Issue',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 8),

              const Center(
                child: Text(
                  'Please provide details about the problem so that the municipality can assist you.',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Issue Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                initialValue: selectedCategory,

                decoration: const InputDecoration(
                  labelText: 'Issue Category',
                  prefixIcon: Icon(
                    Icons.category,
                  ),
                  border: OutlineInputBorder(),
                ),

                items: const [
                  DropdownMenuItem(
                    value: 'Pothole',
                    child: Text('Pothole'),
                  ),

                  DropdownMenuItem(
                    value: 'Broken Streetlight',
                    child: Text(
                      'Broken Streetlight',
                    ),
                  ),

                  DropdownMenuItem(
                    value: 'Illegal Dumping',
                    child: Text(
                      'Illegal Dumping',
                    ),
                  ),

                  DropdownMenuItem(
                    value: 'Water Problem',
                    child: Text(
                      'Water Problem',
                    ),
                  ),

                  DropdownMenuItem(
                    value: 'Other',
                    child: Text('Other'),
                  ),
                ],

                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              TextField(
                controller: titleController,

                decoration: const InputDecoration(
                  labelText: 'Issue Title',
                  hintText:
                      'e.g. Broken streetlight',
                  prefixIcon: Icon(
                    Icons.title,
                  ),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: wardController,

                decoration: const InputDecoration(
                  labelText: 'Ward Number',
                  hintText: 'e.g. Ward 12',
                  prefixIcon: Icon(
                    Icons.location_city,
                  ),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: descriptionController,

                maxLines: 5,

                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText:
                      'Describe the problem in detail...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(
                      bottom: 65,
                    ),
                    child: Icon(
                      Icons.description,
                    ),
                  ),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Location',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: captureLocation,
                  icon: const Icon(
                    Icons.location_on,
                  ),
                  label: const Text(
                    'Capture Location',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              if (currentPosition != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    borderRadius:
                        BorderRadius.circular(8),
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 24,
                          ),

                          const SizedBox(width: 10),

                          const Text(
                            'Location Captured',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Address:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        currentAddress.isEmpty
                            ? 'Address not available'
                            : currentAddress,
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 30),

              const Text(
                'Photos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Add photos to help the municipality understand the issue.',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: pickImage,
                  icon: const Icon(
                    Icons.photo_library,
                  ),
                  label: const Text(
                    'Add Photos',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              if (selectedImages.isNotEmpty)
                SizedBox(
                  height: 200,

                  child: ListView.builder(
                    scrollDirection:
                        Axis.horizontal,

                    itemCount:
                        selectedImages.length,

                    itemBuilder:
                        (context, index) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(
                          right: 10,
                        ),

                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(8),

                          child: Image.file(
                            selectedImages[index],
                            width: 250,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 30),

              const Divider(),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 58,

                child: ElevatedButton.icon(
                  onPressed: isSubmitting
                      ? null
                      : submitReport,

                  icon: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(),
                        )
                      : const Icon(
                          Icons.send,
                        ),

                  label: Text(
                    isSubmitting
                        ? 'Submitting Report...'
                        : 'Submit Report',
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}