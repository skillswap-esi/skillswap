import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../core/app_colors.dart';
import '../models/mission_model.dart';
import '../services/mission_service.dart';
import 'mission_detail_page.dart';

class MissionsPage extends StatefulWidget {
  const MissionsPage({super.key});

  @override
  State<MissionsPage> createState() => _MissionsPageState();
}

class _MissionsPageState extends State<MissionsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<MissionModel> _requestedMissions = [];
  List<MissionModel> _helpingMissions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMissions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMissions() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final userId = authService.value.userProfile?.userId;
      final firebaseUser = authService.value.currentUser;

      if (userId == null || firebaseUser == null) {
        throw Exception('User not authenticated');
      }

      final idToken = await firebaseUser.getIdToken();

      // Load missions where user is requester
      final requested = await missionService.getUserMissions(
        userId: userId,
        authToken: idToken!,
        role: 'REQUESTER',
      );

      // Load missions where user is helper
      final helping = await missionService.getUserMissions(
        userId: userId,
        authToken: idToken,
        role: 'HELPER',
      );

      if (mounted) {
        setState(() {
          _requestedMissions = requested;
          _helpingMissions = helping;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading missions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Missions'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Requested'),
            Tab(text: 'Helping'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMissionsList(_requestedMissions, isRequester: true),
                _buildMissionsList(_helpingMissions, isRequester: false),
              ],
            ),
    );
  }

  Widget _buildMissionsList(List<MissionModel> missions, {required bool isRequester}) {
    if (missions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isRequester ? 'No requested missions' : 'No helping missions',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMissions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: missions.length,
        itemBuilder: (context, index) {
          final mission = missions[index];
          return _buildMissionCard(mission, isRequester);
        },
      ),
    );
  }

  Widget _buildMissionCard(MissionModel mission, bool isRequester) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MissionDetailPage(missionId: mission.missionId),
            ),
          );
          if (result == true) {
            _loadMissions();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      mission.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(mission.status),
                ],
              ),
              const SizedBox(height: 8),
              if (mission.skillTitle != null)
                Text(
                  'Skill: ${mission.skillTitle}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(mission.scheduledDate),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${mission.duration} min',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.monetization_on, size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${mission.creditCost} credits',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (isRequester && mission.helperName != null)
                    Text(
                      'Helper: ${mission.helperName}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    )
                  else if (!isRequester && mission.requesterName != null)
                    Text(
                      'Requester: ${mission.requesterName}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                ],
              ),
            ],
          ),
        ),
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
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
