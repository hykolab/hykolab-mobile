class TankReading {
  final DateTime timestamp;
  final String topic;
  final double? volumeL;
  final double? ph;
  final double? turbidityNtu;
  final String? recommendation;

  TankReading({
    required this.timestamp,
    required this.topic,
    this.volumeL,
    this.ph,
    this.turbidityNtu,
    this.recommendation,
  });

  factory TankReading.fromJson(Map<String, dynamic> json) {
    return TankReading(
      timestamp: DateTime.parse(json['ts']),
      topic: json['topic'] ?? '',
      volumeL: json['volume_L'] is String
          ? double.tryParse(json['volume_L'])
          : json['volume_L']?.toDouble(),
      ph: json['ph'] is String
          ? double.tryParse(json['ph'])
          : json['ph']?.toDouble(),
      turbidityNtu: json['turbidity_ntu'] is String
          ? double.tryParse(json['turbidity_ntu'])
          : json['turbidity_ntu']?.toDouble(),
      recommendation: json['recommendation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ts': timestamp.toIso8601String(),
      'topic': topic,
      'volume_L': volumeL,
      'ph': ph,
      'turbidity_ntu': turbidityNtu,
      'recommendation': recommendation,
    };
  }

  // Helper methods for UI display
  String get phDisplay => ph?.toStringAsFixed(2) ?? 'N/A';
  String get turbidityDisplay => turbidityNtu?.toStringAsFixed(2) ?? 'N/A';
  String get volumeDisplay => volumeL?.toStringAsFixed(1) ?? 'N/A';
  
  // Calculate capacity percentage (assuming 30L max capacity)
  double get capacityPercentage => (volumeL ?? 0) / 30.0 * 100;
  
  // Get water quality score (1-10 scale)
  double get qualityScore {
    if (ph == null || turbidityNtu == null) return 0.0;
    
    // Score based on pH (optimal 6.5-8.5)
    double phScore = 10.0;
    if (ph! < 6.5 || ph! > 8.5) {
      phScore = (ph! < 6.5) ? (ph! / 6.5 * 10) : ((14 - ph!) / 5.5 * 10);
      phScore = phScore.clamp(0.0, 10.0);
    }
    
    // Score based on turbidity (lower is better, <5 NTU is good)
    double turbidityScore = 10.0;
    if (turbidityNtu! > 5) {
      turbidityScore = (10 - (turbidityNtu! - 5) / 5).clamp(0.0, 10.0);
    }
    
    // Average of both scores
    return (phScore + turbidityScore) / 2;
  }
}