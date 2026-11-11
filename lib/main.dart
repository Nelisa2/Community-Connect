import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/account_type_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const CommunityConnectApp());
}

class CommunityConnectApp extends StatelessWidget {
  const CommunityConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Community Connect',

      home: Scaffold(
        body: SafeArea(
          child: Builder(
            builder: (context) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(30),

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,

                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                        ),

                        child: Icon(
                          Icons.location_city,
                          size: 55,
                          color: Colors.blue.shade800,
                        ),
                      ),

                      const SizedBox(height: 30),

                      const Text(
                        'Community Connect',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        'Report. Connect. Improve.',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        'Helping communities report local issues '
                        'and stay connected.',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,
                        height: 50,

                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AccountTypeScreen(),
                              ),
                            );
                          },

                          child: const Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }
}