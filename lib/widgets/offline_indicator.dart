import 'package:flutter/material.dart';
import '../services/offline_service.dart';

/// A widget that displays an offline indicator when the device is offline
class OfflineIndicator extends StatefulWidget {
  /// Whether to show a compact version of the indicator
  final bool compact;
  
  /// Custom message to display (optional)
  final String? message;
  
  /// Background color of the indicator
  final Color backgroundColor;
  
  /// Text and icon color of the indicator
  final Color textColor;

  const OfflineIndicator({
    super.key,
    this.compact = false,
    this.message,
    this.backgroundColor = Colors.orange,
    this.textColor = Colors.white,
  });

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> {
  final OfflineService _offlineService = OfflineService();
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _isOnline = _offlineService.isOnline;
    _offlineService.onConnectivityChanged.listen((online) {
      if (mounted) {
        setState(() {
          _isOnline = online;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything if online
    if (_isOnline) {
      return const SizedBox.shrink();
    }

    final defaultMessage = widget.compact
        ? 'Offline'
        : 'You are offline. Some features may be limited.';
    
    final message = widget.message ?? defaultMessage;

    if (widget.compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, color: widget.textColor, size: 14),
            const SizedBox(width: 4),
            Text(
              message,
              style: TextStyle(
                color: widget.textColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: widget.backgroundColor,
      child: Row(
        children: [
          Icon(Icons.wifi_off, color: widget.textColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: widget.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A widget that wraps content and shows an offline banner when offline
class OfflineAwareWidget extends StatelessWidget {
  /// The child widget to display
  final Widget child;
  
  /// Whether to show a compact version of the indicator
  final bool compactIndicator;
  
  /// Custom message to display (optional)
  final String? offlineMessage;
  
  /// Background color of the indicator
  final Color indicatorColor;
  
  /// Text and icon color of the indicator
  final Color textColor;

  const OfflineAwareWidget({
    super.key,
    required this.child,
    this.compactIndicator = false,
    this.offlineMessage,
    this.indicatorColor = Colors.orange,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OfflineIndicator(
          compact: compactIndicator,
          message: offlineMessage,
          backgroundColor: indicatorColor,
          textColor: textColor,
        ),
        Expanded(child: child),
      ],
    );
  }
}
