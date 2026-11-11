import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'edit_official_profile_screen.dart';

class OfficialProfileScreen extends StatelessWidget {
  const OfficialProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'No official is logged in',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Official Profile'),
      ),

      body: StreamBuilder<DocumentSnapshot>(
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
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Unable to load profile.',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Official profile information not found.',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
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

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  const Center(
                    child: CircleAvatar(
                      radius: 45,
                      child: Icon(
                        Icons.account_balance,
                        size: 45,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Center(
                    child: Text(
                      'Municipality Official',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Center(
                    child: Text(
                      'Official account information',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Personal Information',
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
                        children: [
                          ListTile(
                            contentPadding:
                                EdgeInsets.zero,

                            leading: const Icon(
                              Icons.person,
                            ),

                            title: const Text(
                              'Full Name',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            subtitle: Padding(
                              padding:
                                  const EdgeInsets.only(
                                top: 4,
                              ),
                              child: Text(
                                fullName,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),

                          const Divider(),

                          ListTile(
                            contentPadding:
                                EdgeInsets.zero,

                            leading: const Icon(
                              Icons.email,
                            ),

                            title: const Text(
                              'Official Email',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            subtitle: Padding(
                              padding:
                                  const EdgeInsets.only(
                                top: 4,
                              ),
                              child: Text(
                                email,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),

                          const Divider(),

                          ListTile(
                            contentPadding:
                                EdgeInsets.zero,

                            leading: const Icon(
                              Icons.phone,
                            ),

                            title: const Text(
                              'Phone Number',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            subtitle: Padding(
                              padding:
                                  const EdgeInsets.only(
                                top: 4,
                              ),
                              child: Text(
                                phone,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const EditOfficialProfileScreen(),
                          ),
                        );
                      },

                      icon: const Icon(
                        Icons.edit,
                      ),

                      label: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}