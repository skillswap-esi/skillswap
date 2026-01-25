import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/chat_model.dart';
import '../core/app_colors.dart';
import '../core/api_config.dart';

class MapPickerPage extends StatefulWidget {
  final LatLng? initialPosition;

  const MapPickerPage({
    super.key,
    this.initialPosition,
  });

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  final MapController _mapController = MapController();
  LatLng? _selectedPosition;
  PartnerPlace? _selectedPartnerPlace;
  bool _isLoadingLocation = false;
  bool _isLoadingPlaces = false;
  List<PartnerPlace> _partnerPlaces = [];

  // Default location - Casablanca, Morocco
  static const LatLng _defaultLocation = LatLng(33.5731, -7.5898);

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition;
    _loadPartnerPlaces();
  }

  Future<void> _loadPartnerPlaces() async {
    setState(() => _isLoadingPlaces = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final token = await user.getIdToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/missions/partner-places'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _partnerPlaces = data.map((json) => PartnerPlace.fromJson(json)).toList();
          _isLoadingPlaces = false;
        });
      } else {
        throw Exception('Failed to load partner places');
      }
    } catch (e) {
      print('Error loading partner places: $e');
      setState(() => _isLoadingPlaces = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load partner places: $e')),
        );
      }
    }
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    // Add partner place markers (blue)
    for (var place in _partnerPlaces) {
      markers.add(
        Marker(
          point: LatLng(place.lat, place.lng),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _selectPartnerPlace(place),
            child: Icon(
              Icons.location_on,
              color: _selectedPartnerPlace?.id == place.id
                  ? AppColors.primary
                  : Colors.blue,
              size: 40,
            ),
          ),
        ),
      );
    }

    // Add selected position marker (green)
    if (_selectedPosition != null) {
      markers.add(
        Marker(
          point: _selectedPosition!,
          width: 40,
          height: 40,
          child: const Icon(
            Icons.my_location,
            color: Colors.green,
            size: 40,
          ),
        ),
      );
    }

    return markers;
  }

  void _selectPartnerPlace(PartnerPlace place) {
    setState(() {
      _selectedPartnerPlace = place;
      _selectedPosition = LatLng(place.lat, place.lng);
    });
    _mapController.move(_selectedPosition!, 15);
  }

  void _onMapTap(TapPosition tapPosition, LatLng position) {
    setState(() {
      _selectedPosition = position;
      _selectedPartnerPlace = null;
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

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

      Position position = await Geolocator.getCurrentPosition();
      final currentLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        _selectedPosition = currentLocation;
        _selectedPartnerPlace = null;
      });

      _mapController.move(currentLocation, 15);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _confirmSelection() {
    if (_selectedPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location')),
      );
      return;
    }

    final meetingPoint = MeetingPoint(
      lat: _selectedPosition!.latitude,
      lng: _selectedPosition!.longitude,
      partnerPlaceId: _selectedPartnerPlace?.id,
      placeName: _selectedPartnerPlace?.name,
      placeAddress: _selectedPartnerPlace?.address,
    );

    Navigator.pop(context, meetingPoint);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Meeting Point'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _confirmSelection,
          ),
        ],
      ),
      body: Stack(
        children: [
          // OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedPosition ?? _defaultLocation,
              initialZoom: 13,
              onTap: _onMapTap,
            ),
            children: [
              // OpenStreetMap Tile Layer (free, no API key required)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.skillswap.mobile',
              ),
              // Markers
              MarkerLayer(
                markers: _buildMarkers(),
              ),
            ],
          ),
          // Info Card
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tap on the map to select a meeting point',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (_selectedPartnerPlace != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '📍 ${_selectedPartnerPlace!.name}',
                        style: const TextStyle(color: AppColors.primary),
                      ),
                      Text(
                        _selectedPartnerPlace!.address,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ] else if (_selectedPosition != null) ...[
                      const SizedBox(height: 8),
                      const Text(
                        '📍 Custom Location',
                        style: TextStyle(color: AppColors.primary),
                      ),
                      Text(
                        'Lat: ${_selectedPosition!.latitude.toStringAsFixed(6)}, '
                        'Lng: ${_selectedPosition!.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // My Location Button
          Positioned(
            bottom: 80,
            right: 16,
            child: FloatingActionButton(
              onPressed: _isLoadingLocation ? null : _getCurrentLocation,
              backgroundColor: Colors.white,
              child: _isLoadingLocation
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),
          // Partner Places List
          if (_partnerPlaces.isNotEmpty)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                child: ExpansionTile(
                  title: const Text('Partner Places'),
                  leading: const Icon(Icons.store, color: AppColors.primary),
                  children: _partnerPlaces.map((place) {
                    return ListTile(
                      title: Text(place.name),
                      subtitle: Text(place.address),
                      trailing: _selectedPartnerPlace?.id == place.id
                          ? const Icon(Icons.check_circle, color: AppColors.primary)
                          : null,
                      onTap: () => _selectPartnerPlace(place),
                    );
                  }).toList(),
                ),
              ),
            ),
          // Loading Indicator
          if (_isLoadingPlaces)
            const Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Loading partner places...'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PartnerPlace {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String? type;
  final String? description;

  PartnerPlace({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    this.type,
    this.description,
  });

  factory PartnerPlace.fromJson(Map<String, dynamic> json) {
    return PartnerPlace(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      lat: json['latitude']?.toDouble() ?? 0.0,
      lng: json['longitude']?.toDouble() ?? 0.0,
      type: json['type'],
      description: json['description'],
    );
  }
}
