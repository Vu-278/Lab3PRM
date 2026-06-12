import 'package:flutter/material.dart';

import '../models/publication.dart';

/// Card widget displaying a publication's key information.
class PublicationCard extends StatelessWidget {
  const PublicationCard({
    super.key,
    required this.publication,
    required this.onTap,
  });

  final Publication publication;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final authorsText = _buildAuthorsText();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                publication.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              // Meta row: year | citations | journal
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _MetaChip(
                    icon: Icons.calendar_today_outlined,
                    label: publication.year > 0 ? '${publication.year}' : 'N/A',
                    color: colorScheme.primary,
                  ),
                  _MetaChip(
                    icon: Icons.format_quote_rounded,
                    label: '${publication.citationCount} citations',
                    color: colorScheme.tertiary,
                  ),
                  if (publication.journalName != null)
                    _MetaChip(
                      icon: Icons.library_books_outlined,
                      label: publication.journalName!,
                      color: colorScheme.secondary,
                      maxWidth: 160,
                    ),
                ],
              ),
              if (authorsText.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        authorsText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _buildAuthorsText() {
    if (publication.authors.isEmpty) return '';
    if (publication.authors.length <= 2) {
      return publication.authors.join(', ');
    }
    final extra = publication.authors.length - 2;
    return '${publication.authors.take(2).join(', ')} +$extra more';
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
    this.maxWidth,
  });

  final IconData icon;
  final String label;
  final Color color;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: maxWidth != null ? BoxConstraints(maxWidth: maxWidth!) : null,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
