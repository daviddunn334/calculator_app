import 'dart:async';
import 'package:flutter/material.dart';
import '../services/safety_tips_service.dart';
import '../theme/app_theme.dart';

class SafetyBanner extends StatefulWidget {
  const SafetyBanner({super.key});

  @override
  State<SafetyBanner> createState() => _SafetyBannerState();
}

class _SafetyBannerState extends State<SafetyBanner> {
  bool _isExpanded = true;
  int _currentTipIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startRotation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startRotation() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _currentTipIndex = (_currentTipIndex + 1) % SafetyTipsService.tips.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTip = SafetyTipsService.tips[_currentTipIndex];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isExpanded ? null : 0,
      child: Card(
        elevation: 0,
        color: SafetyTipsService.getPriorityColor(currentTip.priority),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    currentTip.icon,
                    color: SafetyTipsService.getPriorityIconColor(currentTip.priority),
                    size: 24,
                  ),
                  const SizedBox(width: AppTheme.paddingMedium),
                  Expanded(
                    child: Text(
                      currentTip.message,
                      style: AppTheme.titleMedium.copyWith(
                        color: SafetyTipsService.getPriorityIconColor(currentTip.priority),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    color: SafetyTipsService.getPriorityIconColor(currentTip.priority),
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const SizedBox(height: AppTheme.paddingSmall),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    SafetyTipsService.tips.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentTipIndex
                            ? SafetyTipsService.getPriorityIconColor(currentTip.priority)
                            : SafetyTipsService.getPriorityIconColor(currentTip.priority).withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 