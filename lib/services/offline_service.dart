import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service to handle offline functionality and local data storage
class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  // Stream controller for connectivity status
  final _connectivityStreamController = StreamController<bool>.broadcast();
  Stream<bool> get onConnectivityChanged => _connectivityStreamController.stream;
  
  // Current connectivity status
  bool _isOnline = true;
  bool get isOnline => _isOnline;
  
  // Connectivity instance
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  // Initialize the service
  Future<void> initialize() async {
    // Check initial connectivity
    await _checkConnectivity();
    
    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  // Check current connectivity
  Future<void> _checkConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      // Default to offline if we can't check connectivity
      result = ConnectivityResult.none;
    }
    
    _updateConnectionStatus(result);
  }

  // Update connection status based on connectivity result
  void _updateConnectionStatus(ConnectivityResult result) {
    final bool wasOnline = _isOnline;
    _isOnline = result != ConnectivityResult.none;
    
    // Only notify if status changed
    if (wasOnline != _isOnline) {
      _connectivityStreamController.add(_isOnline);
      
      if (kDebugMode) {
        print('Connection status changed: ${_isOnline ? 'Online' : 'Offline'}');
      }
    }
  }

  // Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityStreamController.close();
  }

  // Save calculator data to local storage
  Future<bool> saveCalculatorData(String calculatorId, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'calculator_$calculatorId';
      final jsonData = jsonEncode(data);
      return await prefs.setString(key, jsonData);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving calculator data: $e');
      }
      return false;
    }
  }

  // Load calculator data from local storage
  Future<Map<String, dynamic>?> loadCalculatorData(String calculatorId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'calculator_$calculatorId';
      final jsonData = prefs.getString(key);
      
      if (jsonData == null) {
        return null;
      }
      
      return jsonDecode(jsonData) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading calculator data: $e');
      }
      return null;
    }
  }

  // Clear all calculator data from local storage
  Future<bool> clearAllCalculatorData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('calculator_'));
      
      for (final key in keys) {
        await prefs.remove(key);
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing calculator data: $e');
      }
      return false;
    }
  }

  // Clear specific calculator data from local storage
  Future<bool> clearCalculatorData(String calculatorId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'calculator_$calculatorId';
      return await prefs.remove(key);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing calculator data: $e');
      }
      return false;
    }
  }
}
