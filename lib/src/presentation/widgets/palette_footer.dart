import 'package:flutter/material.dart';

/// Footer with keyboard hints for command palette
class PaletteFooter extends StatelessWidget {
  const PaletteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildHint(context, '↵', 'Confirm'),
          const SizedBox(width: 16),
          _buildHint(context, '↑↓', 'Navigate'),
          const SizedBox(width: 16),
          _buildHint(context, 'Esc', 'Close'),
          const Spacer(),
          _buildHint(context, 'Cmd+K', 'Commands', isRight: true),
        ],
      ),
    );
  }

  Widget _buildHint(
    BuildContext context,
    String key,
    String label, {
    bool isRight = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isRight) ...[
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: 10,
            ),
          ),
          const SizedBox(width: 6),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: Text(
            key,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 10,
              height: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (!isRight) ...[
          const SizedBox(width: 6),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }
}
