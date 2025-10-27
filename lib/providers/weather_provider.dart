import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherData? _currentWeather;
  bool _isLoading = false;
  String? _error;
  Timer? _refreshTimer;

  // Getters
  WeatherData? get currentWeather => _currentWeather;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _currentWeather != null;

  WeatherProvider() {
    _initializeWeatherData();
  }

  Future<void> _initializeWeatherData() async {
    await loadCurrentWeather();
    _startPeriodicRefresh();
  }

  // Load current weather
  Future<void> loadCurrentWeather({String location = 'Jakarta'}) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      final weather = await WeatherService.getCurrentWeather(location: location);
      _currentWeather = weather;
      
      log('Loaded weather data: ${weather.toJson()}');
    } catch (e) {
      _error = e.toString();
      log('Error loading weather: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh weather data
  Future<void> refreshWeatherData() async {
    await loadCurrentWeather();
  }

  // Start periodic refresh (every 30 minutes)
  void _startPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      if (!_isLoading) {
        loadCurrentWeather();
      }
    });
  }

  // Stop periodic refresh
  void stopPeriodicRefresh() {
    _refreshTimer?.cancel();
  }

  // Get weather status color
  Color getWeatherStatusColor() {
    if (_currentWeather == null) return Colors.grey;
    
    final condition = _currentWeather!.condition.toLowerCase();
    if (condition.contains('cerah')) return Colors.orange;
    if (condition.contains('berawan')) return Colors.blue;
    if (condition.contains('hujan')) return Colors.indigo;
    if (condition.contains('panas')) return Colors.red;
    return Colors.blue;
  }

  // Get weather recommendation for water collection
  String getWaterCollectionRecommendation() {
    if (_currentWeather == null) return 'Data cuaca tidak tersedia';
    
    final condition = _currentWeather!.condition.toLowerCase();
    final humidity = _currentWeather!.humidity;
    
    if (condition.contains('hujan')) {
      return 'Kondisi ideal untuk pengisian tangki! Estimasi tangki akan penuh dalam 1-2 jam.';
    } else if (humidity > 80) {
      return 'Kelembapan tinggi, kemungkinan hujan dalam beberapa jam ke depan.';
    } else if (condition.contains('cerah') && humidity < 50) {
      return 'Cuaca kering, konsumsi air mungkin akan meningkat. Pantau level tangki.';
    } else {
      return 'Kondisi cuaca normal, tidak ada prediksi hujan dalam waktu dekat.';
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}