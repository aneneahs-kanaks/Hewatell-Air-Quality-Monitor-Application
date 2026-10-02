import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../air_history_repository.dart';

class PreviousDataScreen extends StatefulWidget {
  const PreviousDataScreen({super.key});

  @override
  State<PreviousDataScreen> createState() => _PreviousDataScreenState();
}

class _PreviousDataScreenState extends State<PreviousDataScreen> {
  // Defaults to the last 7 days
  DateTimeRange? _selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 7)),
    end: DateTime.now(),
  );

  bool _hasRequestedData = false;
  bool _isLoading = false;

  String _selectedGasKey = 'CO₂';

  List<AirDataLog> _filteredLogs = [];

  // ─────────────────────────────────────────────
  // REQUEST DATA
  // ─────────────────────────────────────────────

  void _executeDataFetchRequest() {
    if (_selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a calendar date range first! 📅',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasRequestedData = false;
    });

    Timer(const Duration(milliseconds: 600), () {
      final logs = AirHistoryRepository.instance.getLogsForRange(
        _selectedDateRange!.start,
        _selectedDateRange!.end,
      );

      if (mounted) {
        setState(() {
          _filteredLogs = logs;
          _isLoading = false;
          _hasRequestedData = true;
        });
      }
    });
  }

  // ─────────────────────────────────────────────
  // DATE RANGE PICKER
  // ─────────────────────────────────────────────

  Future<void> _openCalendarPickerRange() async {
    final DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      setState(() {
        _selectedDateRange = pickedRange;
        _hasRequestedData = false;
      });
    }
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final String dateButtonLabel = _selectedDateRange == null
        ? 'Choose Date Range'
        : '${DateFormat('MMM dd').format(_selectedDateRange!.start)}'
        '  –  '
        '${DateFormat('MMM dd').format(_selectedDateRange!.end)}';

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          'Historical Analytics',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ─────────────────────────────────
              // DATE RANGE BUTTON
              // ─────────────────────────────────

              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  side: const BorderSide(
                    color: Colors.teal,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                icon: const Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.teal,
                ),

                label: Text(
                  dateButtonLabel,
                  style: const TextStyle(
                    color: Colors.teal,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                onPressed: _openCalendarPickerRange,
              ),

              const SizedBox(height: 12),

              // ─────────────────────────────────
              // REQUEST DATA BUTTON
              // ─────────────────────────────────

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                onPressed:
                _isLoading ? null : _executeDataFetchRequest,

                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Request Data',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Divider(
                height: 40,
              ),

              // ─────────────────────────────────
              // INITIAL STATE
              // ─────────────────────────────────

              if (!_hasRequestedData && !_isLoading)
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 70,
                        color: Colors.grey.shade300,
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Awaiting Filter Ranges',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),

                      const Text(
                        'Select target range blocks above to isolate '
                            'generated sensor tracks.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

              // ─────────────────────────────────
              // REQUESTED DATA
              // ─────────────────────────────────

              if (_hasRequestedData) ...[
                if (_filteredLogs.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'No simulated logs found for this date range. '
                            'Go to Current Data to generate points first!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                else ...[
                  // ─────────────────────────────
                  // PARAMETER SELECTION
                  // ─────────────────────────────

                  const Text(
                    'Select Parameter to Plot:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 8),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        'CO₂',
                        'Nitrogen',
                        'VOC',
                        'Dust',
                        'Ethylene',
                      ].map((gas) {
                        final bool isSelected =
                            _selectedGasKey == gas;

                        return Padding(
                          padding:
                          const EdgeInsets.only(right: 6.0),
                          child: ChoiceChip(
                            label: Text(
                              gas,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.teal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            selected: isSelected,

                            selectedColor: Colors.teal,

                            backgroundColor:
                            Colors.teal.shade50,

                            onSelected: (bool selected) {
                              if (selected) {
                                setState(() {
                                  _selectedGasKey = gas;
                                });
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ─────────────────────────────
                  // SCIENTIFIC ANALYTICS GRAPH
                  // ─────────────────────────────

                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          '$_selectedGasKey Level Analytics Over Time',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Container(
                        height: 240,
                        padding: const EdgeInsets.only(
                          right: 20,
                          left: 10,
                          top: 10,
                          bottom: 10,
                        ),
                        child: LineChart(
                          LineChartData(

                            // ─────────────────────
                            // GRID
                            // ─────────────────────

                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: true,

                              getDrawingHorizontalLine:
                                  (value) {
                                return FlLine(
                                  color:
                                  Colors.grey.shade200,
                                  strokeWidth: 1,
                                );
                              },

                              getDrawingVerticalLine:
                                  (value) {
                                return FlLine(
                                  color:
                                  Colors.grey.shade200,
                                  strokeWidth: 1,
                                );
                              },
                            ),

                            // ─────────────────────
                            // BORDER
                            // ─────────────────────

                            borderData: FlBorderData(
                              show: true,
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey.shade400,
                                  width: 1.5,
                                ),
                                left: BorderSide(
                                  color: Colors.grey.shade400,
                                  width: 1.5,
                                ),
                              ),
                            ),

                            // ─────────────────────
                            // AXIS TITLES
                            // ─────────────────────

                            titlesData: FlTitlesData(

                              rightTitles:
                              const AxisTitles(
                                sideTitles:
                                SideTitles(
                                  showTitles: false,
                                ),
                              ),

                              topTitles:
                              const AxisTitles(
                                sideTitles:
                                SideTitles(
                                  showTitles: false,
                                ),
                              ),

                              // Y-axis
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 45,

                                  getTitlesWidget:
                                      (value, meta) {
                                    return Text(
                                      value.toStringAsFixed(0),
                                      style:
                                      const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                        fontWeight:
                                        FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                              ),

                              // X-axis
                              bottomTitles:
                              AxisTitles(
                                sideTitles:
                                SideTitles(
                                  showTitles: true,
                                  reservedSize: 22,

                                  interval:
                                  (_filteredLogs.length /
                                      5)
                                      .clamp(
                                    1,
                                    double.infinity,
                                  ),

                                  getTitlesWidget:
                                      (value, meta) {
                                    final int index =
                                    value.toInt();

                                    if (index >= 0 &&
                                        index <
                                            _filteredLogs
                                                .length) {
                                      return Text(
                                        DateFormat(
                                          'mm:ss',
                                        ).format(
                                          _filteredLogs[
                                          index]
                                              .timestamp,
                                        ),
                                        style:
                                        const TextStyle(
                                          fontSize: 9,
                                          color:
                                          Colors.grey,
                                          fontWeight:
                                          FontWeight
                                              .bold,
                                        ),
                                      );
                                    }

                                    return const Text('');
                                  },
                                ),
                              ),
                            ),

                            // ─────────────────────
                            // GRAPH DATA
                            // ─────────────────────

                            lineBarsData: [
                              LineChartBarData(
                                spots: List.generate(
                                  _filteredLogs.length,
                                      (index) {
                                    double yValue = 0.0;

                                    final log =
                                    _filteredLogs[index];

                                    if (_selectedGasKey ==
                                        'CO₂') {
                                      yValue = log.co2;
                                    }

                                    if (_selectedGasKey ==
                                        'Nitrogen') {
                                      yValue =
                                          log.nitrogen;
                                    }

                                    if (_selectedGasKey ==
                                        'VOC') {
                                      yValue = log.voc;
                                    }

                                    if (_selectedGasKey ==
                                        'Dust') {
                                      yValue = log.dust;
                                    }

                                    if (_selectedGasKey ==
                                        'Ethylene') {
                                      yValue =
                                          log.ethylene;
                                    }

                                    return FlSpot(
                                      index.toDouble(),
                                      yValue,
                                    );
                                  },
                                ),

                                isCurved: true,

                                color: Colors.teal,

                                barWidth: 3.5,

                                isStrokeCapRound: true,

                                dotData: const FlDotData(
                                  show: true,
                                ),

                                belowBarData:
                                BarAreaData(
                                  show: true,
                                  color: Colors.teal
                                      .withOpacity(0.12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ─────────────────────────────
                  // LOG COUNT
                  // ─────────────────────────────

                  Text(
                    'Captured Logs Data Count: '
                        '(${_filteredLogs.length} points)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ─────────────────────────────
                  // LOG LIST
                  // ─────────────────────────────

                  Container(
                    height: 200,

                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                      borderRadius:
                      BorderRadius.circular(8),
                    ),

                    child: ListView.builder(
                      itemCount: _filteredLogs.length,

                      itemBuilder: (context, idx) {
                        final logItem =
                        _filteredLogs[idx];

                        final String logTime =
                        DateFormat(
                          'hh:mm:ss a',
                        ).format(logItem.timestamp);

                        return ListTile(
                          dense: true,

                          title: Text(
                            '📍 ${logItem.location} at $logTime',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          subtitle: Text(
                            'CO₂: '
                                '${logItem.co2.toStringAsFixed(0)}'
                                ' | N₂: '
                                '${logItem.nitrogen.toStringAsFixed(0)}'
                                ' | VOC: '
                                '${logItem.voc.toStringAsFixed(2)}'
                                ' | Dust: '
                                '${logItem.dust.toStringAsFixed(0)}',
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}