import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OfficialNotificationsScreen extends StatelessWidget {
  const OfficialNotificationsScreen({super.key});

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

  IconData getStatusIcon(String status) {
    if (status == 'Submitted') {
      return Icons.fiber_new;
    } else if (status == 'Under Review') {
      return Icons.search;
    } else if (status == 'In Progress') {
      return Icons.build;
    } else if (status == 'Resolved') {
      return Icons.check_circle;
    } else {
      return Icons.notifications;
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
        title: const Text('Notifications'),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reports')
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
                padding: EdgeInsets.all(20),
                child: Text(
                  'Unable to load notifications.',
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
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 65,
                    ),

                    SizedBox(height: 15),

                    Text(
                      'No Notifications',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      'New community reports will appear here.',
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

          List<QueryDocumentSnapshot> reports =
              snapshot.data!.docs;

          return ListView(
            padding: const EdgeInsets.all(20),

            children: [
              const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Stay informed about community reports and their current status.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 25),

              ...reports.map((report) {
                Map<String, dynamic> data =
                    report.data()
                        as Map<String, dynamic>;

                String category =
                    data['category'] ?? 'Community Issue';

                String title =
                    data['title'] ?? 'New Report';

                String ward =
                    data['ward'] ?? 'Not available';

                String status =
                    data['status'] ?? 'Submitted';

                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 15,
                  ),

                  child: Card(
                    elevation: 2,

                    child: Padding(
                      padding: const EdgeInsets.all(16),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [
                              CircleAvatar(
                                child: Icon(
                                  getCategoryIcon(
                                    category,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,

                                  children: [
                                    const Text(
                                      'New Community Report',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      category,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color:
                                            Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const Icon(
                                Icons.notifications,
                                size: 22,
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          const Divider(),

                          const SizedBox(height: 12),

                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.description,
                                size: 20,
                              ),

                              const SizedBox(width: 8),

                              Expanded(
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              const Icon(
                                Icons.location_city,
                                size: 20,
                              ),

                              const SizedBox(width: 8),

                              Text(
                                ward,
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          Container(
                            width: double.infinity,

                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),

                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    getStatusColor(status),
                              ),
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),

                            child: Row(
                              children: [
                                Icon(
                                  getStatusIcon(status),
                                  size: 20,
                                  color:
                                      getStatusColor(status),
                                ),

                                const SizedBox(width: 8),

                                const Text(
                                  'Status:',
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(width: 5),

                                Text(
                                  status,
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    color:
                                        getStatusColor(
                                      status,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}