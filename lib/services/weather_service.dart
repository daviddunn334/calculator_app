import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _apiKey = '881cc35f411da96b30ed7a4a8a641717';

  Future<Map<String, dynamic>> getCurrentWeather(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/weather?lat=$lat&lon=$lon&units=imperial&appid=$_apiKey'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }
} 