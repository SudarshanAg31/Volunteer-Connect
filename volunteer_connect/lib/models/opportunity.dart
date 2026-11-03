class Opportunity {
  final int id;
  final String title;
  final String description;
  final String ngoName;
  final String category;
  final String location;
  final double? latitude;
  final double? longitude;
  final String date;
  final String time;
  final int volunteersRequired;
  final String createdAt;
  
  Opportunity({
    required this.id,
    required this.title,
    required this.description,
    required this.ngoName,
    required this.category,
    required this.location,
    this.latitude,
    this.longitude,
    required this.date,
    required this.time,
    required this.volunteersRequired,
    required this.createdAt,
  });
  
  factory Opportunity.fromJson(Map<String, dynamic> json) {
    return Opportunity(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      ngoName: json['ngo_name'] ?? '',
      category: json['category'] ?? '',
      location: json['location'] ?? '',
      latitude: json['latitude'] is double ? json['latitude'] : null,
      longitude: json['longitude'] is double ? json['longitude'] : null,
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      volunteersRequired: json['volunteers_required'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'ngo_name': ngoName,
      'category': category,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'date': date,
      'time': time,
      'volunteers_required': volunteersRequired,
      'created_at': createdAt,
    };
  }
}