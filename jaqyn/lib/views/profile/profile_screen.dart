import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_model.dart';
import '../../viewmodels/main_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<MainViewModel>(context, listen: false).signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<UserModel?>(
        stream: Provider.of<MainViewModel>(context).getCurrentUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text('User not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: user.photoURL != null
                            ? NetworkImage(user.photoURL!)
                            : null,
                        child: user.photoURL == null
                            ? const Icon(Icons.person, size: 60)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.white),
                            onPressed: () async {
                              final picker = ImagePicker();
                              final image = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (image != null) {
                                // TODO: Upload image and update profile
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Display Name
                TextFormField(
                  initialValue: user.displayName,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (value) {
                    Provider.of<MainViewModel>(context, listen: false)
                        .updateProfile(displayName: value);
                  },
                ),

                const SizedBox(height: 16),

                // Role Selection
                DropdownButtonFormField<UserRole>(
                  value: user.role,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.people),
                  ),
                  items: UserRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      Provider.of<MainViewModel>(context, listen: false)
                          .updateProfile(role: value);
                    }
                  },
                ),

                const SizedBox(height: 16),

                // Location Tracking Toggle
                SwitchListTile(
                  title: const Text('Location Tracking'),
                  subtitle: const Text('Allow others to see your location'),
                  value: user.isTrackingEnabled,
                  onChanged: (value) {
                    Provider.of<MainViewModel>(context, listen: false)
                        .updateProfile(isTrackingEnabled: value);
                  },
                ),

                const SizedBox(height: 24),

                // Geofences Section
                const Text(
                  'Geofences',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                StreamBuilder<List<GeofenceModel>>(
                  stream: Provider.of<MainViewModel>(context).getUserGeofences(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final geofences = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: geofences.length,
                      itemBuilder: (context, index) {
                        final geofence = geofences[index];
                        return ListTile(
                          title: Text(geofence.name),
                          subtitle: Text(geofence.description),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  // TODO: Edit geofence
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  Provider.of<MainViewModel>(context, listen: false)
                                      .deleteGeofence(geofence.id);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Add Geofence Button
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Show add geofence dialog
                  },
                  icon: const Icon(Icons.add_location),
                  label: const Text('Add Geofence'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 