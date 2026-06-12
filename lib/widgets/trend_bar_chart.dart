import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/trend_point.dart';

/// A bar chart widget visualizing publication trends over time.
/// The bar with the highest count is highlighted in amber.
class TrendBarChart extends StatefulWidget {
  const TrendBarChart({super.key, required this.data});

  final List<TrendPoint> data;

  @override
  State<TrendBarChart> createState() => _TrendBarChartState();
}

class _TrendBarChartState extends State<TrendBarChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const SizedBox(
        height: 250,
        child: Center(child: Text('No trend data available')),
      );
    }

    final maxCount = widget.data.map((t) => t.count).reduce((a, b) => a > b ? a : b);
    final maxYear = widget.data.firstWhere((t) => t.count == maxCount).year;

    final colorScheme = Theme.of(context).colorScheme;
    final barColor = colorScheme.primary;
    const peakColor = Colors.amber;

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          maxY: maxCount * 1.15,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => colorScheme.inverseSurface,
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final point = widget.data[groupIndex];
                return BarTooltipItem(
                  '${point.year}\n',
                  TextStyle(
                    color: colorScheme.onInverseSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(
                      text: '${point.count} papers',
                      style: TextStyle(
                        color: colorScheme.onInverseSurface.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                );
              },
            ),
            touchCallback: (FlTouchEvent event, barTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    barTouchResponse == null ||
                    barTouchResponse.spot == null) {
                  _touchedIndex = -1;
                } else {
                  _touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                }
              });
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                // Limit to ~5 labels to prevent overlapping on Y axis
                interval: maxCount > 0 ? (maxCount / 5).ceilToDouble() : 1,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  final label = value >= 1000
                      ? '${(value / 1000).toStringAsFixed(0)}k'
                      : value.toInt().toString();
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      label,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= widget.data.length) {
                    return const SizedBox.shrink();
                  }
                  final year = widget.data[index].year;
                  // Show label every 5 years to avoid overlap
                  if (year % 5 != 0) return const SizedBox.shrink();
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      '$year',
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withValues(alpha: 0.15),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: widget.data.asMap().entries.map((entry) {
            final index = entry.key;
            final point = entry.value;
            final isPeak = point.year == maxYear;
            final isTouched = index == _touchedIndex;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: point.count.toDouble(),
                  color: isPeak
                      ? peakColor
                      : isTouched
                          ? barColor.withValues(alpha: 0.7)
                          : barColor,
                  width: _calculateBarWidth(widget.data.length),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  double _calculateBarWidth(int count) {
    if (count <= 15) return 14;
    if (count <= 25) return 9;
    return 6;
  }
}
