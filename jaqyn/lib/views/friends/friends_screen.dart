import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/user_model.dart';
import '../../viewmodels/main_viewmodel.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              // TODO: Show QR scanner
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              _showAddFriendDialog(context);
            },
          ),
        ],
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: Provider.of<MainViewModel>(context).getFriends(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final friends = snapshot.data ?? [];
          if (friends.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No friends yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showAddFriendDialog(context);
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add Friend'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      friend.photoURL != null ? NetworkImage(friend.photoURL!) : null,
                  child: friend.photoURL == null
                      ? Text(friend.displayName[0].toUpperCase())
                      : null,
                ),
                title: Text(friend.displayName),
                subtitle: Text(
                  friend.isOnline
                      ? 'Online'
                      : 'Last seen: ${_formatLastSeen(friend.lastSeen)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.location_on),
                      onPressed: () {
                        // TODO: Show friend's location on map
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        _showRemoveFriendDialog(context, friend);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showShareQRDialog(context);
        },
        child: const Icon(Icons.qr_code),
      ),
    );
  }

  void _showAddFriendDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Friend'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Friend\'s UID',
            hintText: 'Enter your friend\'s UID',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final uid = controller.text.trim();
              if (uid.isNotEmpty) {
                Provider.of<MainViewModel>(context, listen: false)
                    .addFriend(uid);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showRemoveFriendDialog(BuildContext context, UserModel friend) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Friend'),
        content: Text('Are you sure you want to remove ${friend.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<MainViewModel>(context, listen: false)
                  .removeFriend(friend.uid);
              Navigator.pop(context);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showShareQRDialog(BuildContext context) {
    final currentUser = Provider.of<MainViewModel>(context, listen: false).currentUser;
    if (currentUser == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Share Your QR Code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              QrImageView(
                data: currentUser.uid,
                version: QrVersions.auto,
                size: 200.0,
              ),
              const SizedBox(height: 16),
              Text(
                'Scan this QR code to add me as a friend',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return 'Unknown';
    final difference = DateTime.now().difference(lastSeen);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
} 