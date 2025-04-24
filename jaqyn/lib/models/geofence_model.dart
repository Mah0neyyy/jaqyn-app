import 'package:cloud_firestore/cloud_firestore.dart';

class GeofenceModel {
  final String id;
  final String name;
  final String description;
  final GeoPoint center;
  final double radius; // in meters
  final String userId;
  final List<String> notifyUsers;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastTriggered;

  GeofenceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.center,
    required this.radius,
    required this.userId,
    this.notifyUsers = const [],
    this.isActive = true,
    required this.createdAt,
    this.lastTriggered,
  });

  factory GeofenceModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GeofenceModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      center: data['center'] as GeoPoint,
      radius: (data['radius'] ?? 100.0).toDouble(),
      userId: data['userId'] ?? '',
      notifyUsers: List<String>.from(data['notifyUsers'] ?? []),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastTriggered: data['lastTriggered']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'center': center,
      'radius': radius,
      'userId': userId,
      'notifyUsers': notifyUsers,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastTriggered': lastTriggered != null ? Timestamp.fromDate(lastTriggered!) : null,
    };
  }

  GeofenceModel copyWith({
    String? id,
    String? name,
    String? description,
    GeoPoint? center,
    double? radius,
    String? userId,
    List<String>? notifyUsers,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastTriggered,
  }) {
    return GeofenceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      center: center ?? this.center,
      radius: radius ?? this.radius,
      userId: userId ?? this.userId,
      notifyUsers: notifyUsers ?? this.notifyUsers,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastTriggered: lastTriggered ?? this.lastTriggered,
    );
  }
} 