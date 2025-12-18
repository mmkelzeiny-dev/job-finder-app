class Job {
  int? id; // add this
  final String title;
  final String company;
  final String location;
  final String description;
  final String summary;
  final String jobType;
  final String seniority;
  final List<String> skills;
  final String? jobLink;
  bool isSaved;
  final String? salary;

  Job({
    this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.description,
    required this.summary,
    required this.jobType,
    required this.seniority,
    required this.skills,
    this.jobLink,
    this.isSaved = false,
    this.salary,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      summary: json['summary'] ?? '',
      jobType: json['job_type'] ?? '',
      seniority: json['seniority'] ?? '',
      skills: json['skills'] is String
          ? (json['skills'] as String)
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList()
          : (json['skills'] as List<dynamic>? ?? [])
                .map((e) => e.toString())
                .toList(),
      jobLink: json['job_link'],
      salary: json['salary'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'description': description,
      'summary': summary,
      'job_type': jobType,
      'seniority': seniority,
      'skills': skills,
      'job_link': jobLink,
      'salary': salary,
    };
  }
}
