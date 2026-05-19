class ComplaintModel {
  final String complaintId;
  final String userId;
  final String type;
  final String description;
  final String status;
  final List<String> evidenceUrls;
  final double latitude;
  final double longitude;
  final String address;
  final DateTime createdAt;

  ComplaintModel({
    required this.complaintId,
    required this.userId,
    required this.type,
    required this.description,
    required this.status,
    required this.evidenceUrls,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'complaintId': complaintId,
      'userId': userId,
      'type': type,
      'description': description,
      'status': status,
      'evidenceUrls': evidenceUrls,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ComplaintModel.fromMap(Map<String, dynamic> map) {
    return ComplaintModel(
      complaintId: map['complaintId'] ?? '',
      userId: map['userId'] ?? '',
      type: map['type'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'Pending',
      evidenceUrls: List<String>.from(map['evidenceUrls'] ?? []),
      latitude: (map['latitude'] ?? 0.0) as double,
      longitude: (map['longitude'] ?? 0.0) as double,
      address: map['address'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}