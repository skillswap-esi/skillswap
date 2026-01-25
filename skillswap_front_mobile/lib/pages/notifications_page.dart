import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth_service.dart';
import '../core/app_colors.dart';
import 'mission_detail_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot>? _notificationsStream;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    final user = authService.value.currentUser;
    if (user != null) {
      _notificationsStream = _firestore
          .collection('notifications')
          .doc(user.uid)
          .collection('items')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .snapshots();
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      final user = authService.value.currentUser;
      if (user == null) return;

      await _firestore
          .collection('notifications')
          .doc(user.uid)
          .collection('items')
          .doc(notificationId)
          .update({'read': true});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final user = authService.value.currentUser;
      if (user == null) return;

      final unreadDocs = await _firestore
          .collection('notifications')
          .doc(user.uid)
          .collection('items')
          .where('read', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in unreadDocs.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All marked as read'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      final user = authService.value.currentUser;
      if (user == null) return;

      await _firestore
          .collection('notifications')
          .doc(user.uid)
          .collection('items')
          .doc(notificationId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification deleted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: _markAllAsRead,
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: _notificationsStream == null
          ? const Center(child: Text('Please login to view notifications'))
          : StreamBuilder<QuerySnapshot>(
              stream: _notificationsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    return _buildNotificationCard(doc);
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final notificationId = doc.id;
    final type = data['type'] ?? 'GENERAL';
    final title = data['title'] ?? 'Notification';
    final message = data['message'] ?? '';
    final read = data['read'] ?? false;
    final timestamp = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
    final notifData = data['data'] as Map<String, dynamic>?;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: read ? 0 : 2,
      color: read ? Colors.grey[100] : Colors.white,
      child: InkWell(
        onTap: () {
          if (!read) {
            _markAsRead(notificationId);
          }
          // Navigate to mission detail if missionId exists
          if (notifData?['missionId'] != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MissionDetailPage(
                  missionId: notifData!['missionId'],
                ),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNotificationIcon(type),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: read ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!read)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: () => _deleteNotification(notificationId),
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(String type) {
    IconData icon;
    Color color;

    switch (type.toUpperCase()) {
      case 'MISSION_CREATED':
        icon = Icons.add_task;
        color = Colors.blue;
        break;
      case 'MISSION_ACCEPTED':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'MISSION_REJECTED':
        icon = Icons.cancel;
        color = Colors.red;
        break;
      case 'MISSION_STARTED':
        icon = Icons.play_circle;
        color = Colors.purple;
        break;
      case 'MISSION_COMPLETED':
        icon = Icons.done_all;
        color = Colors.green;
        break;
      case 'MISSION_CANCELLED':
        icon = Icons.block;
        color = Colors.grey;
        break;
      case 'CREDIT_RECEIVED':
        icon = Icons.monetization_on;
        color = Colors.amber;
        break;
      case 'CREDIT_SPENT':
        icon = Icons.money_off;
        color = Colors.orange;
        break;
      default:
        icon = Icons.notifications;
        color = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
