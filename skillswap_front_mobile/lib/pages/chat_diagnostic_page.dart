import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_colors.dart';

class ChatDiagnosticPage extends StatefulWidget {
  const ChatDiagnosticPage({super.key});

  @override
  State<ChatDiagnosticPage> createState() => _ChatDiagnosticPageState();
}

class _ChatDiagnosticPageState extends State<ChatDiagnosticPage> {
  final List<String> _results = [];
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isRunning = true;
      _results.clear();
    });

    await _checkFirebaseAuth();
    await _checkFirestoreConnection();
    await _checkFirestoreRules();
    await _checkChatThreads();

    setState(() => _isRunning = false);
  }

  void _addResult(String message, {bool isError = false}) {
    setState(() {
      _results.add('${isError ? "❌" : "✅"} $message');
    });
  }

  Future<void> _checkFirebaseAuth() async {
    _addResult('Checking Firebase Authentication...');
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _addResult('User not authenticated', isError: true);
        return;
      }
      
      _addResult('User authenticated: ${user.uid}');
      _addResult('Email: ${user.email}');
      _addResult('Display Name: ${user.displayName ?? "Not set"}');
    } catch (e) {
      _addResult('Firebase Auth Error: $e', isError: true);
    }
  }

  Future<void> _checkFirestoreConnection() async {
    _addResult('Checking Firestore Connection...');
    
    try {
      final firestore = FirebaseFirestore.instance;
      
      // Try to read from Firestore
      await firestore.collection('_test_connection').limit(1).get();
      _addResult('Firestore connection successful');
    } catch (e) {
      _addResult('Firestore connection error: $e', isError: true);
    }
  }

  Future<void> _checkFirestoreRules() async {
    _addResult('Checking Firestore Security Rules...');
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _addResult('Cannot check rules: User not authenticated', isError: true);
        return;
      }

      final firestore = FirebaseFirestore.instance;
      
      // Try to create a test thread
      final testThreadId = 'test_${user.uid}_${DateTime.now().millisecondsSinceEpoch}';
      final threadRef = firestore.collection('chat_threads').doc(testThreadId);
      
      try {
        await threadRef.set({
          'threadId': testThreadId,
          'participants': [user.uid],
          'firebaseUids': [user.uid],
          'skillId': 'test',
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessageAt': FieldValue.serverTimestamp(),
          'lastMessage': null,
        });
        _addResult('Can create chat threads ✓');
        
        // Try to read it back
        final doc = await threadRef.get();
        if (doc.exists) {
          _addResult('Can read chat threads ✓');
        } else {
          _addResult('Cannot read chat thread', isError: true);
        }
        
        // Try to create a message
        final messageRef = threadRef.collection('messages').doc();
        await messageRef.set({
          'messageId': messageRef.id,
          'senderId': user.uid,
          'senderName': user.displayName ?? 'Test User',
          'message': 'Test message',
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });
        _addResult('Can create messages ✓');
        
        // Try to read messages
        final messages = await threadRef.collection('messages').get();
        if (messages.docs.isNotEmpty) {
          _addResult('Can read messages ✓');
        } else {
          _addResult('Cannot read messages', isError: true);
        }
        
        // Clean up test data
        await messageRef.delete();
        await threadRef.delete();
        _addResult('Test data cleaned up');
        
      } catch (e) {
        if (e.toString().contains('permission-denied') || 
            e.toString().contains('PERMISSION_DENIED')) {
          _addResult('PERMISSION DENIED: Firestore rules not configured correctly', isError: true);
          _addResult('Please deploy rules: firebase deploy --only firestore:rules', isError: true);
        } else {
          _addResult('Rules check error: $e', isError: true);
        }
      }
    } catch (e) {
      _addResult('Rules check failed: $e', isError: true);
    }
  }

  Future<void> _checkChatThreads() async {
    _addResult('Checking existing chat threads...');
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _addResult('Cannot check threads: User not authenticated', isError: true);
        return;
      }

      final firestore = FirebaseFirestore.instance;
      final threads = await firestore
          .collection('chat_threads')
          .where('firebaseUids', arrayContains: user.uid)
          .get();
      
      _addResult('Found ${threads.docs.length} chat threads');
      
      for (var doc in threads.docs) {
        final data = doc.data();
        _addResult('  Thread: ${doc.id}');
        _addResult('    Participants: ${data['participants']}');
        _addResult('    Firebase UIDs: ${data['firebaseUids']}');
        
        // Check messages
        final messages = await doc.reference.collection('messages').get();
        _addResult('    Messages: ${messages.docs.length}');
      }
    } catch (e) {
      _addResult('Error checking threads: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Diagnostics'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRunning ? null : _runDiagnostics,
          ),
        ],
      ),
      body: _isRunning
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final result = _results[index];
                final isError = result.startsWith('❌');
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    result,
                    style: TextStyle(
                      color: isError ? Colors.red : Colors.green,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border(top: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Diagnostic Summary',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Total checks: ${_results.length}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Errors: ${_results.where((r) => r.startsWith('❌')).length}',
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
            Text(
              'Success: ${_results.where((r) => r.startsWith('✅')).length}',
              style: const TextStyle(fontSize: 12, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
