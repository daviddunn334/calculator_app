import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../models/saved_coordinate.dart';
import '../services/coordinates_service.dart';
import '../theme/app_theme.dart';

class CoordinatesLoggerScreen extends StatefulWidget {
  const CoordinatesLoggerScreen({super.key});

  @override
  State<CoordinatesLoggerScreen> createState() => _CoordinatesLoggerScreenState();
}

class _CoordinatesLoggerScreenState extends State<CoordinatesLoggerScreen> {
  final CoordinatesService _coordinatesService = CoordinatesService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  Position? _currentPosition;
  bool _isLoadingPosition = false;
  bool _permissionDenied = false;
  List<SavedCoordinate> _savedCoordinates = [];
  List<SavedCoordinate> _filteredCoordinates = [];
  String? _selectedCoordinateId;

  @override
  void initState() {
    super.initState();
    _loadSavedCoordinates();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadSavedCoordinates() {
    setState(() {
      _savedCoordinates = _coordinatesService.getAllCoordinates();
      _filteredCoordinates = _savedCoordinates;
    });
  }

  void _filterCoordinates(String query) {
    setState(() {
      _filteredCoordinates = _coordinatesService.searchCoordinates(query);
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingPosition = true;
      _permissionDenied = false;
      _currentPosition = null;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _isLoadingPosition = false;
          });
          _showErrorDialog(
            'Location Services Disabled',
            'Please enable location services on your device to use this feature.',
          );
        }
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _isLoadingPosition = false;
              _permissionDenied = true;
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _isLoadingPosition = false;
            _permissionDenied = true;
          });
        }
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoadingPosition = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPosition = false;
        });
        _showErrorDialog('Error', 'Failed to get location: ${e.toString()}');
      }
    }
  }

  Future<void> _saveLocation() async {
    if (_currentPosition == null) {
      _showErrorDialog('No Location', 'Please get current coordinates first.');
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      _showErrorDialog('Name Required', 'Please enter a name for this location.');
      return;
    }

    try {
      await _coordinatesService.addCoordinate(
        name: _nameController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        lat: _currentPosition!.latitude,
        lon: _currentPosition!.longitude,
        accuracyMeters: _currentPosition!.accuracy,
      );

      if (mounted) {
        _nameController.clear();
        _notesController.clear();
        _loadSavedCoordinates();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error', 'Failed to save location: ${e.toString()}');
      }
    }
  }

  Future<void> _deleteCoordinate(SavedCoordinate coordinate) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Location'),
        content: Text('Are you sure you want to delete "${coordinate.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _coordinatesService.deleteCoordinate(coordinate.id);
        if (mounted) {
          setState(() {
            if (_selectedCoordinateId == coordinate.id) {
              _selectedCoordinateId = null;
            }
          });
          _loadSavedCoordinates();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location deleted'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog('Error', 'Failed to delete location: ${e.toString()}');
        }
      }
    }
  }

  void _copyToClipboard(SavedCoordinate coordinate) {
    Clipboard.setData(ClipboardData(text: coordinate.formattedCoordinates));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: ${coordinate.formattedCoordinates}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openInMaps(SavedCoordinate coordinate) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${coordinate.lat},${coordinate.lon}',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          _showErrorDialog('Error', 'Could not open maps application');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error', 'Failed to open maps: ${e.toString()}');
      }
    }
  }

  void _shareCoordinate(SavedCoordinate coordinate) {
    final text = '''
${coordinate.name}
${coordinate.notes != null ? '${coordinate.notes}\n' : ''}
Coordinates: ${coordinate.formattedCoordinates}
Accuracy: ${coordinate.accuracyMeters.toStringAsFixed(1)}m
Saved: ${DateFormat('MMM d, yyyy h:mm a').format(coordinate.createdAt)}
''';

    Share.share(text, subject: coordinate.name);
  }

  Future<void> _openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                    color: AppTheme.textPrimary,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coordinates Logger',
                          style: AppTheme.titleLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Capture and save GPS coordinates',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Capture Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Capture Location',
                        style: AppTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Get Coordinates Button
                      ElevatedButton.icon(
                        onPressed: _isLoadingPosition ? null : _getCurrentLocation,
                        icon: _isLoadingPosition
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.my_location),
                        label: Text(_isLoadingPosition ? 'Getting Location...' : 'Get Current Coordinates'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),

                      // Permission Denied Message
                      if (_permissionDenied) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.warning_amber, color: Colors.orange.shade700),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Location permission is required',
                                      style: TextStyle(
                                        color: Colors.orange.shade900,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: _openAppSettings,
                                icon: const Icon(Icons.settings, size: 18),
                                label: const Text('Open Settings'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Current Position Display
                      if (_currentPosition != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildReadOnlyField('Latitude', _currentPosition!.latitude.toStringAsFixed(6)),
                              const SizedBox(height: 8),
                              _buildReadOnlyField('Longitude', _currentPosition!.longitude.toStringAsFixed(6)),
                              const SizedBox(height: 8),
                              _buildReadOnlyField('Accuracy', '${_currentPosition!.accuracy.toStringAsFixed(1)} meters'),
                              const SizedBox(height: 8),
                              _buildReadOnlyField('Timestamp', DateFormat('MMM d, yyyy h:mm:ss a').format(_currentPosition!.timestamp)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Input Fields
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name/Label *',
                            hintText: 'e.g., Wellhead #12',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Notes (Optional)',
                            hintText: 'Additional information...',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Save Button
                        ElevatedButton.icon(
                          onPressed: _saveLocation,
                          icon: const Icon(Icons.save),
                          label: const Text('Save Location'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Saved Locations Section
              Text(
                'Saved Locations (${_savedCoordinates.length})',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Search Bar
              if (_savedCoordinates.isNotEmpty) ...[
                TextField(
                  controller: _searchController,
                  onChanged: _filterCoordinates,
                  decoration: InputDecoration(
                    hintText: 'Search by name or notes...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterCoordinates('');
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Saved Locations List
              if (_filteredCoordinates.isEmpty && _savedCoordinates.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(Icons.location_off, size: 64, color: AppTheme.textSecondary.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'No saved locations yet',
                          style: AppTheme.titleMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Capture and save your first location to get started',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else if (_filteredCoordinates.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'No locations match your search',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ..._filteredCoordinates.map((coordinate) => _buildCoordinateCard(coordinate)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoordinateCard(SavedCoordinate coordinate) {
    final isExpanded = _selectedCoordinateId == coordinate.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        side: BorderSide(
          color: isExpanded ? AppTheme.primaryBlue : AppTheme.divider,
          width: isExpanded ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _selectedCoordinateId = isExpanded ? null : coordinate.id;
              });
            },
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppTheme.primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          coordinate.name,
                          style: AppTheme.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: AppTheme.textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    coordinate.shortCoordinates,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM d, yyyy h:mm a').format(coordinate.createdAt),
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded Details
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Latitude', coordinate.lat.toStringAsFixed(6)),
                  const SizedBox(height: 8),
                  _buildDetailRow('Longitude', coordinate.lon.toStringAsFixed(6)),
                  const SizedBox(height: 8),
                  _buildDetailRow('Accuracy', '${coordinate.accuracyMeters.toStringAsFixed(1)} meters'),
                  if (coordinate.notes != null) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow('Notes', coordinate.notes!),
                  ],
                  const SizedBox(height: 16),

                  // Action Buttons
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _copyToClipboard(coordinate),
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('Copy'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _openInMaps(coordinate),
                        icon: const Icon(Icons.map, size: 18),
                        label: const Text('Open Map'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _shareCoordinate(coordinate),
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text('Share'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _deleteCoordinate(coordinate),
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
