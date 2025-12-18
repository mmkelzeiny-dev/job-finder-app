import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/auth_provider.dart';
import 'package:flutter_application_1/screens/GradientBackground.dart';
import 'package:flutter_application_1/screens/saved_jobs_screen.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import 'results_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController jobController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context, listen: true);
    final authProvider = Provider.of<AuthProvider>(context);
    const storage = FlutterSecureStorage();
    return GradientBackground(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Job Finder',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
        ),
        drawer: Drawer(
          width: 180.0,
          child: ListView(
            children: [
              ListTile(
                title: Text(
                  'My jobs',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  await jobProvider.fetchSavedJobs();
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SavedJobsScreen(),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                trailing: Icon(Icons.logout),
                title: Text(
                  'Logout',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  await authProvider.signOut();
                },
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(30, 25, 30, 40),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: jobController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Job title',
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.orange,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: locationController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Location',
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.orange,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      SizedBox(height: 50),
                      jobProvider.isLoading
                          ? LinearProgressIndicator(
                              backgroundColor: Colors.grey,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue,
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: () async {
                                final job = jobController.text.trim();
                                final location = locationController.text.trim();
                                print("SEARCH BUTTON PRESSED");
                                print("job = $job, location = $location");
                                if (job.isEmpty) return;

                                await jobProvider.fetchJobs(job, location);

                                if (jobProvider.jobs.isNotEmpty &&
                                    context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ResultsScreen(),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('No jobs found'),
                                    ),
                                  );
                                }
                              },
                              label: Text(
                                'Search',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              icon: const Icon(Icons.search),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),

                      ElevatedButton(
                        onPressed: () async {
                          final all = await storage.readAll();
                          print(
                            "ALL YOUR SAVED DATA: $all",
                          ); // ← This will show your JWT

                          final token =
                              await storage.read(key: "jwt_token") ??
                              await storage.read(key: "access_token") ??
                              await storage.read(key: "token") ??
                              await storage.read(key: "idToken");

                          print("YOUR JWT TOKEN IS: $token");
                        },
                        child: Text("DEBUG: Show JWT"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final token =
                              await storage.read(key: "jwt_token") ??
                              "No JWT found";

                          // Show Snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("JWT: $token"),
                              duration: Duration(seconds: 5),
                            ),
                          );
                        },
                        child: Text("DEBUG: Show JWT"),
                      ),
                    ],
                  ),
                ),
                // const SizedBox(height: 200),
                // IntrinsicWidth(
                //   child: jobProvider.isLoading
                //       ? CircularProgressIndicator(
                //           valueColor: AlwaysStoppedAnimation<Color>(
                //             Colors.purple,
                //           ),
                //         )
                //       : Column(
                //           children: [
                //             Container(
                //               decoration: BoxDecoration(
                //                 borderRadius: BorderRadius.circular(12),
                //                 gradient: const LinearGradient(
                //                   colors: <Color>[
                //                     Color(0xFF42A5F5), // Deep blue
                //                     Color(0xFF1976D2), // Medium blue
                //                     Color(0xFF42A5F5), // Light blue
                //                   ],
                //                 ),
                //               ),
                //               child: SizedBox(
                //                 width: double.infinity,
                //                 child: ElevatedButton(
                //                   onPressed: () async {
                //                     final job = jobController.text.trim();
                //                     final location = locationController.text
                //                         .trim();
                //                     print("SEARCH BUTTON PRESSED");
                //                     print("job = $job, location = $location");
                //                     if (job.isEmpty) return;

                //                     await jobProvider.fetchJobs(job, location);

                //                     if (jobProvider.jobs.isNotEmpty &&
                //                         context.mounted) {
                //                       Navigator.push(
                //                         context,
                //                         MaterialPageRoute(
                //                           builder: (_) => const ResultsScreen(),
                //                         ),
                //                       );
                //                     } else {
                //                       ScaffoldMessenger.of(
                //                         context,
                //                       ).showSnackBar(
                //                         const SnackBar(
                //                           content: Text('No jobs found'),
                //                         ),
                //                       );
                //                     }
                //                   },
                //                   style: ElevatedButton.styleFrom(
                //                     foregroundColor: Colors.white,
                //                     backgroundColor: Colors.transparent,
                //                     shadowColor: Colors.transparent,
                //                     shape: RoundedRectangleBorder(
                //                       borderRadius: BorderRadius.circular(12),
                //                     ),
                //                   ),
                //                   child: const Padding(
                //                     padding: EdgeInsets.symmetric(
                //                       vertical: 12,
                //                       horizontal: 16,
                //                     ),
                //                     child: Text(
                //                       'Find jobs',
                //                       style: TextStyle(
                //                         fontWeight: FontWeight.bold,
                //                       ),
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             ),
                //             const SizedBox(height: 20),
                //             // Saved jobs button
                //             Container(
                //               decoration: BoxDecoration(
                //                 borderRadius: BorderRadius.circular(12),
                //                 gradient: const LinearGradient(
                //                   colors: <Color>[
                //                     Color(0xFF42A5F5), // Deep blue
                //                     Color(0xFF1976D2), // Medium blue
                //                     Color(0xFF42A5F5), // Light blue
                //                   ],
                //                 ),
                //               ),
                //               child: ElevatedButton(
                //                 onPressed: () async {
                //                   await jobProvider.fetchSavedJobs();
                //                   if (context.mounted) {
                //                     Navigator.push(
                //                       context,
                //                       MaterialPageRoute(
                //                         builder: (_) => const SavedJobsScreen(),
                //                       ),
                //                     );
                //                   }
                //                 },
                //                 style: ElevatedButton.styleFrom(
                //                   foregroundColor: Colors.white,
                //                   backgroundColor: Colors.transparent,
                //                   shadowColor: Colors.transparent,
                //                   shape: RoundedRectangleBorder(
                //                     borderRadius: BorderRadius.circular(12),
                //                   ),
                //                 ),
                //                 child: const Padding(
                //                   padding: EdgeInsets.symmetric(
                //                     vertical: 12,
                //                     horizontal: 16,
                //                   ),
                //                   child: Text(
                //                     'View Saved Jobs',
                //                     style: TextStyle(
                //                       fontWeight: FontWeight.bold,
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             ),
                //           ],
                //         ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
