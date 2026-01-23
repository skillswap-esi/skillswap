import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../auth_service.dart';
import '../core/app_colors.dart';
import '../models/mission_model.dart';
import '../services/mission_service.dart';

class MissionDetailPage extends StatefulWidget {
  final String missionId;

  const MissionDetailPage({super.key, required this.missionId});

  @override
  State<MissionDetailPage> createState() => _MissionDetailPageState();
}

class _MissionDetailPageState extends State<MissionDetailPage> {
  MissionModel? _mission;
  bool _isLoading = true;
  String? _generatedOtp;
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMission();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _loadMission() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final firebaseUser = authService.value.currentUser;
      if (firebaseUser == null) throw Exception('Not authenticated');

      final idToken = await firebaseUser.getIdToken();
      final mission = await missionService.getMissionById(widget.missionId, idToken!);

      if (mounted) {
        setState(() {
          _mission = mission;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _acceptMission() async {
    try {
      final firebaseUser = authService.value.currentUser;
      final idToken = await firebaseUser!.getIdToken();

      await missionService.acceptMission(widget.missionId, idToken!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mission accepted!'), backgroundColor: Colors.green),
        );
        _loadMission();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _startMission() async {
    try {
      final firebaseUser = authService.value.currentUser;
      final idToken = await firebaseUser!.getIdToken();

      await missionService.startMission(widget.missionId, idToken!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mission started!'), backgroundColor: Colors.green),
        );
        _loadMission();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _generateOtp() async {
    try {
      final firebaseUser = authService.value.currentUser;
      final idToken = await firebaseUser!.getIdToken();

      final result = await missionService.generateOtp(widget.missionId, idToken!);

      if (mounted) {
        setState(() {
          _generatedOtp = result['otpCode'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP generated!'), backgroundColor: Colors.green),
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

  Future<void> _validateOtp() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP must be 6 digits'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      final firebaseUser = authService.value.currentUser;
      final idToken = await firebaseUser!.getIdToken();

      await missionService.validateOtp(
        missionId: widget.missionId,
        otpCode: _otpController.text,
        authToken: idToken!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mission completed!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mission Details'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_mission == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mission Details'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Mission not found')),
      );
    }

    final userId = authService.value.userProfile?.userId;
    final isRequester = _mission!.requesterId == userId;
    final isHelper = _mission!.helperId == userId;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mission Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildParticipantsCard(),
            const SizedBox(height: 16),
            if (_mission!.status == MissionStatus.pending && isHelper)
              _buildAcceptButton(),
            if (_mission!.status == MissionStatus.accepted && (isRequester || isHelper))
              _buildStartButton(),
            if (_mission!.status == MissionStatus.inProgress && isHelper)
              _buildOtpGenerateSection(),
            if (_mission!.status == MissionStatus.inProgress && isRequester)
              _buildOtpValidateSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _mission!.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            _buildStatusChip(_mission!.status),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_mission!.description),
            const Divider(height: 24),
            _buildInfoRow(Icons.calendar_today, 'Scheduled', _formatDate(_mission!.scheduledDate)),
            _buildInfoRow(Icons.access_time, 'Duration', '${_mission!.duration} minutes'),
            _buildInfoRow(Icons.monetization_on, 'Credits', '${_mission!.creditCost}'),
            if (_mission!.skillTitle != null)
              _buildInfoRow(Icons.school, 'Skill', _mission!.skillTitle!),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Participants', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (_mission!.requesterName != null)
              _buildParticipantRow('Requester', _mission!.requesterName!),
            if (_mission!.helperName != null)
              _buildParticipantRow('Helper', _mission!.helperName!),
          ],
        ),
      ),
    );
  }

  Widget _buildAcceptButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _acceptMission,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Accept Mission', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _startMission,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Start Mission', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildOtpGenerateSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Generate OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Generate an OTP code and share it with the requester to complete the mission.'),
            const SizedBox(height: 16),
            if (_generatedOtp != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _generatedOtp!,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 8),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _generatedOtp!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('OTP copied to clipboard')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _generateOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Generate OTP'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpValidateSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Validate OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Enter the OTP code provided by the helper to complete the mission.'),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              decoration: const InputDecoration(
                labelText: 'OTP Code',
                hintText: '123456',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _validateOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Complete Mission'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildParticipantRow(String role, String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.person, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text('$role: ', style: TextStyle(color: Colors.grey[600])),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatusChip(MissionStatus status) {
    Color color;
    switch (status) {
      case MissionStatus.pending:
        color = Colors.orange;
        break;
      case MissionStatus.accepted:
        color = Colors.blue;
        break;
      case MissionStatus.inProgress:
        color = Colors.purple;
        break;
      case MissionStatus.completed:
        color = Colors.green;
        break;
      case MissionStatus.cancelled:
        color = Colors.grey;
        break;
      case MissionStatus.rejected:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
