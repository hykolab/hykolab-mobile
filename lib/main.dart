import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'models/tank_reading.dart';
import 'models/weather_data.dart';
import 'providers/tank_data_provider.dart';
import 'providers/weather_provider.dart';

void main() {
  runApp(const HykolabApp());
}

class HykolabApp extends StatelessWidget {
  const HykolabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => TankDataProvider()..loadLatestReading(),
        ),
        ChangeNotifierProvider(
          create: (context) => WeatherProvider()..loadCurrentWeather(),
        ),
      ],
      child: MaterialApp(
        title: 'Hykolab',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const MainPage(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const BerandaPage(),
    const CuacaPage(),
    const AnalisisPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF2196F3),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.cloud),
              label: 'Cuaca',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Analisis',
            ),
          ],
        ),
      ),
    );
  }
}

// HALAMAN BERANDA
class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF08435D),
              Color(0xFF118DC3),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<TankDataProvider>(
            builder: (context, tankData, child) {
              return RefreshIndicator(
                onRefresh: () async {
                  await tankData.refreshData();
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with connection status
                Row(
                  children: [
                    Expanded(
                      child: const Center(
                        child: Text(
                          'BERANDA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: tankData.hasData ? Colors.green.withOpacity(0.8) : 
                               tankData.isLoading ? Colors.orange.withOpacity(0.8) :
                               Colors.red.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            tankData.hasData ? Icons.wifi : 
                            tankData.isLoading ? Icons.sync : Icons.wifi_off,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tankData.hasData ? 'Live' : 
                            tankData.isLoading ? 'Sync' : 'Offline',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                
                // Tangki Air
                Center(
                  child: SizedBox(
                    width: 270,
                    height: 250,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Tank outline image (sekarang di bawah air)
                        Container(
                          width: 260,
                          height: 280,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.transparent, width: 0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.asset(
                              'assets/images/tank.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),

                        // Air dalam tangki (dihitung dari persentase) - di atas image
                        Consumer<TankDataProvider>(
                          builder: (context, tankData, child) {
                            final fillPercent = (tankData.latestReading?.capacityPercentage ?? 30.0) / 100;
                            final double tankInnerWidth = 240; // slightly smaller than image width
                            final double tankInnerHeight = 250; // full height of tank area
                            final double waterHeight = tankInnerHeight * fillPercent.clamp(0.0, 1.0);

                            return Positioned(
                              bottom: 0,
                              child: Container(
                                width: tankInnerWidth-33,
                                height: waterHeight,
                                decoration: BoxDecoration(
                                  color: Colors.lightBlue.withOpacity(0.8),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(18),
                                    bottomRight: Radius.circular(18),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Indicators
                        const Positioned(
                          right: -20,
                          top: 120,
                          child: Text(
                            '95L',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Positioned(
                          right: -30,
                          top: 20,
                          child: Text(
                            '300L',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 23),
                
                // Statistik dalam Row
                Consumer<TankDataProvider>(
                  builder: (context, tankData, child) {
                    final reading = tankData.latestReading;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard(
                          'pH', 
                          reading?.phDisplay ?? 'N/A', 
                          '/14',
                          true // Show suffix on new line
                        ),
                        _buildStatCard(
                          'Kapasitas', 
                          reading != null ? '${reading.capacityPercentage.toInt()}%' : 'N/A', 
                          '',
                          false
                        ),
                        _buildStatCard(
                          'Kejernihan', 
                          reading?.qualityScore.toStringAsFixed(1) ?? 'N/A', 
                          '/10',
                          true // Show suffix on new line
                        ),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Info Kualitas Air (ikon berada di dalam kotak card)
                Consumer<TankDataProvider>(
                  builder: (context, tankData, child) {
                    final reading = tankData.latestReading;
                    final recommendation = reading?.recommendation ?? 
                        'Menunggu data dari sensor untuk analisis kualitas air.';
                    
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white70),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/images/lamp.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.lightbulb,
                                  color: Colors.yellow,
                                  size: 36,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Kualitas Air',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (tankData.isLoading)
                                      const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  recommendation,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),
                
                // Info Cuaca Bottom Card
                SizedBox(
                  height: 220,
                  child: Row(
                    children: [
                      Expanded(
                        child: Consumer<WeatherProvider>(
                          builder: (context, weatherProvider, child) {
                            final currentWeather = weatherProvider.currentWeather;
                            final isLoading = weatherProvider.isLoading;
                            
                            return Container(
                              height: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1976D2), // blue background
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Stack(
                                children: [
                                  // Small city label top-right
                                  Positioned(
                                    top: 4,
                                    right: 8,
                                    child: Text(
                                      currentWeather?.location ?? 'Gambir, Jakarta Pusat',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),

                                  // Main content column aligned to start
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 14),
                                      if (isLoading)
                                        const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(20),
                                            child: CircularProgressIndicator(color: Colors.white),
                                          ),
                                        )
                                      else
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Column with weather icon on top, temperature and description below
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 64,
                                                  height: 64,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withOpacity(0.12),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(12),
                                                    child: Center(
                                                      child: Text(
                                                        currentWeather?.icon ?? '🌤️',
                                                        style: const TextStyle(fontSize: 30),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  '${(currentWeather?.temperature ?? 35).round()}°C',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  currentWeather?.condition ?? 'Cuaca cerah berawan',
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12,
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
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tren Konsumsi Air',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              '3600 L',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Anda sudah menggunakan 3600L air',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Graph placeholder
                            SizedBox(
                              height: 48,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6.0),
                                child: SimpleSparkline(
                                  values: const [10, 18, 14, 20, 26, 22, 30, 28, 34, 40],
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ),
                    ],
                  ),
                ),
              ],
              ), // Column
            ), // SingleChildScrollView
          ); // RefreshIndicator
        }, // Consumer builder
      ), // Consumer
    ), // SafeArea
  ), // Container
); // Scaffold
  }

  Widget _buildStatCard(String title, String value, String suffix, [bool suffixOnNewLine = false]) {
    // Prepare value widget with optional suffix
    Widget valueWidget;
    
    if (suffix.isNotEmpty && !value.contains(suffix)) {
      if (suffixOnNewLine) {
        // Show value and suffix on separate lines
        valueWidget = Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              suffix,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      } else {
        // Show inline
        valueWidget = RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: suffix,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }
    } else {
      valueWidget = Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 5),
          valueWidget,
        ],
      ),
    );
  }
}

// HALAMAN CUACA
class CuacaPage extends StatelessWidget {
  const CuacaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        final currentWeather = weatherProvider.currentWeather;
        final isLoading = weatherProvider.isLoading;

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () => weatherProvider.refreshWeatherData(),
            child: Container(
              constraints: BoxConstraints(minHeight: screenHeight),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1976D2),
                    Color(0xFF64B5F6),
                  ],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: isLoading 
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          const Center(
                            child: Text(
                              'CUACA',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Main Weather Info
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      currentWeather?.location ?? 'Gambir, Jakarta Pusat',
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                _formatDate(DateTime.now()),
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Temperature and Weather Icon
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${currentWeather?.temperature ?? 32}°C',
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 80,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 20),
                                  // Weather icon on the right
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: SizedBox(
                                        width: 180,
                                        height: 180,
                                        child: _getWeatherIcon(currentWeather?.condition ?? 'Cerah'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),
                              Text(
                                weatherProvider.getWaterCollectionRecommendation(),
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // Prediksi Cuaca
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Prediksi Cuaca',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: (currentWeather?.hourlyForecast ?? [])
                                      .take(5)
                                      .map((forecast) => _buildWeatherItem(
                                        forecast.time,
                                        '${forecast.temperature}°C',
                                        _getEmojiForCondition(forecast.condition),
                                      ))
                                      .toList(),
                                ),

                                const SizedBox(height: 30),

                                // AI Insight (yellow card with lamp image)
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFCC40),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.asset(
                                            'assets/images/lamp.png',
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => const Icon(
                                              Icons.lightbulb,
                                              color: Colors.white,
                                              size: 28,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'AI Insight',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              weatherProvider.getWaterCollectionRecommendation(),
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    final months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 
                   'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    
    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'cerah':
        return const AnimatedSun();
      case 'berawan':
        return const Icon(Icons.cloud, size: 140, color: Colors.white70);
      case 'hujan ringan':
      case 'hujan':
      case 'hujan deras':
        return const Icon(Icons.cloud_queue, size: 140, color: Colors.white70);
      default:
        return const AnimatedSun();
    }
  }

  String _getEmojiForCondition(String condition) {
    switch (condition.toLowerCase()) {
      case 'cerah':
        return '☀️';
      case 'berawan':
        return '☁️';
      case 'hujan ringan':
      case 'hujan':
        return '🌧️';
      case 'hujan deras':
        return '⛈️';
      default:
        return '☀️';
    }
  }

  Widget _buildWeatherItem(String time, String temp, String icon) {
    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            time,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            icon,
            style: const TextStyle(fontSize: 36),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            temp,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// HALAMAN ANALISIS
class AnalisisPage extends StatefulWidget {
  const AnalisisPage({super.key});

  @override
  State<AnalisisPage> createState() => _AnalisisPageState();
}

class _AnalisisPageState extends State<AnalisisPage> {
  int _activeTab = 0; // 0=Harian,1=Bulanan,2=Tahunan

  List<FlSpot> _getChartSpots(List<TankReading> readings) {
    if (readings.isEmpty) {
      // Return dummy data if no readings available
      switch (_activeTab) {
        case 0:
          return const [
            FlSpot(0, 8), FlSpot(1, 12), FlSpot(2, 10), FlSpot(3, 14), FlSpot(4, 18),
            FlSpot(5, 15), FlSpot(6, 20), FlSpot(7, 24), FlSpot(8, 22), FlSpot(9, 26),
          ];
        case 1:
          return const [
            FlSpot(0, 80), FlSpot(1, 120), FlSpot(2, 100), FlSpot(3, 140),
            FlSpot(4, 180), FlSpot(5, 150), FlSpot(6, 200),
          ];
        case 2:
        default:
          return const [
            FlSpot(0, 800), FlSpot(1, 900), FlSpot(2, 1100),
            FlSpot(3, 1050), FlSpot(4, 1300), FlSpot(5, 1600),
          ];
      }
    }

    // Filter readings based on selected tab
    Duration filterDuration;
    switch (_activeTab) {
      case 0: // Daily
        filterDuration = const Duration(hours: 24);
      case 1: // Monthly
        filterDuration = const Duration(days: 30);
      case 2: // Yearly
      default:
        filterDuration = const Duration(days: 365);
    }

    final cutoffTime = DateTime.now().subtract(filterDuration);
    final filteredReadings = readings
        .where((reading) => reading.timestamp.isAfter(cutoffTime))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (filteredReadings.isEmpty) {
      return const [FlSpot(0, 0)];
    }

    // Convert readings to chart spots based on volume data
    final spots = <FlSpot>[];
    for (int i = 0; i < filteredReadings.length && i < 20; i++) {
      final reading = filteredReadings[i];
      spots.add(FlSpot(i.toDouble(), reading.volumeL ?? 0.0));
    }

    return spots;
  }

  Widget _tabButton(String text, int index) {
    final isActive = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0773A2) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.white : Colors.black54,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0773A2),
              Color(0xFF59AFD5),
              Color(0xFFA0D1E7),
            ],
            stops: [0.0, 0.45, 0.9],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header row with title and right-aligned pill
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'ANALISIS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Text(
                        'Terakhir sesak 15 Juli 2025',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Total Air (left aligned)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Total air yang telah didapatkan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '36000',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Liter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Statistik cards
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white70),
                        ),
                        child: Column(
                          children: const [
                            Text(
                              'Total dalam setahun',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '2300 L',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '+10% sejak Juli 2024',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white70),
                        ),
                        child: Column(
                          children: const [
                            Text(
                              'Total dalam sebulan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '1000 L',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '-5% sejak Juli 2025',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Trend container with tabs and chart
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tren Konsumsi Air',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          _tabButton('Harian', 0),
                          _tabButton('Bulanan', 1),
                          _tabButton('Tahunan', 2),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Current consumption (static for demo)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            '155',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'Liter',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              '+6%',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        height: 160,
                        width: double.infinity,
                        child: Consumer<TankDataProvider>(
                          builder: (context, tankData, child) {
                            final spots = _getChartSpots(tankData.readings);
                            return AreaConsumptionChart(spots: spots);
                          },
                        ),
                      ),

                      const SizedBox(height: 10),
                      const Text(
                        'Periode 25 Juni 2025 - 25 Juli 2025',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Simple horizontal sparkline widget using fl_chart's LineChart
class SimpleSparkline extends StatelessWidget {
  final List<double> values;
  final Color color;

  const SimpleSparkline({super.key, required this.values, this.color = Colors.blue});

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();

    final spots = <FlSpot>[];
    for (var i = 0; i < values.length; i++) {
      spots.add(FlSpot(i.toDouble(), values[i]));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(enabled: false),
        minY: values.reduce((a, b) => a < b ? a : b),
        maxY: values.reduce((a, b) => a > b ? a : b),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 2,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}

// Area chart for consumption trends
class AreaConsumptionChart extends StatelessWidget {
  final List<FlSpot> spots;

  const AreaConsumptionChart({super.key, required this.spots});

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) return const SizedBox.shrink();

    // compute minY and maxY
    double minY = spots.first.y;
    double maxY = spots.first.y;
    for (final s in spots) {
      if (s.y < minY) minY = s.y;
      if (s.y > maxY) maxY = s.y;
    }

    // add some padding
    final yPadding = (maxY - minY) * 0.2;
    if (yPadding == 0) {
      // avoid zero padding
      minY -= 1;
      maxY += 1;
    } else {
      minY -= yPadding;
      maxY += yPadding;
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minY: minY,
        maxY: maxY,
        lineTouchData: LineTouchData(enabled: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: LinearGradient(colors: [Colors.blue.shade700, Colors.blue.shade300]),
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [Colors.blue.withOpacity(0.35), Colors.blue.withOpacity(0.05)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Animated sun widget: subtle rotation + pulse
class AnimatedSun extends StatefulWidget {
  const AnimatedSun({super.key});

  @override
  State<AnimatedSun> createState() => _AnimatedSunState();
}

class _AnimatedSunState extends State<AnimatedSun> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _rotationAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotationAnim = Tween<double>(begin: -0.03, end: 0.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnim.value,
          child: Transform.scale(
            scale: _scaleAnim.value,
            child: SizedBox(
              width: 180,
              height: 180,
              child: Center(
                // Try to load a real sun image from assets. If the asset is missing or fails
                // to load, fall back to a Material icon that resembles the sun.
                child: Image.asset(
                  'assets/images/sun.png',
                  width: 160,
                  height: 160,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFFE58A),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.yellow.withOpacity(0.25),
                            blurRadius: 24,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.wb_sunny,
                        size: 96,
                        color: Color(0xFFFFCC40),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}