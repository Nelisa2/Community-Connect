
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'edit_profile_screen.dart';
import 'account_type_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const AccountTypeScreen(),
      ),
      (route) => false,
    );
  }

  Widget buildInfoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(fontSize: 17),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'No user is logged in',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Unable to load profile.\nPlease try again later.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            if (!snapshot.hasData ||
                !snapshot.data!.exists) {
              return const Center(
                child: Text(
                  'Profile information not found',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            Map<String, dynamic> data =
                snapshot.data!.data()
                    as Map<String, dynamic>;

            String fullName =
                data['fullName'] ?? 'Not available';

            String email =
                data['email'] ??
                    user.email ??
                    'Not available';

            String phone =
                data['phone'] ?? 'Not available';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 15),

                  const CircleAvatar(
                    radius: 45,
                    child: Icon(
                      Icons.person,
                      size: 50,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'My Profile',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'View and manage your account information.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        buildInfoRow(
                          Icons.person,
                          'Full Name',
                          fullName,
                        ),

                        const SizedBox(height: 20),

                        buildInfoRow(
                          Icons.email,
                          'Email',
                          email,
                        ),

                        const SizedBox(height: 20),

                        buildInfoRow(
                          Icons.phone,
                          'Phone Number',
                          phone,
                        ),

                        const SizedBox(height: 20),

                        StreamBuilder<
                            QuerySnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance
                              .collection('reports')
                              .where(
                                'userId',
                                isEqualTo: user.uid,
                              )
                              .snapshots(),
                          builder: (context, reportSnapshot) {
                            if (reportSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Row(
                                children: [
                                  Icon(Icons.location_city),
                                  SizedBox(width: 12),
                                  Text('Loading ward...'),
                                ],
                              );
                            }

                            if (reportSnapshot.hasError) {
                              return buildInfoRow(
                                Icons.location_city,
                                'Ward Number',
                                'Unable to load ward',
                              );
                            }

                            if (!reportSnapshot.hasData ||
                                reportSnapshot.data!.docs.isEmpty) {
                              return buildInfoRow(
                                Icons.location_city,
                                'Ward Number',
                                'No reports submitted yet',
                              );
                            }

                            // Get the member's reports.
                            final reports = [
                              ...reportSnapshot.data!.docs,
                            ];

                            // Sort reports by submission date,
                            // newest report first.
                            reports.sort((a, b) {
                              final aDate =
                                  a.data()['createdAt'];
                              final bDate =
                                  b.data()['createdAt'];

                              final dateA = aDate is Timestamp
                                  ? aDate.toDate()
                                  : DateTime.fromMillisecondsSinceEpoch(0);

                              final dateB = bDate is Timestamp
                                  ? bDate.toDate()
                                  : DateTime.fromMillisecondsSinceEpoch(0);

                              return dateB.compareTo(dateA);
                            });

                            // Read the ward from the latest report.
                            final latestReport =
                                reports.first.data();

                            final savedWard =
                                latestReport['ward']?.toString().trim();

                            final ward = savedWard == null ||
                                    savedWard.isEmpty
                                ? 'Not available'
                                : savedWard;

                            return buildInfoRow(
                              Icons.location_city,
                              'Ward Number',
                              ward,
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const EditProfileScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text(
                        'Edit Profile',
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        logout(context);
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        'Logout',
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
