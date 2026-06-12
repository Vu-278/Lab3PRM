import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/constants.dart';
import '../core/exceptions.dart';
import '../models/author_stat.dart';
import '../models/journal_stat.dart';
import '../models/publication.dart';
import '../models/trend_point.dart';

/// Service responsible for all HTTP communication with the OpenAlex API.
class OpenAlexService {
  OpenAlexService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  // ─── Private helper ────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _get(
    String path,
    Map<String, String> params,
  ) async {
    params['mailto'] = AppConstants.mailto;

    final uri = Uri.parse('${AppConstants.baseUrl}$path')
        .replace(queryParameters: params);

    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: AppConstants.requestTimeoutSeconds));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      if (response.statusCode == 429) {
        throw const OpenAlexException('Rate limit exceeded. Please wait.');
      }

      throw OpenAlexException('HTTP ${response.statusCode}');
    } on SocketException {
      throw const NetworkException(
        'No internet connection. Please check your network.',
      );
    } on TimeoutException {
      throw const NetworkException(
        'Request timed out. Please try again.',
      );
    }
  }

  // ─── Public API methods ────────────────────────────────────────────────────

  /// Search publications by [topic] with pagination.
  /// Returns a record with the list of items and the total result count.
  Future<({List<Publication> items, int total})> searchWorks(
    String topic,
    int page,
  ) async {
    final data = await _get('/works', {
      'search': topic,
      'per_page': '${AppConstants.perPage}',
      'page': '$page',
      'sort': 'cited_by_count:desc',
      'filter': 'type:article',
    });

    final results = (data['results'] as List? ?? []);
    final total = (data['meta']?['count'] as num?)?.toInt() ?? 0;

    return (
      items: results
          .whereType<Map<String, dynamic>>()
          .map(Publication.fromJson)
          .toList(),
      total: total,
    );
  }

  /// Fetch a single publication by its OpenAlex [workId].
  Future<Publication> getWork(String workId) async {
    // Strip the full URI prefix if present
    final id = workId.replaceFirst('https://openalex.org/', '');
    final data = await _get('/works/$id', {});
    return Publication.fromJson(data);
  }

  /// Fetch publication counts grouped by year for [topic].
  /// Filters years between 1990 and the current year.
  Future<List<TrendPoint>> getTrendByYear(String topic) async {
    final data = await _get('/works', {
      'search': topic,
      'group_by': 'publication_year',
      'per_page': '${AppConstants.trendPerPage}',
    });

    final groupBy = (data['group_by'] as List? ?? []);
    final currentYear = DateTime.now().year;

    return groupBy
        .whereType<Map<String, dynamic>>()
        .map(TrendPoint.fromGroupBy)
        .where(
          (t) => t.year >= AppConstants.minTrendYear && t.year <= currentYear,
        )
        .toList()
      ..sort((a, b) => a.year.compareTo(b.year));
  }

  /// Fetch top 10 journals publishing on [topic].
  Future<List<JournalStat>> getTopJournals(String topic) async {
    final data = await _get('/works', {
      'search': topic,
      'group_by': 'primary_location.source.id',
      'per_page': '${AppConstants.analyticsPerPage}',
    });

    final groupBy = (data['group_by'] as List? ?? []);

    return groupBy
        .whereType<Map<String, dynamic>>()
        .map(
          (e) => JournalStat(
            name: e['key_display_name']?.toString() ?? 'Unknown',
            count: (e['count'] as num?)?.toInt() ?? 0,
          ),
        )
        .where((j) => j.name != 'Unknown')
        .toList();
  }

  /// Fetch top 10 authors publishing on [topic].
  Future<List<AuthorStat>> getTopAuthors(String topic) async {
    final data = await _get('/works', {
      'search': topic,
      'group_by': 'authorships.author.id',
      'per_page': '${AppConstants.analyticsPerPage}',
    });

    final groupBy = (data['group_by'] as List? ?? []);

    return groupBy
        .whereType<Map<String, dynamic>>()
        .map(
          (e) => AuthorStat(
            name: e['key_display_name']?.toString() ?? 'Unknown',
            count: (e['count'] as num?)?.toInt() ?? 0,
          ),
        )
        .where((a) => a.name != 'Unknown')
        .toList();
  }
}
