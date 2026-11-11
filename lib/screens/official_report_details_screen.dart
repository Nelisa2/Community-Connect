import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OfficialReportDetailsScreen extends StatefulWidget {
  final String reportId;
  final String category;
  final String title;
  final String ward;
  final String description;
  final String address;
  final String status;

  const OfficialReportDetailsScreen({
    super.key,
    required this.reportId,
    required this.category,
    required this.title,
    required this.ward,
    required this.description,
    required this.address,
    required this.status,
  });

  @override
  State<OfficialReportDetailsScreen> createState() =>
      _OfficialReportDetailsScreenState();
}

class _OfficialReportDetailsScreenState
    extends State<OfficialReportDetailsScreen> {
  late String currentStatus;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.status;
  }

  Future<void> updateStatus() async {
    setState(() {
      isUpdating = true;
    });

    try {
      DocumentSnapshot reportSnapshot =
          await FirebaseFirestore.instance
              .collection('reports')
              .doc(widget.reportId)
              .get();

      if (!reportSnapshot.exists) {
        throw Exception('Report not found');
      }

      Map<String, dynamic> reportData =
          reportSnapshot.data() as Map<String, dynamic>;

      String userId = reportData['userId'];

      // Get the actual report title from Firestore.
      String reportTitle =
          reportData['title'] ?? widget.title;

      // Update the report status.
      await FirebaseFirestore.instance
          .collection('reports')
          .doc(widget.reportId)
          .update({
        'status': currentStatus,
      });

      // Create a notification using the actual report title.
      await FirebaseFirestore.instance
          .collection('notifications')
          .add({
        'userId': userId,
        'reportId': widget.reportId,
        'title': 'Report Status Updated',
        'message':
            'Your report "$reportTitle" has been updated.',
        'status': currentStatus,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Report status updated to $currentStatus',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to update report status.',
          ),
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      isUpdating = false;
    });
  }

  Color getStatusColor(String status) {
    if (status == 'Submitted') {
      return Colors.orange;
    } else if (status == 'Under Review') {
      return Colors.blue;
    } else if (status == 'In Progress') {
      return Colors.purple;
    } else if (status == 'Resolved') {
      return Colors.green;
    } else {
      return Colors.grey;
    }
  }

  IconData getCategoryIcon(String category) {
    if (category == 'Pothole') {
      return Icons.warning;
    } else if (category == 'Broken Streetlight') {
      return Icons.lightbulb;
    } else if (category == 'Water Problem') {
      return Icons.water_drop;
    } else {
      return Icons.report_problem;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reports')
            .doc(widget.reportId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Unable to load report.',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Report not found.',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            );
          }

          Map<String, dynamic> reportData =
              snapshot.data!.data()
                  as Map<String, dynamic>;

          List<String> imageUrls =
              List<String>.from(
            reportData['imageUrls'] ?? [],
          );

          String liveStatus =
              reportData['status'] ?? currentStatus;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      child: Icon(
                        getCategoryIcon(
                          widget.category,
                        ),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.category,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Community Report',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                const Text(
                  'Report Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Title',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 17,
                          ),
                        ),

                        const SizedBox(height: 18),

                        const Text(
                          'Ward Number',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),

                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_city,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.ward,
                                style: const TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),

                        Text(
                          widget.description,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 18),

                        const Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),

                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.place,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.address,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  'Attached Photos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Photos submitted with this report.',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 15),

                if (imageUrls.isEmpty)
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      borderRadius:
                          BorderRadius.circular(8),
                    ),
                    child: const Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 45,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'No photos attached to this report.',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    height: 210,
                    child: ListView.builder(
                      scrollDirection:
                          Axis.horizontal,
                      itemCount: imageUrls.length,
                      itemBuilder:
                          (context, index) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(
                            right: 12,
                          ),
                          child: Container(
                            width: 260,
                            decoration:
                                BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                10,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(
                                10,
                              ),
                              child: Image.network(
                                imageUrls[index],
                                width: 260,
                                height: 210,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress ==
                                      null) {
                                    return child;
                                  }

                                  return const Center(
                                    child:
                                        CircularProgressIndicator(),
                                  );
                                },
                                errorBuilder:
                                    (
                                  context,
                                  error,
                                  stackTrace,
                                ) {
                                  return const Center(
                                    child: Text(
                                      'Unable to load image',
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 30),

                const Text(
                  'Manage Report Status',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: getStatusColor(
                        liveStatus,
                      ),
                    ),
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: getStatusColor(
                              liveStatus,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Current Status',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        initialValue: currentStatus,
                        decoration:
                            const InputDecoration(
                          labelText: 'Select Status',
                          border:
                              OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Submitted',
                            child:
                                Text('Submitted'),
                          ),
                          DropdownMenuItem(
                            value: 'Under Review',
                            child: Text(
                              'Under Review',
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'In Progress',
                            child: Text(
                              'In Progress',
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Resolved',
                            child:
                                Text('Resolved'),
                          ),
                        ],
                        onChanged:
                            (String? newStatus) {
                          if (newStatus != null) {
                            setState(() {
                              currentStatus =
                                  newStatus;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: isUpdating
                        ? null
                        : updateStatus,
                    icon: isUpdating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.update,
                          ),
                    label: Text(
                      isUpdating
                          ? 'Updating...'
                          : 'Update Status',
                      style: const TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                    ),
                    label: const Text(
                      'Back to Reports',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}