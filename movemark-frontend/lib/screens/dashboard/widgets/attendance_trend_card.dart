import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:movemark/model/monthly_attendance.dart';

class AttendanceTrendCard extends StatefulWidget {
  final List<MonthlyAttendance> monthlyData;
  final bool isSingleDay;

  const AttendanceTrendCard({
    Key? key,
    required this.monthlyData,
    required this.isSingleDay,
  }) : super(key: key);

  @override
  State<AttendanceTrendCard> createState() => _AttendanceTrendCardState();
}

class _AttendanceTrendCardState extends State<AttendanceTrendCard> {
  // Define custom colors
  static const Color lineColor = Color(0xFF2196F3);
  static const Color gridLineColor = Color(0xFFEEEEEE);
  static const Color textColor = Color(0xFF757575);

  String _formatBottomTitle(double value) {
    if (value >= 0 && value < widget.monthlyData.length) {
      final date = widget.monthlyData[value.toInt()].month;
      if (widget.isSingleDay) {
        return DateFormat('HH:mm').format(date);
      } else {
        return DateFormat('MMM').format(date);
      }
    }
    return '';
  }

  double _getMinY() {
    if (widget.monthlyData.isEmpty) return 0;
    double min = widget.monthlyData
        .map((d) => d.percentage)
        .reduce((a, b) => a < b ? a : b);
    return (min - 5).clamp(0, 95);
  }

  double _getMaxY() {
    if (widget.monthlyData.isEmpty) return 100;
    double max = widget.monthlyData
        .map((d) => d.percentage)
        .reduce((a, b) => a > b ? a : b);
    return (max + 5).clamp(5, 100);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Attendance Trend',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: lineColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.isSingleDay ? 'Hourly' : 'Monthly',
                    style: const TextStyle(
                      color: lineColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: widget.isSingleDay ? 2 : 10,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: gridLineColor,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (widget.isSingleDay) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                color: textColor,
                                fontSize: 12,
                              ),
                            );
                          } else {
                            return Text(
                              '${value.toInt()}%',
                              style: const TextStyle(
                                color: textColor,
                                fontSize: 12,
                              ),
                            );
                          }
                        },
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Transform.rotate(
                              angle: widget.isSingleDay ? -0.5 : 0,
                              child: Text(
                                _formatBottomTitle(value),
                                style: const TextStyle(
                                  color: textColor,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        },
                        reservedSize: widget.isSingleDay ? 50 : 30,
                        interval: widget.isSingleDay ? 2 : 1,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: widget.monthlyData
                          .asMap()
                          .entries
                          .map((entry) => FlSpot(
                              entry.key.toDouble(), entry.value.percentage))
                          .toList(),
                      isCurved: !widget.isSingleDay,
                      color: lineColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: lineColor,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: lineColor.withOpacity(0.1),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            lineColor.withOpacity(0.2),
                            lineColor.withOpacity(0.05),
                          ],
                        ),
                      ),
                    ),
                  ],
                  minY: _getMinY(),
                  maxY: _getMaxY(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
