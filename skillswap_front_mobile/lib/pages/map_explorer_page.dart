import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../auth_service.dart';
import '../core/app_colors.dart';
import '../models/skill_model.dart';
import '../services/skill_service.dart';
import 'skill_detail_page.dart';

class MapExplorerPage extends StatefulWidget {
  const MapExplorerPage({super.key});

  @override
  State<MapExplorerPage> createState() => _MapExplorerPageState();
}

class _MapExplorerPageState extends State<MapExplorerPage> {
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(33.5731, -7.5898); // Casablanca default
  List<SkillModel> _skills = [];
  bool _isLoading = true;
  String? _selectedCategory;

  final List<String> _categories = [
    'All',
    'SCOLAIRE',
    'PROFESSIONNEL',
    'LOISIR',
    'SPORT',
    'ART',
    'MUSIQUE',
    'LANGUE',
    'CUISINE',
    'TECHNOLOGIE',
    'AUTRE',
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadSkills();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
        _mapController.move(_currentLocation, 13.0);
      }
    } catch (e) {
      print('[MapExplorer] Error getting location: $e');
    }
  }

  Future<void> _loadSkills() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Get skills near current location (with large radius to get all)
      final skills = await skillService.getSkillsNear(
        latitude: _currentLocation.latitude,
        longitude: _currentLocation.longitude,
        radiusKm: 1000, // Large radius to get all skills
      );

      if (mounted) {
        setState(() {
          _skills = skills.where((s) => s.latitude != null && s.longitude != null).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading skills: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<SkillModel> get _filteredSkills {
    if (_selectedCategory == null || _selectedCategory == 'All') {
      return _skills;
    }
    return _skills.where((s) => s.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 13.0,
              minZoom: 5.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.skillswap.app',
              ),
              MarkerLayer(
                markers: [
                  // Current location marker
                  Marker(
                    point: _currentLocation,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 40,
                    ),
                  ),
                  // Skill markers
                  ..._filteredSkills.map((skill) {
                    return Marker(
                      point: LatLng(skill.latitude!, skill.longitude!),
                      width: 50,
                      height: 50,
                      child: GestureDetector(
                        onTap: () => _showSkillDetails(skill),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(skill.category.value),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _getCategoryIcon(skill.category.value),
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ],
          ),

          // Category filter
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category || 
                                    (_selectedCategory == null && category == 'All');
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category == 'All' ? null : category;
                        });
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Recenter button
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () {
                _mapController.move(_currentLocation, 13.0);
              },
              child: const Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  void _showSkillDetails(SkillModel skill) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(skill.category.value),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getCategoryIcon(skill.category.value),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        skill.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        skill.category.value,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(skill.description, maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(skill.ownerName ?? 'Unknown', style: TextStyle(color: Colors.grey[600])),
                const Spacer(),
                if (skill.ownerScore != null) ...[
                  Icon(Icons.star, size: 16, color: Colors.amber[700]),
                  const SizedBox(width: 4),
                  Text('${skill.ownerScore}/5', style: TextStyle(color: Colors.grey[600])),
                ],
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SkillDetailPage(skill: skill),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'SCOLAIRE':
        return Colors.blue;
      case 'PROFESSIONNEL':
        return Colors.purple;
      case 'LOISIR':
        return Colors.green;
      case 'SPORT':
        return Colors.orange;
      case 'ART':
        return Colors.pink;
      case 'MUSIQUE':
        return Colors.deepPurple;
      case 'LANGUE':
        return Colors.teal;
      case 'CUISINE':
        return Colors.red;
      case 'TECHNOLOGIE':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'SCOLAIRE':
        return Icons.school;
      case 'PROFESSIONNEL':
        return Icons.work;
      case 'LOISIR':
        return Icons.sports_esports;
      case 'SPORT':
        return Icons.sports_soccer;
      case 'ART':
        return Icons.palette;
      case 'MUSIQUE':
        return Icons.music_note;
      case 'LANGUE':
        return Icons.language;
      case 'CUISINE':
        return Icons.restaurant;
      case 'TECHNOLOGIE':
        return Icons.computer;
      default:
        return Icons.category;
    }
  }
}
