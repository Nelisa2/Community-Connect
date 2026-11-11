import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'Under Review':
        return Icons.hourglass_top;
      case 'In Progress':
        return Icons.build;
      case 'Resolved':
        return Icons.check_circle;
      default:
        return Icons.notifications_active;
    }
  }

  String getStatusMessage(String status) {
    switch (status) {
      case 'Under Review':
        return 'Your report is currently being reviewed.';
      case 'In Progress':
        return 'The municipality is working on your report.';
      case 'Resolved':
        return 'Your reported issue has been resolved.';
      default:
        return 'Your report has been submitted successfully.';
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Please log in to view notifications.',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),

      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('notifications')
              .where('userId', isEqualTo: user.uid)
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
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Unable to load notifications.\nPlease try again later.',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (!snapshot.hasData ||
                snapshot.data!.docs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.notifications_none,
                        size: 70,
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'No Notifications Yet',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'You will receive notifications when there are updates about your reports.',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            List<QueryDocumentSnapshot> notifications =
                snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: notifications.length,

              itemBuilder: (context, index) {
                Map<String, dynamic> data =
                    notifications[index].data()
                        as Map<String, dynamic>;

                String title =
                    data['title'] ?? 'Notification';

                String message =
                    data['message'] ??
                        'No message available';

                String status =
                    data['status'] ?? 'Submitted';

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 18,
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(18),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.notifications,
                              size: 28,
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        Text(
                          message,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 18),

                        Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.all(14),

                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.orange,
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
                                  Icon(
                                    getStatusIcon(
                                      status,
                                    ),
                                    size: 23,
                                  ),

                                  const SizedBox(
                                    width: 10,
                                  ),

                                  const Text(
                                    'Report Status',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              Text(
                                status,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                getStatusMessage(
                                  status,
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}