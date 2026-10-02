import 'dart:async';
import 'dart:math';
import '../air_history_repository.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class CurrentDataScreen extends StatefulWidget {
  const CurrentDataScreen({super.key});

  @override
  State<CurrentDataScreen> createState() => _CurrentDataScreenState();
}

class _CurrentDataScreenState extends State<CurrentDataScreen> {
  final StreamController<Map<String, dynamic>> _mockDataController =
  StreamController<Map<String, dynamic>>.broadcast();

  Timer? _mockTimer;
  final Random _random = Random();

  // ─── Start the local mock data simulation ───
  @override
  void initState() {
    super.initState();
    _startLocalMockLoop();
  }

  void _startLocalMockLoop() {
    final List<String> mockLocations = [
      'Mathari, Nairobi',
      'Pangani, Nairobi',
      'Eastleigh, Nairobi',
      'Huruma, Nairobi',
      'Parklands, Nairobi'
    ];

    _mockTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final currentTimestamp = DateTime.now();
      final randomLocation =
      mockLocations[_random.nextInt(mockLocations.length)];

      final int co2Val = 400 + _random.nextInt(1000);
      final int nitrogenVal = 100 + _random.nextInt(350);
      final double vocVal = 0.05 + _random.nextDouble() * 2.7;
      final int dustVal = 5 + _random.nextInt(85);
      final double ethyleneVal = 0.005 + _random.nextDouble() * 0.17;

      final mockPayload = {
        'location': randomLocation,
        'timestamp': currentTimestamp,
        'carbonDioxide': co2Val,
        'nitrogen': nitrogenVal,
        'voc': vocVal,
        'dust': dustVal,
        'ethylene': ethyleneVal,
      };

      // Save the generated reading into the history repository
      AirHistoryRepository.instance.addLog(
        AirDataLog(
          timestamp: currentTimestamp,
          location: randomLocation,
          co2: co2Val.toDouble(),
          nitrogen: nitrogenVal.toDouble(),
          voc: vocVal,
          dust: dustVal.toDouble(),
          ethylene: ethyleneVal,
        ),
      );

      if (!_mockDataController.isClosed) {
        _mockDataController.add(mockPayload);
      }
    });
  }

  @override
  void dispose() {
    _mockTimer?.cancel();
    _mockDataController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Current Sensor Data',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: StreamBuilder<Map<String, dynamic>>(
          stream: _mockDataController.stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.teal,
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(
                child: Text('No data available'),
              );
            }

            final data = snapshot.data!;

            final String formattedTime =
            DateFormat('hh:mm:ss a').format(data['timestamp']);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── Location + Sync Time ───
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '📍 ${data['location']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '🕐 Sync: $formattedTime',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ─── CO₂ Primary Gauge ───
                  _buildPrimaryGaugeCard(
                    title: 'Carbon Dioxide (CO₂)',
                    value: (data['carbonDioxide'] as int).toDouble(),
                    unit: 'ppm',
                    min: 400,
                    max: 1500,
                    greenEnd: 600,
                    amberEnd: 1000,
                  ),

                  const SizedBox(height: 16),

                  // ─── Section Heading ───
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Environmental Gas Breakdowns',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),

                  // ─── 2 × 2 Gauge Grid ───
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 0.85,
                    children: [
                      _buildGridGaugeCard(
                        title: 'Nitrogen (N₂)',
                        value: (data['nitrogen'] as int).toDouble(),
                        unit: 'ppm',
                        min: 0,
                        max: 500,
                        greenEnd: 200,
                        amberEnd: 350,
                        decimalPlaces: 0,
                      ),

                      _buildGridGaugeCard(
                        title: 'VOC Exposure',
                        value: data['voc'] as double,
                        unit: 'ppm',
                        min: 0.0,
                        max: 3.0,
                        greenEnd: 0.5,
                        amberEnd: 1.5,
                        decimalPlaces: 2,
                      ),

                      _buildGridGaugeCard(
                        title: 'Dust / PM',
                        value: (data['dust'] as int).toDouble(),
                        unit: 'µg/m³',
                        min: 0,
                        max: 100,
                        greenEnd: 35,
                        amberEnd: 75,
                        decimalPlaces: 0,
                      ),

                      _buildGridGaugeCard(
                        title: 'Ethylene (C₂H₄)',
                        value: data['ethylene'] as double,
                        unit: 'ppm',
                        min: 0.000,
                        max: 0.200,
                        greenEnd: 0.050,
                        amberEnd: 0.120,
                        decimalPlaces: 3,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── Primary CO₂ Gauge Card ───
  Widget _buildPrimaryGaugeCard({
    required String title,
    required double value,
    required String unit,
    required double min,
    required double max,
    required double greenEnd,
    required double amberEnd,
  }) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            SizedBox(
              height: 180,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    minimum: min,
                    maximum: max,
                    showLabels: true,
                    showTicks: true,

                    axisLineStyle: const AxisLineStyle(
                      thickness: 8,
                      color: Colors.black12,
                    ),

                    ranges: <GaugeRange>[
                      GaugeRange(
                        startValue: min,
                        endValue: greenEnd,
                        color: Colors.green,
                        startWidth: 8,
                        endWidth: 8,
                      ),

                      GaugeRange(
                        startValue: greenEnd,
                        endValue: amberEnd,
                        color: Colors.amber,
                        startWidth: 8,
                        endWidth: 8,
                      ),

                      GaugeRange(
                        startValue: amberEnd,
                        endValue: max,
                        color: Colors.red,
                        startWidth: 8,
                        endWidth: 8,
                      ),
                    ],

                    pointers: <GaugePointer>[
                      NeedlePointer(
                        value: value,
                        needleColor: Colors.teal,
                        knobStyle: const KnobStyle(
                          color: Colors.teal,
                          knobRadius: 0.07,
                        ),
                      ),
                    ],

                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        widget: Text(
                          '${value.toStringAsFixed(0)} $unit',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        angle: 90,
                        positionFactor: 0.8,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Secondary Grid Gauge Card ───
  Widget _buildGridGaugeCard({
    required String title,
    required double value,
    required String unit,
    required double min,
    required double max,
    required double greenEnd,
    required double amberEnd,
    required int decimalPlaces,
  }) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 8.0,
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            Expanded(
              child: SfRadialGauge(
                axes: [
                  RadialAxis(
                    minimum: min,
                    maximum: max,
                    showLabels: false,
                    showTicks: false,

                    axisLineStyle: const AxisLineStyle(
                      thickness: 6,
                      color: Colors.black12,
                    ),

                    ranges: [
                      GaugeRange(
                        startValue: min,
                        endValue: greenEnd,
                        color: Colors.green,
                        startWidth: 6,
                        endWidth: 6,
                      ),

                      GaugeRange(
                        startValue: greenEnd,
                        endValue: amberEnd,
                        color: Colors.amber,
                        startWidth: 6,
                        endWidth: 6,
                      ),

                      GaugeRange(
                        startValue: amberEnd,
                        endValue: max,
                        color: Colors.red,
                        startWidth: 6,
                        endWidth: 6,
                      ),
                    ],

                    pointers: [
                      NeedlePointer(
                        value: value,
                        needleColor: Colors.teal.shade700,
                        needleLength: 0.75,
                        knobStyle: const KnobStyle(
                          color: Colors.teal,
                          knobRadius: 0.1,
                        ),
                      ),
                    ],

                    annotations: [
                      GaugeAnnotation(
                        widget: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              value.toStringAsFixed(decimalPlaces),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),

                            Text(
                              unit,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        angle: 90,
                        positionFactor: 0.85,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}