// lib/providers/job_provider.dart

import 'package:flutter/material.dart';
import '../models/job.dart';
import '../services/api_service.dart';

class JobProvider extends ChangeNotifier {
  List<Job> jobs = [];
  bool isLoading = false;
  Job? selectedJob;

  String? _userId; // Logged-in Firebase UID

  // Called by AuthProvider whenever user logs in/out
  void updateUser(String? userId) {
    _userId = userId;
    print('JobProvider: user updated -> $_userId');
    notifyListeners();
  }

  // Fetch jobs from API (This remains unchanged)
  Future<void> fetchJobs(String jobQuery, String location) async {
    isLoading = true;
    notifyListeners();

    try {
      jobs = await ApiService.fetchJobs(jobQuery, location);
    } catch (e) {
      print('Error fetching jobs: $e');
      jobs = [];
    }

    isLoading = false;
    notifyListeners();
  }

  // Fetch saved jobs for logged-in user
  Future<void> fetchSavedJobs() async {
    if (_userId == null) return;
    isLoading = true;
    notifyListeners();

    try {
      // SECURE: Now relies on the JWT from the interceptor, not the local _userId
      jobs = await ApiService.getSavedJobs();
    } catch (e) {
      print('Error fetching saved jobs: $e');
      jobs = [];
    }

    isLoading = false;
    notifyListeners();
  }

  void selectJob(Job job) {
    selectedJob = job;
    notifyListeners();
  }

  // Returns a status string to handle feedback
  Future<String> saveJob() async {
    if (selectedJob == null) return "no_job";
    if (_userId == null) return "not_logged_in";

    try {
      // SECURE: Now relies on the JWT from the interceptor, not the local _userId
      await ApiService.saveJob(selectedJob!);
      selectedJob?.isSaved = true;
      notifyListeners();
      return "Job saved";
    } catch (e) {
      if (e.toString().contains('409')) {
        print(selectedJob?.isSaved.toString());
        return "You have already saved this job";
      }
      return "error";
    }
  }

  Future<String> deleteSavedJob(int jobId) async {
    if (_userId == null) {
      throw Exception("User is not authenticated. Cannot delete job");
    }

    try {
      // SECURE: Now relies on the JWT for user identification
      await ApiService.deleteSavedJob(jobId);
      jobs.removeWhere((job) => job.id == jobId);
      selectedJob?.isSaved = false;
      notifyListeners();
      return "Job removed";
    } catch (e) {
      print('Error deleting job: $e');
      return "Failed to remove";
    }
  }
}
