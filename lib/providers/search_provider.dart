import 'package:flutter/foundation.dart';

import '../models/author_stat.dart';
import '../models/journal_stat.dart';
import '../models/publication.dart';
import '../models/trend_point.dart';
import '../services/openalex_service.dart';

enum SearchStatus { idle, loading, loaded, error }

/// State management for the Journal Trend Analyzer.
/// Manages search results, analytics data, and pagination.
class SearchProvider extends ChangeNotifier {
  SearchProvider({OpenAlexService? service})
      : _service = service ?? OpenAlexService();

  final OpenAlexService _service;

  // ─── State ─────────────────────────────────────────────────────────────────

  String _currentTopic = '';
  SearchStatus _status = SearchStatus.idle;
  String _errorMessage = '';

  List<Publication> _publications = [];
  int _totalCount = 0;
  int _currentPage = 1;
  bool _hasMore = false;
  bool _isLoadingMore = false;

  /// Trend analytics data by year.
  List<TrendPoint> _trendData = [];
  /// List of journals with the most publications.
  List<JournalStat> _topJournals = [];
  /// List of authors with the most publications.
  List<AuthorStat> _topAuthors = [];

  // ─── Getters ───────────────────────────────────────────────────────────────

  /// The currently searched topic.
  String get currentTopic => _currentTopic;
  /// The current status of the provider.
  SearchStatus get status => _status;
  /// The last occurred error message.
  String get errorMessage => _errorMessage;
  /// Unmodifiable list of loaded publications.
  List<Publication> get publications => List.unmodifiable(_publications);
  /// Total matching publications available on the server.
  int get totalCount => _totalCount;
  /// The current page being displayed.
  int get currentPage => _currentPage;
  /// Whether more pages are available to be loaded.
  bool get hasMore => _hasMore;
  /// Whether the provider is currently fetching more items.
  bool get isLoadingMore => _isLoadingMore;
  /// Unmodifiable list of trend analytics.
  List<TrendPoint> get trendData => List.unmodifiable(_trendData);
  /// Unmodifiable list of top journals.
  List<JournalStat> get topJournals => List.unmodifiable(_topJournals);
  /// Unmodifiable list of top authors.
  List<AuthorStat> get topAuthors => List.unmodifiable(_topAuthors);

  // ─── Computed getters ──────────────────────────────────────────────────────

  /// Year with the highest publication count.
  int get mostActiveYear {
    if (_trendData.isEmpty) return 0;
    return _trendData.reduce((a, b) => a.count > b.count ? a : b).year;
  }

  /// Name of the top journal (most publications).
  String get topJournal =>
      _topJournals.isEmpty ? '-' : _topJournals.first.name;

  /// Name of the top author (most publications).
  String get topAuthor => _topAuthors.isEmpty ? '-' : _topAuthors.first.name;

  /// Average citation count across loaded publications.
  double get avgCitation {
    if (_publications.isEmpty) return 0.0;
    final total =
        _publications.map((p) => p.citationCount).reduce((a, b) => a + b);
    return total / _publications.length;
  }

  /// The most cited publication from the loaded results.
  Publication? get mostCitedPaper {
    if (_publications.isEmpty) return null;
    return _publications.reduce(
      (a, b) => a.citationCount > b.citationCount ? a : b,
    );
  }

  // ─── Methods ───────────────────────────────────────────────────────────────

  /// Search for [topic] and load both publications and analytics data in parallel.
  /// Initiates a new search for the given [topic].
  /// 
  /// This method resets all existing state, pagination, and aggregated
  /// statistics before making parallel API calls to fetch the new data.
  Future<void> search(String topic) async {
    _currentTopic = topic.trim();
    _status = SearchStatus.loading;
    _publications = [];
    _currentPage = 1;
    _hasMore = false;
    _errorMessage = '';
    notifyListeners();

    try {
      await Future.wait([
        _loadPublications(),
        _loadAnalytics(),
      ]);
      _status = SearchStatus.loaded;
    } catch (e) {
      _status = SearchStatus.error;
      _errorMessage = e.toString().replaceFirst(RegExp(r'^.*Exception: '), '');
    }

    notifyListeners();
  }

  /// Load the next page of publications (infinite scroll).
  /// Loads the next page of publications for the current topic.
  /// 
  /// This is typically called by infinite scrolling UI components.
  /// If data is already loading or no more pages are available, this does nothing.
  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore || _status == SearchStatus.loading) return;

    _isLoadingMore = true;
    _currentPage++;
    notifyListeners();

    try {
      await _loadPublications();
    } catch (e) {
      // Revert page on failure
      _currentPage--;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Reset all state back to idle.
  void reset() {
    _currentTopic = '';
    _status = SearchStatus.idle;
    _errorMessage = '';
    _publications = [];
    _totalCount = 0;
    _currentPage = 1;
    _hasMore = false;
    _isLoadingMore = false;
    _trendData = [];
    _topJournals = [];
    _topAuthors = [];
    notifyListeners();
  }

  // ─── Private helpers ───────────────────────────────────────────────────────

  Future<void> _loadPublications() async {
    final result =
        await _service.searchWorks(_currentTopic, _currentPage);

    if (_currentPage == 1) {
      _publications = result.items;
    } else {
      _publications = [..._publications, ...result.items];
    }

    _totalCount = result.total;
    _hasMore = _publications.length < _totalCount;
  }

  Future<void> _loadAnalytics() async {
    final results = await Future.wait([
      _service.getTrendByYear(_currentTopic),
      _service.getTopJournals(_currentTopic),
      _service.getTopAuthors(_currentTopic),
    ]);

    _trendData = results[0] as List<TrendPoint>;
    _topJournals = results[1] as List<JournalStat>;
    _topAuthors = results[2] as List<AuthorStat>;
  }
}
