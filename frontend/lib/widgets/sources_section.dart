/// 來源新聞標籤元件
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SourcesSection extends StatelessWidget {
  final String? source1;
  final String? source2;
  const SourcesSection({super.key, this.source1, this.source2});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '\u9748\u611f\u4f86\u6e90',
          style: TextStyle(
            color: AppTheme.textMutedLight,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            if (source1 != null) _SourceChip(label: source1!),
            if (source2 != null) _SourceChip(label: source2!),
          ],
        ),
      ],
    );
  }
}

class _SourceChip extends StatelessWidget {
  final String label;
  const _SourceChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.surfaceMutedLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.link, size: 12, color: AppTheme.textMutedLight),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondaryLight,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
