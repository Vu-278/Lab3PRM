/// Represents a publication count data point for a given year.
/// Used for rendering trend bar charts.
class TrendPoint {
  const TrendPoint({required this.year, required this.count});

  final int year;
  final int count;

  factory TrendPoint.fromGroupBy(Map<String, dynamic> json) {
    return TrendPoint(
      year: int.tryParse(json['key']?.toString() ?? '') ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}
