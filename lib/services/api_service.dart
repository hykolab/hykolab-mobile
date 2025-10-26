import 'dart:developer';
import '../models/tank_reading.dart';

class ApiService {
  // Using mock data for now since Neon Data API requires JWT authentication
  // To use real data, either:
  // 1. Deploy your Go backend to Railway/Render/Heroku
  // 2. Set up Neon Auth with JWT tokens
  
  static Future<List<TankReading>> getReadings({int limit = 50}) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Return mock data based on your CSV
      return _getMockReadings().take(limit).toList();
    } catch (e) {
      log('API Service Error: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<TankReading?> getLatestReading() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));
      
      final readings = _getMockReadings();
      return readings.isNotEmpty ? readings.first : null;
    } catch (e) {
      log('API Service Error: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<bool> testConnection() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      return true; // Mock connection success
    } catch (e) {
      log('Connection test failed: $e');
      return false;
    }
  }

  // Mock data based on your CSV file
  static List<TankReading> _getMockReadings() {
    return [
      TankReading(
        timestamp: DateTime.parse("2025-10-26 13:24:33.179122+00"),
        topic: "hykolab/tank/01",
        volumeL: 8.2,
        ph: 5.82,
        turbidityNtu: 4.38,
        recommendation: "Kualitas air ini menunjukkan keasaman yang rendah (pH 5.82) dan kekeruhan sedang (4.38 NTU), sehingga memerlukan pengolahan fisik dan penyesuaian pH agar dapat memenuhi baku mutu air konsumsi. Penggunaan paling sesuai adalah untuk keperluan non-potabel seperti penyiraman tanaman hias, pembilasan awal peralatan, atau flushing toilet.",
      ),
      TankReading(
        timestamp: DateTime.parse("2025-10-26 09:46:36.351975+00"),
        topic: "hykolab/tank/01",
        volumeL: 7.81,
        ph: 5.87,
        turbidityNtu: 1.14,
        recommendation: "Kualitas air menunjukkan kondisi asam (pH 5.87) dan kekeruhan yang rendah (1.14 NTU), sehingga tidak memenuhi baku mutu pH minimal untuk konsumsi langsung. Air disarankan hanya untuk keperluan non-konsumsi seperti mencuci tangan, menyiram tanaman, atau pembilasan toilet, dan wajib diolah (termasuk penyesuaian pH dan desinfeksi) agar memenuhi standar baku mutu jika akan digunakan sebagai air minum.",
      ),
      TankReading(
        timestamp: DateTime.parse("2025-10-26 09:38:32.473975+00"),
        topic: "hykolab/tank/01",
        volumeL: 7.81,
        ph: 5.82,
        turbidityNtu: 4.96,
        recommendation: "Berdasarkan hasil pengujian, kualitas air menunjukkan kondisi sedikit asam (pH 5.82) dan tingkat kekeruhan yang mendekati batas maksimum standar air minum (4.96 NTU), yang memerlukan penyesuaian pH dan filtrasi. Air ini direkomendasikan untuk penggunaan non-kontak seperti menyiram tanaman atau keperluan flushing toilet, dan memerlukan pengolahan sesuai standar ketat sebelum dapat dipertimbangkan untuk konsumsi atau pencucian peralatan makanan.",
      ),
      TankReading(
        timestamp: DateTime.parse("2025-10-26 09:36:29.26646+00"),
        topic: "hykolab/tank/01",
        volumeL: 8.9,
        ph: 5.86,
        turbidityNtu: 0.52,
        recommendation: "Air cukup jernih dengan pH yang masih dapat diterima untuk penggunaan non-konsumsi. Sesuai untuk cuci tangan cepat, pel lantai, dan siram tanaman; tidak direkomendasikan untuk diminum.",
      ),
      TankReading(
        timestamp: DateTime.parse("2025-10-26 09:34:26.581732+00"),
        topic: "hykolab/tank/01",
        volumeL: 8.9,
        ph: 6.0,
        turbidityNtu: 2.94,
        recommendation: "Air cukup jernih dengan pH yang masih dapat diterima untuk penggunaan non-konsumsi. Sesuai untuk cuci tangan cepat, pel lantai, dan siram tanaman; tidak direkomendasikan untuk diminum.",
      ),
      TankReading(
        timestamp: DateTime.parse("2025-10-26 09:32:26.752212+00"),
        topic: "hykolab/tank/01",
        volumeL: 8.9,
        ph: 5.88,
        turbidityNtu: 0.82,
        recommendation: "Air cukup jernih dengan pH yang masih dapat diterima untuk penggunaan non-konsumsi. Sesuai untuk cuci tangan cepat, pel lantai, dan siram tanaman; tidak direkomendasikan untuk diminum.",
      ),
    ];
  }
}