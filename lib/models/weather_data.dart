class WeatherData {
  final String location;
  final double temperature;
  final String condition;
  final String icon;
  final int humidity;
  final double windSpeed;
  final List<HourlyForecast> hourlyForecast;
  final String description;

  WeatherData({
    required this.location,
    required this.temperature,
    required this.condition,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.hourlyForecast,
    required this.description,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      location: json['location'] ?? 'Jakarta',
      temperature: (json['temperature'] ?? 32.0).toDouble(),
      condition: json['condition'] ?? 'Cerah Berawan',
      icon: json['icon'] ?? '🌤️',
      humidity: json['humidity'] ?? 65,
      windSpeed: (json['windSpeed'] ?? 10.5).toDouble(),
      hourlyForecast: (json['hourlyForecast'] as List?)
          ?.map((item) => HourlyForecast.fromJson(item))
          .toList() ?? [],
      description: json['description'] ?? 'Cuaca cerah berawan dengan kemungkinan hujan ringan',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'temperature': temperature,
      'condition': condition,
      'icon': icon,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'hourlyForecast': hourlyForecast.map((item) => item.toJson()).toList(),
      'description': description,
    };
  }
}

class HourlyForecast {
  final String time;
  final double temperature;
  final String icon;
  final String condition;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.icon,
    required this.condition,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: json['time'] ?? '00:00',
      temperature: (json['temperature'] ?? 30.0).toDouble(),
      icon: json['icon'] ?? '☀️',
      condition: json['condition'] ?? 'Cerah',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'temperature': temperature,
      'icon': icon,
      'condition': condition,
    };
  }
}