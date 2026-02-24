/// Forge 頁面 - AI 點子展示與魔鬼審計
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/idea_provider.dart';
import '../theme/app_theme.dart';
import 'export_screen.dart';

class ForgeScreen extends StatelessWidget {
  const ForgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forge'),
        leading: BackButton(
          onPressed: () {
            context.read<IdeaProvider>().reset();
            Navigator.of(context).pop();
          },
        ),
        actions: [
          // 匯出按鈕
          Consumer<IdeaProvider>(
            builder: (context, provider, _) {
              return IconButton(
                icon: const Icon(Icons.ios_share_outlined),
                tooltip: '匯出 Markdown',
                onPressed: provider.currentIdea != null
                    ? () => _navigateToExport(context)
                    : null,
              );
            },
          ),
        ],
      ),
      body: Consumer<IdeaProvider>(
        builder: (context, provider, _) {
          final idea = provider.currentIdea;
          if (idea == null) {
            return const Center(
              child: Text(
                '點子尚未生成',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                // 主要內容捲動區
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        // 點子標題
                        _IdeaTitleSection(title: idea.title),
                        const SizedBox(height: 20),
                        // 點子內容
                        _IdeaContentSection(content: idea.content),
                        const SizedBox(height: 24),
                        // 來源新聞標籤
                        if (idea.newsSource1 != null || idea.newsSource2 != null)
                          _SourcesSection(
                            source1: idea.newsSource1,
                            source2: idea.newsSource2,
                          ),
                        const SizedBox(height: 24),
                        // 魔鬼審計結果（若已執行）
                        if (idea.devilAudit != null)
                          _DevilAuditSection(audit: idea.devilAudit!),
                        // 錯誤訊息
                        if (provider.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          _ErrorBanner(message: provider.errorMessage!),
                        ],
                        const SizedBox(height: 100), // 底部 padding
                      ],
                    ),
                  ),
                ),
                // 底部操作區
                _BottomActions(provider: provider),
              ],
            ),
          );
        },
      ),
    );
  }

  void _navigateToExport(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ExportScreen()),
    );
  }
}

/// 點子標題區
class _IdeaTitleSection extends StatelessWidget {
  final String title;
  const _IdeaTitleSection({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            '⚡ AI 生成點子',
            style: TextStyle(
              color: AppTheme.primary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1.25,
            letterSpacing: -0.8,
          ),
        ),
      ],
    );
  }
}

/// 點子內容區（格式化顯示 6 個章節）
class _IdeaContentSection extends StatelessWidget {
  final String content;
  const _IdeaContentSection({required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: _parseAndRenderSections(content),
    );
  }

  Widget _parseAndRenderSections(String content) {
    final lines = content.split('\n');
    final List<Widget> sections = [];
    String currentSection = '';
    String currentTitle = '';
    bool first = true;

    for (final line in lines) {
      if (line.startsWith('## ') || line.startsWith('# ')) {
        // 儲存上一個章節
        if (currentTitle.isNotEmpty && currentSection.trim().isNotEmpty) {
          sections.add(
            _SectionTile(
              title: currentTitle,
              content: currentSection.trim(),
              showDivider: !first,
            ),
          );
          first = false;
        }
        currentTitle = line.replaceAll(RegExp(r'^#+\s*'), '').trim();
        currentSection = '';
      } else if (line.startsWith('**') && line.endsWith('**')) {
        // 粗體標題行也視為章節
        if (currentTitle.isNotEmpty && currentSection.trim().isNotEmpty) {
          sections.add(
            _SectionTile(
              title: currentTitle,
              content: currentSection.trim(),
              showDivider: !first,
            ),
          );
          first = false;
        }
        currentTitle = line.replaceAll(RegExp(r'\*\*'), '').trim();
        currentSection = '';
      } else {
        currentSection += '$line\n';
      }
    }

    // 最後一個章節
    if (currentTitle.isNotEmpty && currentSection.trim().isNotEmpty) {
      sections.add(
        _SectionTile(
          title: currentTitle,
          content: currentSection.trim(),
          showDivider: !first,
        ),
      );
    }

    // 若解析失敗（無 ## 標記），直接顯示純文字
    if (sections.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          content,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 15,
            height: 1.6,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections,
    );
  }
}

/// 單一章節磁貼
class _SectionTile extends StatelessWidget {
  final String title;
  final String content;
  final bool showDivider;
  const _SectionTile({
    required this.title,
    required this.content,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDivider) const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.secondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                content,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 來源新聞標籤
class _SourcesSection extends StatelessWidget {
  final String? source1;
  final String? source2;
  const _SourcesSection({this.source1, this.source2});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '靈感來源',
          style: TextStyle(
            color: AppTheme.textMuted,
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
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.link, size: 12, color: AppTheme.textMuted),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// 魔鬼審計展示區
class _DevilAuditSection extends StatelessWidget {
  final String audit;
  const _DevilAuditSection({required this.audit});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.danger.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.danger.withOpacity(0.25)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 標題列
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.danger.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '🔥 魔鬼審計',
                  style: TextStyle(
                    color: AppTheme.danger,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            audit,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

/// 底部操作列
class _BottomActions extends StatelessWidget {
  final IdeaProvider provider;
  const _BottomActions({required this.provider});

  @override
  Widget build(BuildContext context) {
    final hasAudit = provider.currentIdea?.devilAudit != null;
    final isAuditing = provider.state == AppState.auditing;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.background,
        border: Border(top: BorderSide(color: AppTheme.border)),
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
                    color: AppTheme.primary,
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  isAuditing ? '魔鬼正在審問...' : 'AI 正在鍛造點子...',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
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
                      foregroundColor: AppTheme.danger,
                      side: BorderSide(
                        color: provider.isLoading
                            ? AppTheme.border
                            : AppTheme.danger.withOpacity(0.5),
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

/// 錯誤橫幅
class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.danger, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppTheme.danger, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
