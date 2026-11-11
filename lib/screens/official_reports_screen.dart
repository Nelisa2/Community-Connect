import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'official_report_details_screen.dart';

class OfficialReportsScreen extends StatelessWidget {
  const OfficialReportsScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Reports'),
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
                  'Unable to load community reports.',
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
                      Icons.assignment_outlined,
                      size: 65,
                    ),

                    SizedBox(height: 15),

                    Text(
                      'No Community Reports',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      'No community reports have been submitted yet.',
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
                'Community Reports',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'View and manage reports submitted by community members.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 25),

              ...reports.map((report) {
                Map<String, dynamic> data =
                    report.data() as Map<String, dynamic>;

                String category =
                    data['category'] ?? 'Unknown Category';

                String title =
                    data['title'] ?? 'No title';

                String ward =
                    data['ward'] ?? 'Not available';

                String description =
                    data['description'] ?? 'No description';

                String address =
                    data['address'] ?? 'Address not available';

                String status =
                    data['status'] ?? 'Submitted';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),

                  child: Card(
                    elevation: 2,

                    child: Padding(
                      padding: const EdgeInsets.all(16),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                child: Icon(
                                  getCategoryIcon(category),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),

                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),

                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        getStatusColor(status),
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),

                                child: Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight:
                                        FontWeight.bold,
                                    color:
                                        getStatusColor(status),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 20,
                              ),

                              const SizedBox(width: 6),

                              Expanded(
                                child: Text(
                                  ward,
                                  style: const TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
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

                              const SizedBox(width: 6),

                              Expanded(
                                child: Text(
                                  address,
                                  style: const TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 15),

                          SizedBox(
                            width: double.infinity,
                            height: 45,

                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        OfficialReportDetailsScreen(
                                      reportId: report.id,
                                      category: category,
                                      title: title,
                                      ward: ward,
                                      description:
                                          description,
                                      address: address,
                                      status: status,
                                    ),
                                  ),
                                );
                              },

                              icon: const Icon(
                                Icons.visibility,
                              ),

                              label: const Text(
                                'View Report Details',
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
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