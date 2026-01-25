import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../auth_service.dart';
import 'package:latlong2/latlong.dart';
import '../models/skill_model.dart';
import '../models/chat_model.dart';
import '../models/mission_model.dart';
import '../services/mission_service.dart';
import '../services/chat_service.dart';
import '../core/app_colors.dart';
import 'map_picker_page.dart';
import 'chat_page.dart';

class CreateMissionPage extends StatefulWidget {
  final SkillModel skill;

  const CreateMissionPage({
    super.key,
    required this.skill,
  });

  @override
  State<CreateMissionPage> createState() => _CreateMissionPageState();
}

class _CreateMissionPageState extends State<CreateMissionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _creditCostController = TextEditingController(text: '10');
  final _durationController = TextEditingController(text: '60');
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  MeetingPoint? _meetingPoint;
  bool _isLoading = false;
  String? _chatThreadId;

  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _titleController.text = 'Request: ${widget.skill.title}';
    _initializeChatThread();
  }

  Future<void> _initializeChatThread() async {
    if (_currentUser == null) return;

    try {
      // Get backend user ID
      final currentBackendUserId = authService.value.userProfile?.userId;
      if (currentBackendUserId == null) {
        print('[CreateMissionPage] Backend user ID not available yet');
        return;
      }
      
      final threadId = await chatService.getOrCreateChatThread(
        userId1: currentBackendUserId,  // Use backend UUID, not Firebase UID
        userId2: widget.skill.ownerId ?? '',
        skillId: widget.skill.skillId ?? '',
        skillTitle: widget.skill.title,
        skillOwnerName: widget.skill.ownerName,
      );
      setState(() => _chatThreadId = threadId);
    } catch (e) {
      print('[CreateMissionPage] Error initializing chat: $e');
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _selectMeetingPoint() async {
    final result = await Navigator.push<MeetingPoint>(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerPage(
          initialPosition: _meetingPoint != null
              ? LatLng(_meetingPoint!.lat, _meetingPoint!.lng)
              : null,
        ),
      ),
    );

    if (result != null) {
      setState(() => _meetingPoint = result);
    }
  }

  void _openChat() {
    if (_chatThreadId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat not available yet')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          threadId: _chatThreadId!,
          otherUserId: widget.skill.ownerId ?? '',
          otherUserName: widget.skill.ownerName ?? 'Provider',
          skillTitle: widget.skill.title,
        ),
      ),
    );
  }

  Future<void> _createMission() async {
    print('[CreateMissionPage] === CREATE MISSION START ===');
    
    if (!_formKey.currentState!.validate()) {
      print('[CreateMissionPage] Form validation failed');
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      print('[CreateMissionPage] Date/time not selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    if (_meetingPoint == null) {
      print('[CreateMissionPage] Meeting point not selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a meeting point')),
      );
      return;
    }

    if (_currentUser == null) {
      print('[CreateMissionPage] User not authenticated');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final scheduledDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      print('[CreateMissionPage] Skill ID: ${widget.skill.skillId}');
      print('[CreateMissionPage] Title: ${_titleController.text}');
      print('[CreateMissionPage] Scheduled: $scheduledDateTime');
      print('[CreateMissionPage] Duration: ${_durationController.text}');
      print('[CreateMissionPage] Credits: ${_creditCostController.text}');
      print('[CreateMissionPage] Meeting point: ${_meetingPoint?.lat}, ${_meetingPoint?.lng}');

      final request = CreateMissionRequest(
        skillId: widget.skill.skillId ?? '',
        title: _titleController.text,
        description: _descriptionController.text,
        scheduledDate: scheduledDateTime,
        duration: int.parse(_durationController.text),
        creditCost: int.parse(_creditCostController.text),
      );

      // Get auth token and user ID
      final token = await _currentUser!.getIdToken();
      if (token == null) throw Exception('No auth token');
      
      // Get backend UUID from auth service
      final userId = authService.value.userProfile?.userId;
      print('[CreateMissionPage] Backend UUID: $userId');
      
      if (userId == null) {
        throw Exception('User profile not loaded. Please try logging in again.');
      }

      await missionService.createMission(
        request: request,
        authToken: token,
        userId: userId,
      );

      print('[CreateMissionPage] Mission created successfully!');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mission created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e, stackTrace) {
      print('[CreateMissionPage] ERROR creating mission: $e');
      print('[CreateMissionPage] Stack trace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Mission'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: _openChat,
            tooltip: 'Chat with provider',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Skill Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.skill.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Provider: ${widget.skill.ownerName ?? "Unknown"}'),
                    Text('Category: ${widget.skill.category}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Mission Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Date and Time
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _selectedDate == null
                          ? 'Select Date'
                          : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(
                      _selectedTime == null
                          ? 'Select Time'
                          : _selectedTime!.format(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Duration and Cost
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _durationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration (min)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _creditCostController,
                    decoration: const InputDecoration(
                      labelText: 'Credits',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.monetization_on),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Meeting Point
            Card(
              color: _meetingPoint != null ? Colors.green[50] : null,
              child: ListTile(
                leading: Icon(
                  Icons.location_on,
                  color: _meetingPoint != null ? Colors.green : null,
                ),
                title: Text(
                  _meetingPoint != null
                      ? _meetingPoint!.placeName ?? 'Custom Location'
                      : 'Select Meeting Point',
                ),
                subtitle: _meetingPoint != null
                    ? Text(
                        _meetingPoint!.placeAddress ??
                            'Lat: ${_meetingPoint!.lat.toStringAsFixed(4)}, '
                            'Lng: ${_meetingPoint!.lng.toStringAsFixed(4)}',
                      )
                    : const Text('Tap to choose location on map'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _selectMeetingPoint,
              ),
            ),
            const SizedBox(height: 24),

            // Chat Button
            OutlinedButton.icon(
              onPressed: _openChat,
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Discuss with Provider'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),

            // Create Button
            ElevatedButton(
              onPressed: _isLoading ? null : _createMission,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Create Mission',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _creditCostController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}
