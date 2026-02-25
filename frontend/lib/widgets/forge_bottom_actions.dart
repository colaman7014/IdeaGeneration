/// 底部操作列元件
import 'package:flutter/material.dart';
import '../providers/idea_provider.dart';
import '../theme/app_theme.dart';
import '../screens/export_screen.dart';

class ForgeBottomActions extends StatelessWidget {
  final IdeaProvider provider;
  const ForgeBottomActions({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final hasAudit = provider.currentIdea?.devilAudit != null;
    final isAuditing = provider.state == AppState.auditing;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundLight,
        border: Border(top: BorderSide(color: AppTheme.borderLight)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 生成中 Loading 指示器
          if (provider.state == AppState.generating ||
              provider.state == AppState.auditing) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryLight,
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  isAuditing ? '魔鬼正在審問...' : 'AI 正在鍛造點子...',
                  style: const TextStyle(
                    color: AppTheme.textSecondaryLight,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          // 按鈕列
          Row(
            children: [
              // Call the Devil（若已有點子且尚未審計）
              if (!hasAudit)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: provider.isLoading
                        ? null
                        : () => provider.runDevilAudit(),
                    icon: const Icon(Icons.whatshot_outlined, size: 18),
                    label: const Text('Call the Devil'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.dangerLight,
                      side: BorderSide(
                        color: provider.isLoading
                            ? AppTheme.borderLight
                            : AppTheme.dangerLight.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              if (!hasAudit) const SizedBox(width: 12),
              // 匯出
              Expanded(
                flex: hasAudit ? 2 : 1,
                child: ElevatedButton.icon(
                  onPressed: provider.isLoading
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const ExportScreen()),
                          ),
                  icon: const Icon(Icons.ios_share_outlined, size: 18),
                  label: const Text('匯出 Markdown'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
