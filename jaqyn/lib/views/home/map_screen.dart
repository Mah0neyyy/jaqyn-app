import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/user_model.dart';
import '../../viewmodels/main_viewmodel.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    final viewModel = Provider.of<MainViewModel>(context, listen: false);
    await viewModel.initialize();
    await _updateUserLocation();
    _setupLocationUpdates();
  }

  Future<void> _updateUserLocation() async {
    final viewModel = Provider.of<MainViewModel>(context, listen: false);
    await viewModel.updateLocation();
  }

  void _setupLocationUpdates() {
    // Update location every 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _updateUserLocation();
        _setupLocationUpdates();
      }
    });
  }

  void _updateMarkers(List<UserModel> friends) {
    setState(() {
      _markers = {
        // Current user marker
        if (Provider.of<MainViewModel>(context, listen: false).currentUser != null)
          Marker(
            markerId: const MarkerId('current_user'),
            position: LatLng(
              friends.firstWhere((user) => user.uid ==
                      Provider.of<MainViewModel>(context, listen: false)
                          .currentUser!
                          .uid)
                  .lastLocation!
                  .latitude,
              friends.firstWhere((user) => user.uid ==
                      Provider.of<MainViewModel>(context, listen: false)
                          .currentUser!
                          .uid)
                  .lastLocation!
                  .longitude,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: const InfoWindow(title: 'You'),
          ),
        // Friends markers
        ...friends
            .where((user) =>
                user.uid !=
                    Provider.of<MainViewModel>(context, listen: false)
                        .currentUser!
                        .uid &&
                user.lastLocation != null &&
                user.isTrackingEnabled)
            .map((user) => Marker(
                  markerId: MarkerId(user.uid),
                  position: LatLng(
                    user.lastLocation!.latitude,
                    user.lastLocation!.longitude,
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen),
                  infoWindow: InfoWindow(
                    title: user.displayName,
                    snippet: 'Last seen: ${_formatLastSeen(user.lastSeen)}',
                  ),
                )),
      };
    });
  }

  String _formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return 'Unknown';
    final difference = DateTime.now().difference(lastSeen);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<UserModel>>(
        stream: Provider.of<MainViewModel>(context).getFriends(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _updateMarkers(snapshot.data!);
            _isLoading = false;
          }

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(0, 0), // Will be updated with user location
                  zoom: 15,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                onMapCreated: (controller) {
                  _mapController = controller;
                },
              ),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
              Positioned(
                top: 16,
                right: 16,
                child: FloatingActionButton(
                  onPressed: () {
                    // TODO: Show friends list
                  },
                  child: const Icon(Icons.people),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: FloatingActionButton(
                  onPressed: () {
                    // TODO: Show profile
                  },
                  child: const Icon(Icons.person),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
} 