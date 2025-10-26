import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import '../models/tank_reading.dart';
import '../services/api_service.dart';

class TankDataProvider extends ChangeNotifier {
  TankReading? _latestReading;
  List<TankReading> _readings = [];
  bool _isLoading = false;
  String? _error;
  Timer? _refreshTimer;

  // Getters
  TankReading? get latestReading => _latestReading;
  List<TankReading> get readings => _readings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Check if we have any data
  bool get hasData => _latestReading != null;

  TankDataProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    await loadLatestReading();
    await loadReadings();
    _startPeriodicRefresh();
  }

  // Load latest reading
  Future<void> loadLatestReading() async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      final reading = await ApiService.getLatestReading();
      _latestReading = reading;
      
      log('Loaded latest reading: ${reading?.toJson()}');
    } catch (e) {
      _error = e.toString();
      log('Error loading latest reading: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load historical readings
  Future<void> loadReadings({int limit = 50}) async {
    try {
      _error = null;
      if (_readings.isEmpty) {
        _isLoading = true;
        notifyListeners();
      }

      final readings = await ApiService.getReadings(limit: limit);
      _readings = readings;
      
      // Update latest reading if we got data
      if (readings.isNotEmpty) {
        _latestReading = readings.first;
      }
      
      log('Loaded ${readings.length} readings');
    } catch (e) {
      _error = e.toString();
      log('Error loading readings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh all data
  Future<void> refreshData() async {
    await Future.wait([
      loadLatestReading(),
      loadReadings(),
    ]);
  }

  // Start periodic refresh (every 30 seconds)
  void _startPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_isLoading) {
        loadLatestReading();
      }
    });
  }

  // Stop periodic refresh
  void stopPeriodicRefresh() {
    _refreshTimer?.cancel();
  }

  // Get readings for chart (last 24 hours by default)
  List<TankReading> getChartData({Duration? duration}) {
    duration ??= const Duration(hours: 24);
    final cutoffTime = DateTime.now().subtract(duration);
    
    return _readings
        .where((reading) => reading.timestamp.isAfter(cutoffTime))
        .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}