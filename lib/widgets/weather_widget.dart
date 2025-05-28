import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../theme/app_theme.dart';

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _weatherData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      // Default coordinates (can be replaced with actual location later)
      const lat = 40.7128; // New York coordinates as default
      const lon = -74.0060;
      
      final weatherData = await _weatherService.getCurrentWeather(lat, lon);
      setState(() {
        _weatherData = weatherData;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Unable to load weather';
        _weatherData = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          side: const BorderSide(color: AppTheme.divider),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Row(
            children: [
              const Icon(Icons.cloud_off, color: AppTheme.textSecondary),
              const SizedBox(width: AppTheme.paddingSmall),
              Expanded(
                child: Text(_error!, style: AppTheme.bodyMedium),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _fetchWeather,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      );
    }

    if (_weatherData == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.paddingMedium),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final temp = _weatherData!['main']['temp'].round();
    final condition = _weatherData!['weather'][0]['main'];
    final humidity = _weatherData!['main']['humidity'];
    final windSpeed = _weatherData!['wind']['speed'].round();

    IconData weatherIcon;
    switch (condition.toLowerCase()) {
      case 'clear':
        weatherIcon = Icons.wb_sunny;
        break;
      case 'clouds':
        weatherIcon = Icons.cloud;
        break;
      case 'rain':
        weatherIcon = Icons.grain;
        break;
      case 'thunderstorm':
        weatherIcon = Icons.flash_on;
        break;
      default:
        weatherIcon = Icons.cloud;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: const BorderSide(color: AppTheme.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(weatherIcon, 
                  size: 32, 
                  color: AppTheme.accent1,
                ),
                const SizedBox(width: AppTheme.paddingMedium),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$temp°F',
                      style: AppTheme.titleLarge.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      condition,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.water_drop, 
                          size: 16, 
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$humidity%',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.air, 
                          size: 16, 
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$windSpeed mph',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 