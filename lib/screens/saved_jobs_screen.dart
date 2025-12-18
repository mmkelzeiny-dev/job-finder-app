import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/GradientBackground.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import 'job_detail_screen.dart';

class SavedJobsScreen extends StatelessWidget {
  const SavedJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Column(
            children: [
              SizedBox(height: 20.0),
              const Text(
                'Saved jobs',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20.0),
            ],
          ),
        ),
        body: jobProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : jobProvider.jobs.isEmpty
            ? const Center(child: Text('No jobs found'))
            : ListView.builder(
                itemCount: jobProvider.jobs.length,
                itemBuilder: (context, index) {
                  final job = jobProvider.jobs[index];
                  // final cardColor = index % 2 == 0
                  //     ? Colors.white
                  //     : Color(0xFFFFE0B2);
                  return Card(
                    color: Color(0xFFFFE0B2),
                    shape: RoundedRectangleBorder(),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(job.title),
                      subtitle: Text('${job.company} • ${job.location}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.bookmark),
                        onPressed: () async {
                          final result = await jobProvider.deleteSavedJob(
                            job.id!,
                          );
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(result)));
                        },
                      ),
                      onTap: () {
                        jobProvider.selectJob(job);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const JobDetailScreen(),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
