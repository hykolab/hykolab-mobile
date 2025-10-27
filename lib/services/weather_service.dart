import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class WeatherService {
  // Untuk demo, menggunakan data mock yang realistis untuk Jakarta
  // Bisa diganti dengan OpenWeatherMap API atau API cuaca lainnya
  
  static Future<WeatherData> getCurrentWeather({String location = 'Jakarta'}) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Return realistic mock data for Jakarta
      return _getMockWeatherData(location);
    } catch (e) {
      log('Weather Service Error: $e');
      throw Exception('Failed to load weather data: $e');
    }
  }

  static Future<List<HourlyForecast>> getHourlyForecast() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return _getMockHourlyForecast();
    } catch (e) {
      log('Weather Service Error: $e');
      throw Exception('Failed to load hourly forecast: $e');
    }
  }

  // Mock data berdasarkan cuaca Jakarta yang realistis
  static WeatherData _getMockWeatherData(String location) {
    // Simulasi cuaca Jakarta dengan variasi berdasarkan waktu
    final now = DateTime.now();
    final hour = now.hour;
    
    double temp = 32.0; // Base temperature
    String condition = 'Cerah Berawan';
    String icon = '🌤️';
    String description = 'Cuaca cerah berawan dengan kemungkinan hujan ringan sore hari';
    
    // Variasi berdasarkan jam
    if (hour >= 6 && hour < 12) {
      // Pagi
      temp = 28.0;
      condition = 'Cerah';
      icon = '☀️';
      description = 'Pagi yang cerah, suhu nyaman untuk aktivitas luar ruangan';
    } else if (hour >= 12 && hour < 15) {
      // Siang
      temp = 34.0;
      condition = 'Panas';
      icon = '☀️';
      description = 'Cuaca panas, disarankan menggunakan pelindung dari sinar matahari';
    } else if (hour >= 15 && hour < 18) {
      // Sore
      temp = 32.0;
      condition = 'Berawan';
      icon = '☁️';
      description = 'Sore hari berawan, kemungkinan hujan dalam 1-2 jam ke depan';
    } else {
      // Malam
      temp = 26.0;
      condition = 'Cerah Malam';
      icon = '🌙';
      description = 'Malam yang sejuk dengan langit cerah';
    }
    
    return WeatherData(
      location: '$location, Indonesia',
      temperature: temp,
      condition: condition,
      icon: icon,
      humidity: 75,
      windSpeed: 12.5,
      hourlyForecast: _getMockHourlyForecast(),
      description: description,
    );
  }

  static List<HourlyForecast> _getMockHourlyForecast() {
    final now = DateTime.now();
    final forecasts = <HourlyForecast>[];
    
    final weatherPatterns = [
      {'temp': 35.0, 'icon': '☀️', 'condition': 'Cerah'},
      {'temp': 29.0, 'icon': '🌧️', 'condition': 'Hujan'},
      {'temp': 28.0, 'icon': '🌧️', 'condition': 'Hujan'},
      {'temp': 31.0, 'icon': '☀️', 'condition': 'Cerah'},
      {'temp': 30.0, 'icon': '🌤️', 'condition': 'Berawan'},
    ];
    
    for (int i = 0; i < 5; i++) {
      final time = now.add(Duration(hours: i + 1));
      final pattern = weatherPatterns[i];
      
      forecasts.add(HourlyForecast(
        time: '${time.hour.toString().padLeft(2, '0')}:00',
        temperature: pattern['temp'] as double,
        icon: pattern['icon'] as String,
        condition: pattern['condition'] as String,
      ));
    }
    
    return forecasts;
  }
}

// Jika ingin menggunakan API real (OpenWeatherMap)
class OpenWeatherMapService {
  static const String apiKey = 'YOUR_API_KEY'; // Ganti dengan API key Anda
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  
  static Future<WeatherData?> getCurrentWeatherFromAPI({
    double lat = -6.2088, // Jakarta coordinates
    double lon = 106.8456,
  }) async {
    try {
      final url = '$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=id';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Convert OpenWeatherMap response to WeatherData
        return WeatherData(
          location: data['name'] ?? 'Jakarta',
          temperature: (data['main']['temp'] ?? 30.0).toDouble(),
          condition: data['weather'][0]['description'] ?? 'Cerah',
          icon: _mapWeatherIcon(data['weather'][0]['icon']),
          humidity: data['main']['humidity'] ?? 70,
          windSpeed: (data['wind']['speed'] ?? 10.0).toDouble(),
          hourlyForecast: [], // Perlu API call terpisah untuk hourly
          description: data['weather'][0]['description'] ?? 'Cuaca normal',
        );
      }
    } catch (e) {
      log('OpenWeatherMap API Error: $e');
    }
    return null;
  }
  
  static String _mapWeatherIcon(String? iconCode) {
    switch (iconCode) {
      case '01d': case '01n': return '☀️';
      case '02d': case '02n': return '🌤️';
      case '03d': case '03n': case '04d': case '04n': return '☁️';
      case '09d': case '09n': case '10d': case '10n': return '🌧️';
      case '11d': case '11n': return '⛈️';
      case '13d': case '13n': return '🌨️';
      case '50d': case '50n': return '🌫️';
      default: return '🌤️';
    }
  }
}