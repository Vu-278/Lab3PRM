/// Utility to decode OpenAlex abstract_inverted_index to plain text.
///
/// OpenAlex returns abstracts as an inverted index:
/// { "word": [position1, position2], ... }
/// This parser reconstructs the original text by mapping positions to words.
library;

class AbstractParser {
  AbstractParser._();

  /// Parses an inverted index map to a plain text string.
  /// Returns null if [invertedIndex] is null or empty.
  static String? parse(Map<String, dynamic>? invertedIndex) {
    if (invertedIndex == null || invertedIndex.isEmpty) return null;

    final Map<int, String> positionMap = {};

    for (final entry in invertedIndex.entries) {
      final word = entry.key;
      final positions = entry.value;
      if (positions is List) {
        for (final pos in positions) {
          if (pos is int) {
            positionMap[pos] = word;
          }
        }
      }
    }

    if (positionMap.isEmpty) return null;

    final sorted = positionMap.keys.toList()..sort();
    return sorted.map((i) => positionMap[i]).join(' ');
  }
}
