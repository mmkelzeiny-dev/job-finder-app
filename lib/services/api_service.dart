import '../models/job.dart';
import 'auth_service.dart'; // Ensure this path is correct

class ApiService {
  static Future<List<Job>> fetchJobs(String job, String location) async {
    try {
      // Use the global dio instance
      final response = await dio.get(
        '/jobs',
        queryParameters: {'job': job, 'location': location},
      );

      if (response.statusCode == 200) {
        final decoded = response.data;

        if (decoded is Map && decoded.containsKey('results')) {
          final List<dynamic> results = decoded['results'];
          print('fetch is working');
          return results.map((json) => Job.fromJson(json)).toList();
        } else {
          throw Exception('Unexpected JSON structure');
        }
      } else {
        throw Exception('Failed to load jobs: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching jobs: $e');
      return [];
    }
  }

  // Save job (SECURED - relies on JWT in Interceptor)
  static Future<void> saveJob(Job job) async {
    print("📤 Sending job to secured server...");

    final jobData = job.toJson();

    try {
      final response = await dio.post("/save-job", data: jobData);

      if (response.statusCode == 200) {
        final data = response.data;
        job.id = data['id'];
        return; // Success
      } else if (response.statusCode == 409) {
        throw Exception('409'); // Already saved
      } else {
        throw Exception('Failed to save job');
      }
    } catch (e) {
      print('Error saving job: $e');
      rethrow;
    }
  }

  static Future<List<Job>> getSavedJobs() async {
    try {
      final response = await dio.get('/saved-jobs');

      if (response.statusCode == 200) {
        final decoded = response.data as List;
        return decoded.map((json) => Job.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch saved jobs');
      }
    } catch (e) {
      print('Error fetching saved jobs: $e');
      return [];
    }
  }

  static Future<void> deleteSavedJob(int jobId) async {
    try {
      final response = await dio.delete('/saved-job/$jobId');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete saved job');
      }
    } catch (e) {
      print('Error deleting job: $e');
      rethrow;
    }
  }
}
