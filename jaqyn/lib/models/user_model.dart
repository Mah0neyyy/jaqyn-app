import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  child,
  parent,
  friend,
}

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final UserRole role;
  final GeoPoint? lastLocation;
  final DateTime? lastSeen;
  final bool isOnline;
  final bool isTrackingEnabled;
  final List<String> friends;
  final List<String> geofences;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.role,
    this.lastLocation,
    this.lastSeen,
    this.isOnline = false,
    this.isTrackingEnabled = true,
    this.friends = const [],
    this.geofences = const [],
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${data['role']}',
        orElse: () => UserRole.friend,
      ),
      lastLocation: data['lastLocation'],
      lastSeen: data['lastSeen']?.toDate(),
      isOnline: data['isOnline'] ?? false,
      isTrackingEnabled: data['isTrackingEnabled'] ?? true,
      friends: List<String>.from(data['friends'] ?? []),
      geofences: List<String>.from(data['geofences'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'role': role.toString().split('.').last,
      'lastLocation': lastLocation,
      'lastSeen': lastSeen,
      'isOnline': isOnline,
      'isTrackingEnabled': isTrackingEnabled,
      'friends': friends,
      'geofences': geofences,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    UserRole? role,
    GeoPoint? lastLocation,
    DateTime? lastSeen,
    bool? isOnline,
    bool? isTrackingEnabled,
    List<String>? friends,
    List<String>? geofences,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      role: role ?? this.role,
      lastLocation: lastLocation ?? this.lastLocation,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
      isTrackingEnabled: isTrackingEnabled ?? this.isTrackingEnabled,
      friends: friends ?? this.friends,
      geofences: geofences ?? this.geofences,
    );
  }
} 