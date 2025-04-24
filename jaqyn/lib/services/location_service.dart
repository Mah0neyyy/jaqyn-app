import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/geofence_model.dart';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  // Initialize location service
  Future<void> initialize() async {
    // Request location permissions
    await _requestLocationPermission();
    
    // Initialize notifications
    await _initializeNotifications();
  }

  // Request location permission
  Future<bool> _requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Initialize notifications
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notifications.initialize(initializationSettings);
  }

  // Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // Update user location in Firestore
  Future<void> updateUserLocation(String userId, Position position) async {
    try {
      final geoPoint = GeoPoint(position.latitude, position.longitude);
      
      await _firestore.collection('users').doc(userId).update({
        'lastLocation': geoPoint,
        'lastSeen': FieldValue.serverTimestamp(),
      });

      // Check geofences
      await _checkGeofences(userId, geoPoint);
    } catch (e) {
      print('Error updating location: $e');
    }
  }

  // Check if user entered/exited any geofences
  Future<void> _checkGeofences(String userId, GeoPoint location) async {
    try {
      final geofences = await _firestore
          .collection('geofences')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      for (var doc in geofences.docs) {
        final geofence = GeofenceModel.fromFirestore(doc);
        final distance = _calculateDistance(
          location.latitude,
          location.longitude,
          geofence.center.latitude,
          geofence.center.longitude,
        );

        if (distance <= geofence.radius) {
          // User entered geofence
          await _notifyGeofenceEntry(geofence);
        }
      }
    } catch (e) {
      print('Error checking geofences: $e');
    }
  }

  // Calculate distance between two points
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // Notify users about geofence entry/exit
  Future<void> _notifyGeofenceEntry(GeofenceModel geofence) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'geofence_channel',
      'Geofence Notifications',
      channelDescription: 'Notifications for geofence events',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    for (String userId in geofence.notifyUsers) {
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch,
        'Geofence Alert',
        '${geofence.name} - User entered the area',
        platformChannelSpecifics,
      );
    }
  }

  // Create new geofence
  Future<void> createGeofence(GeofenceModel geofence) async {
    try {
      await _firestore.collection('geofences').add(geofence.toMap());
    } catch (e) {
      print('Error creating geofence: $e');
    }
  }

  // Update geofence
  Future<void> updateGeofence(GeofenceModel geofence) async {
    try {
      await _firestore
          .collection('geofences')
          .doc(geofence.id)
          .update(geofence.toMap());
    } catch (e) {
      print('Error updating geofence: $e');
    }
  }

  // Delete geofence
  Future<void> deleteGeofence(String geofenceId) async {
    try {
      await _firestore.collection('geofences').doc(geofenceId).delete();
    } catch (e) {
      print('Error deleting geofence: $e');
    }
  }

  // Get user's geofences
  Stream<List<GeofenceModel>> getUserGeofences(String userId) {
    return _firestore
        .collection('geofences')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GeofenceModel.fromFirestore(doc))
            .toList());
  }
} 