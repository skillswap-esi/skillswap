import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_model.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get or create chat thread between two users
  Future<String> getOrCreateChatThread({
    required String userId1,
    required String userId2,
    required String skillId,
    String? skillTitle,
    String? skillOwnerName,
  }) async {
    print('[ChatService] === GET OR CREATE CHAT THREAD ===');
    print('[ChatService] Backend userId1: $userId1');
    print('[ChatService] Backend userId2: $userId2');
    print('[ChatService] skillId: $skillId');
    print('[ChatService] skillTitle: $skillTitle');
    print('[ChatService] skillOwnerName: $skillOwnerName');
    
    // Check if user is authenticated
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('[ChatService] ERROR: User not authenticated with Firebase');
      throw Exception('User not authenticated. Please login first.');
    }
    print('[ChatService] Current Firebase user: ${currentUser.uid}');
    
    // Create consistent thread ID (sorted backend user IDs)
    final userIds = [userId1, userId2]..sort();
    final threadId = '${userIds[0]}_${userIds[1]}_$skillId';
    print('[ChatService] Thread ID: $threadId');

    try {
      final threadRef = _firestore.collection('chat_threads').doc(threadId);
      
      // Check if thread exists
      final threadDoc = await threadRef.get();
      print('[ChatService] Thread exists: ${threadDoc.exists}');

      if (!threadDoc.exists) {
        print('[ChatService] Creating new thread...');
        // Create new thread with Firebase UID in participants for security rules
        await threadRef.set({
          'threadId': threadId,
          'participants': [userId1, userId2], // Backend UUIDs for app logic
          'firebaseUids': [currentUser.uid], // Firebase UIDs for security rules (will be updated when other user joins)
          'skillId': skillId,
          'skillTitle': skillTitle,
          'skillOwnerName': skillOwnerName,
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessageAt': FieldValue.serverTimestamp(),
          'lastMessage': null,
        });
        print('[ChatService] Thread created successfully');
      } else {
        // Thread exists, add current user's Firebase UID if not already there
        final data = threadDoc.data() as Map<String, dynamic>?;
        final firebaseUids = List<String>.from(data?['firebaseUids'] ?? []);
        if (!firebaseUids.contains(currentUser.uid)) {
          await threadRef.update({
            'firebaseUids': FieldValue.arrayUnion([currentUser.uid]),
          });
          print('[ChatService] Added Firebase UID to existing thread');
        }
        
        // Update skill info if provided and not already set
        if ((skillTitle != null && data?['skillTitle'] == null) ||
            (skillOwnerName != null && data?['skillOwnerName'] == null)) {
          final updates = <String, dynamic>{};
          if (skillTitle != null && data?['skillTitle'] == null) {
            updates['skillTitle'] = skillTitle;
          }
          if (skillOwnerName != null && data?['skillOwnerName'] == null) {
            updates['skillOwnerName'] = skillOwnerName;
          }
          if (updates.isNotEmpty) {
            await threadRef.update(updates);
            print('[ChatService] Updated thread with skill info');
          }
        }
      }

      return threadId;
    } catch (e) {
      print('[ChatService] ERROR creating/getting thread: $e');
      if (e.toString().contains('permission-denied') || 
          e.toString().contains('PERMISSION_DENIED')) {
        throw Exception(
          'Permission denied. Please check Firestore security rules.\n'
          'Make sure the chat_threads collection allows read/write for authenticated users.'
        );
      }
      rethrow;
    }
  }

  // Send message
  Future<void> sendMessage({
    required String threadId,
    required String senderId,
    required String senderName,
    required String message,
  }) async {
    print('[ChatService] === SEND MESSAGE ===');
    print('[ChatService] threadId: $threadId');
    print('[ChatService] Backend senderId: $senderId');
    print('[ChatService] message: $message');
    
    // Get current Firebase user
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }
    
    try {
      final messageRef = _firestore
          .collection('chat_threads')
          .doc(threadId)
          .collection('messages')
          .doc();

      await messageRef.set({
        'messageId': messageRef.id,
        'senderId': currentUser.uid, // Use Firebase UID for security rules
        'backendUserId': senderId, // Store backend UUID for app logic
        'senderName': senderName,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });
      print('[ChatService] Message sent successfully');

      // Update thread last message
      await _firestore.collection('chat_threads').doc(threadId).update({
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastMessage': message,
      });
      print('[ChatService] Thread updated with last message');
    } catch (e) {
      print('[ChatService] ERROR sending message: $e');
      if (e.toString().contains('permission-denied') || 
          e.toString().contains('PERMISSION_DENIED')) {
        throw Exception(
          'Permission denied. You may not be a participant in this chat thread.'
        );
      }
      rethrow;
    }
  }

  // Get messages stream
  Stream<List<ChatMessage>> getMessagesStream(String threadId) {
    print('[ChatService] Getting messages stream for thread: $threadId');
    
    return _firestore
        .collection('chat_threads')
        .doc(threadId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      print('[ChatService] Received ${snapshot.docs.length} messages');
      return snapshot.docs.map((doc) {
        return ChatMessage.fromFirestore(doc.data());
      }).toList();
    }).handleError((e) {
      print('[ChatService] ERROR in messages stream: $e');
      if (e.toString().contains('permission-denied') || 
          e.toString().contains('PERMISSION_DENIED')) {
        throw Exception(
          'Permission denied. Please check Firestore security rules.'
        );
      }
      throw e;
    });
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String threadId, String userId) async {
    print('[ChatService] Marking messages as read for thread: $threadId');
    
    try {
      final messagesRef = _firestore
          .collection('chat_threads')
          .doc(threadId)
          .collection('messages');

      final unreadMessages = await messagesRef
          .where('senderId', isNotEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();

      print('[ChatService] ${unreadMessages.docs.length} unread messages');

      final batch = _firestore.batch();
      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
      print('[ChatService] Messages marked as read');
    } catch (e) {
      print('[ChatService] ERROR marking messages as read: $e');
    }
  }

  // Get user's chat threads using Firebase UID
  Stream<List<ChatThread>> getUserChatThreads(String backendUserId) {
    print('[ChatService] Getting chat threads for backend user: $backendUserId');
    
    // Get current Firebase user
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('[ChatService] ERROR: No Firebase user');
      throw Exception('User not authenticated');
    }
    
    final firebaseUid = currentUser.uid;
    print('[ChatService] Firebase UID: $firebaseUid');
    
    // Query by firebaseUids (for security rules) but filter by participants (for app logic)
    return _firestore
        .collection('chat_threads')
        .where('firebaseUids', arrayContains: firebaseUid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) {
      print('[ChatService] Found ${snapshot.docs.length} threads');
      
      // Filter threads where the backend user is a participant
      final filteredThreads = snapshot.docs
          .where((doc) {
            final data = doc.data();
            final participants = List<String>.from(data['participants'] ?? []);
            return participants.contains(backendUserId);
          })
          .map((doc) => ChatThread.fromFirestore(doc.data()))
          .toList();
      
      print('[ChatService] Filtered to ${filteredThreads.length} threads for backend user');
      return filteredThreads;
    }).handleError((e) {
      print('[ChatService] ERROR getting threads: $e');
      if (e.toString().contains('permission-denied') || 
          e.toString().contains('PERMISSION_DENIED')) {
        throw Exception(
          'Permission denied. Please check Firestore security rules.'
        );
      }
      throw e;
    });
  }

  // Get unread message count for a thread
  Future<int> getUnreadCount(String threadId, String userId) async {
    try {
      final snapshot = await _firestore
          .collection('chat_threads')
          .doc(threadId)
          .collection('messages')
          .where('senderId', isNotEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('[ChatService] ERROR getting unread count: $e');
      return 0;
    }
  }
}

final chatService = ChatService();
