import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../core/app_colors.dart';
import '../models/skill_model.dart';
import '../services/skill_service.dart';
import 'skill_detail_page.dart';

class ExploreSkillsPage extends StatefulWidget {
  const ExploreSkillsPage({super.key});

  @override
  State<ExploreSkillsPage> createState() => _ExploreSkillsPageState();
}

class _ExploreSkillsPageState extends State<ExploreSkillsPage> {
  List<SkillModel> _skills = [];
  bool _isLoading = true;
  bool _isLoadingLocation = false;
  String? _errorMessage;
  Position? _currentPosition;
  
  SkillCategory? _selectedCategory;
  double _radiusKm = 10.0;

  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndLoadSkills();
  }

  Future<void> _getCurrentLocationAndLoadSkills() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingLocation = true;
      _errorMessage = null;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoadingLocation = false;
        });

        await _loadSkills();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoadingLocation = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadSkills() async {
    if (_currentPosition == null || !mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final skills = await skillService.getSkillsNear(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        radiusKm: _radiusKm,
        category: _selectedCategory?.value,
      );

      if (mounted) {
        setState(() {
          _skills = skills;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Filter Skills',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Category Filter
                const Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedCategory == null,
                      onSelected: (selected) {
                        setModalState(() => _selectedCategory = null);
                        setState(() => _selectedCategory = null);
                      },
                    ),
                    ...SkillCategory.values.map((category) {
                      return FilterChip(
                        label: Text('${category.emoji} ${category.label}'),
                        selected: _selectedCategory == category,
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedCategory = selected ? category : null;
                          });
                          setState(() {
                            _selectedCategory = selected ? category : null;
                          });
                        },
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Radius Filter
                const Text(
                  'Search Radius',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _radiusKm,
                        min: 1,
                        max: 50,
                        divisions: 49,
                        label: '${_radiusKm.toInt()} km',
                        onChanged: (value) {
                          setModalState(() => _radiusKm = value);
                          setState(() => _radiusKm = value);
                        },
                      ),
                    ),
                    Text(
                      '${_radiusKm.toInt()} km',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Apply Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _loadSkills();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Explore Skills'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: _isLoadingLocation
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Getting your location...'),
                ],
              ),
            )
          : _errorMessage != null
              ? _buildErrorView()
              : _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildSkillsList(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _getCurrentLocationAndLoadSkills,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsList() {
    if (_skills.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 80,
                color: AppColors.primary.withOpacity(0.3),
              ),
              const SizedBox(height: 24),
              const Text(
                'No skills found',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Try adjusting your filters or search radius',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _showFilterDialog,
                icon: const Icon(Icons.filter_list),
                label: const Text('Adjust Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSkills,
      child: Column(
        children: [
          // Filter Summary
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Icon(Icons.location_on, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Found ${_skills.length} skill${_skills.length != 1 ? 's' : ''} within ${_radiusKm.toInt()} km',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _showFilterDialog,
                  child: const Text('Filter'),
                ),
              ],
            ),
          ),
          
          // Skills List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _skills.length,
              itemBuilder: (context, index) {
                final skill = _skills[index];
                return _buildSkillCard(skill);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillCard(SkillModel skill) {
    final category = SkillCategory.fromString(skill.category.value);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SkillDetailPage(skill: skill),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Category Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      category.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Title and Category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          skill.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category.label,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Distance Badge
                  if (skill.distance != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${skill.distance!.toStringAsFixed(1)} km',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Description
              Text(
                skill.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (skill.ownerName != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 12,
                      child: Icon(Icons.person, size: 14),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      skill.ownerName!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (skill.ownerScore != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.star,
                        size: 14,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        skill.ownerScore!.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
