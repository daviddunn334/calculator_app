import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

/// Service for detecting and managing PWA updates
/// Listens for service worker update events and notifies the app
class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  final _updateAvailableController = StreamController<String>.broadcast();
  Stream<String> get updateAvailableStream => _updateAvailableController.stream;

  bool _isInitialized = false;
  String? _newVersion;
  html.ServiceWorkerRegistration? _registration;

  /// Get the current version from service worker
  String? get newVersion => _newVersion;

  /// Initialize the update service (web only)
  Future<void> initialize() async {
    if (_isInitialized || !kIsWeb) {
      return;
    }

    try {
      // Listen for messages from service worker
      html.window.navigator.serviceWorker?.addEventListener('message', _handleServiceWorkerMessage);

      // Get service worker registration
      final reg = await html.window.navigator.serviceWorker?.ready;
      _registration = reg;

      // Check for updates periodically
      _startUpdateCheck();

      _isInitialized = true;
      print('[UpdateService] Initialized successfully');
    } catch (e) {
      print('[UpdateService] Initialization error: $e');
    }
  }

  /// Handle messages from service worker
  void _handleServiceWorkerMessage(html.Event event) {
    if (event is html.MessageEvent) {
      final data = event.data;
      
      if (data is Map && data['type'] == 'UPDATE_AVAILABLE') {
        final version = data['version'] as String?;
        if (version != null) {
          _newVersion = version;
          _updateAvailableController.add(version);
          print('[UpdateService] Update available: $version');
        }
      }
    }
  }

  /// Start periodic update checks
  void _startUpdateCheck() {
    // Check for updates every 30 minutes
    Timer.periodic(const Duration(minutes: 30), (timer) {
      checkForUpdate();
    });

    // Initial check after 5 seconds
    Timer(const Duration(seconds: 5), () {
      checkForUpdate();
    });
  }

  /// Manually check for updates
  Future<void> checkForUpdate() async {
    if (!kIsWeb || _registration == null) {
      return;
    }

    try {
      print('[UpdateService] Checking for updates...');
      await _registration!.update();
    } catch (e) {
      print('[UpdateService] Update check error: $e');
    }
  }

  /// Apply the update by reloading the page (with aggressive auto-reload)
  Future<void> applyUpdate({bool immediate = false}) async {
    if (!kIsWeb) {
      return;
    }

    try {
      print('[UpdateService] Applying update...');
      
      // Tell service worker to skip waiting
      _registration?.active?.postMessage({'type': 'SKIP_WAITING'});
      
      if (immediate) {
        // Immediate reload
        html.window.location.reload();
      } else {
        // Wait 3 seconds then reload (aggressive auto-update)
        await Future.delayed(const Duration(seconds: 3));
        html.window.location.reload();
      }
    } catch (e) {
      print('[UpdateService] Apply update error: $e');
      // Fallback: just reload
      html.window.location.reload();
    }
  }

  /// Get current service worker version
  Future<String?> getCurrentVersion() async {
    if (!kIsWeb || _registration?.active == null) {
      return null;
    }

    try {
      final completer = Completer<String?>();
      final channel = html.MessageChannel();
      
      channel.port1?.onMessage.listen((event) {
        final data = event.data;
        if (data is Map && data['version'] != null) {
          completer.complete(data['version'] as String);
        } else {
          completer.complete(null);
        }
      });

      _registration!.active!.postMessage(
        {'type': 'GET_VERSION'},
        [channel.port2!]
      );

      return await completer.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () => null,
      );
    } catch (e) {
      print('[UpdateService] Get version error: $e');
      return null;
    }
  }

  /// Clear all caches (useful for debugging)
  Future<void> clearCache() async {
    if (!kIsWeb || _registration?.active == null) {
      return;
    }

    try {
      final completer = Completer<bool>();
      final channel = html.MessageChannel();
      
      channel.port1?.onMessage.listen((event) {
        final data = event.data;
        if (data is Map && data['success'] == true) {
          completer.complete(true);
        } else {
          completer.complete(false);
        }
      });

      _registration!.active!.postMessage(
        {'type': 'CLEAR_CACHE'},
        [channel.port2!]
      );

      await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => false,
      );
      
      print('[UpdateService] Cache cleared');
    } catch (e) {
      print('[UpdateService] Clear cache error: $e');
    }
  }

  /// Dispose the service
  void dispose() {
    _updateAvailableController.close();
    _isInitialized = false;
  }
}
