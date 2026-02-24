/// 新聞卡片元件 - 顯示單則新聞資訊
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class NewsCard extends StatelessWidget {
  final NewsItem news;
  /// 標籤顯示標籤（A / B），用於區分兩則新聞
  final String label;
  final Color labelColor;

  const NewsCard({
    super.key,
    required this.news,
    required this.label,
    this.labelColor = AppTheme.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 標籤行：來源 + 標籤徽章
          Row(
            children: [
              // 來源標籤
              Expanded(
                child: Text(
                  news.source,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // A / B 徽章
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: labelColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: labelColor.withOpacity(0.4)),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 標題
          Text(
            news.title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.4,
              letterSpacing: -0.3,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          // 摘要（選填）
          if (news.summary != null && news.summary!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              news.summary!,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          // 標籤列
          if (news.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: news.tags.take(4).map((tag) => _TagChip(tag: tag)).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

/// 小型標籤徽章
class _TagChip extends StatelessWidget {
  final TagItem tag;
  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tag.name,
        style: const TextStyle(
          color: AppTheme.textMuted,
          fontSize: 11,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
