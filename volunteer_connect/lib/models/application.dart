class Application {
  final int applicationId;
  final int opportunityId;
  final String title;
  final String ngoName;
  final String category;
  final String location;
  final String date;
  final String time;
  final String status;
  final String appliedDate;
  
  Application({
    required this.applicationId,
    required this.opportunityId,
    required this.title,
    required this.ngoName,
    required this.category,
    required this.location,
    required this.date,
    required this.time,
    required this.status,
    required this.appliedDate,
  });
  
  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      applicationId: json['application_id'] ?? 0,
      opportunityId: json['opportunity_id'] ?? 0,
      title: json['title'] ?? '',
      ngoName: json['ngo_name'] ?? '',
      category: json['category'] ?? '',
      location: json['location'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      status: json['status'] ?? 'Applied',
      appliedDate: json['applied_date'] ?? '',
    );
  }
}

class Applicant {
  final int applicationId;
  final String volunteerName;
  final String email;
  final String phone;
  final String status;
  final String appliedDate;
  
  Applicant({
    required this.applicationId,
    required this.volunteerName,
    required this.email,
    required this.phone,
    required this.status,
    required this.appliedDate,
  });
  
  factory Applicant.fromJson(Map<String, dynamic> json) {
    return Applicant(
      applicationId: json['application_id'] ?? 0,
      volunteerName: json['volunteer_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      status: json['status'] ?? 'Applied',
      appliedDate: json['applied_date'] ?? '',
    );
  }
}