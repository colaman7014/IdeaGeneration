/// 匯出頁面 - Markdown 預覽與複製
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../providers/idea_provider.dart';
import '../providers/export_provider.dart';
import '../theme/app_theme.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    // 透過 ExportProvider 載入 Markdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ideaProvider = context.read<IdeaProvider>();
      if (ideaProvider.currentIdea != null) {
        context.read<ExportProvider>().loadMarkdown(ideaProvider.currentIdea!.id);
      }
    });
  }

  Future<void> _copyToClipboard(String content) async {
    await Clipboard.setData(ClipboardData(text: content));
    if (!mounted) return;
    setState(() => _copied = true);
    // 2 秒後重置複製狀態
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExportProvider>(
      builder: (context, exportProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('匯出'),
            actions: [
              // 複製按鈕
              if (exportProvider.markdownContent != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton.icon(
                    onPressed: _copied
                        ? null
                        : () => _copyToClipboard(exportProvider.markdownContent!),
                    icon: Icon(
                      _copied ? Icons.check_circle_outline : Icons.copy_outlined,
                      size: 18,
                      color: _copied ? AppTheme.secondaryLight : AppTheme.textSecondaryLight
                    ),
                    label: Text(
                      _copied ? '已複製！' : '複製',
                      style: TextStyle(
                        color: _copied ? AppTheme.secondaryLight : AppTheme.textSecondaryLight,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: SafeArea(
            child: _buildBody(exportProvider),
          ),
        );
      },
    );
  }

  Widget _buildBody(ExportProvider exportProvider) {
    if (exportProvider.isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppTheme.primaryLight,
              strokeWidth: 2,
            ),
            const SizedBox(height: 16),
            const Text(
              '正在產生 Markdown...',
              style: TextStyle(color: AppTheme.textSecondaryLight, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (exportProvider.markdownContent == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppTheme.textMutedLight,
            ),
            const SizedBox(height: 16),
            Text(
              exportProvider.errorMessage ?? '無法產生匯出內容',
              style: const TextStyle(color: AppTheme.textSecondaryLight, fontSize: 15),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                final ideaProvider = context.read<IdeaProvider>();
                if (ideaProvider.currentIdea != null) {
                  exportProvider.loadMarkdown(ideaProvider.currentIdea!.id);
                }
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('重試'),
            ),
          ],
        ),
      );
    }

    final content = exportProvider.markdownContent!;
    return Column(
      children: [
        // 提示列
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppTheme.borderLight)),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 14,
                color: AppTheme.textMutedLight,
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  '此格式可直接貼入 Obsidian 或任何 Markdown 編輯器',
                  style: TextStyle(
                    color: AppTheme.textMutedLight,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Markdown 渲染預覽
        Expanded(
          child: Markdown(
            data: content,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            styleSheet: _buildMarkdownStyleSheet(),
          ),
        ),
        // 底部複製按鈕
        _buildCopyButton(content),
      ],
    );
  }

  Widget _buildCopyButton(String content) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundLight,
        border: Border(top: BorderSide(color: AppTheme.borderLight)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: ElevatedButton.icon(
        onPressed: _copied ? null : () => _copyToClipboard(content),
        icon: Icon(
          _copied ? Icons.check_circle_outline : Icons.copy_outlined,
          size: 18,
        ),
        label: Text(_copied ? '已複製到剪貼板 ✓' : '複製 Markdown'),
        style: _copied
            ? ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryLight,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              )
            : null,
      ),
    );
  }

  MarkdownStyleSheet _buildMarkdownStyleSheet() {
    return MarkdownStyleSheet(
      h1: const TextStyle(
        color: AppTheme.textPrimaryLight,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.3,
      ),
      h2: const TextStyle(
        color: AppTheme.secondaryLight,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
      h3: const TextStyle(
        color: AppTheme.textPrimaryLight,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      p: const TextStyle(
        color: AppTheme.textPrimaryLight,
        fontSize: 15,
        height: 1.6,
      ),
      listBullet: const TextStyle(
        color: AppTheme.secondaryLight,
        fontSize: 15,
      ),
      blockquoteDecoration: BoxDecoration(
        color: AppTheme.surfaceMutedLight,
        border: const Border(
          left: BorderSide(color: AppTheme.secondaryLight, width: 3),
        ),
      ),
      blockquotePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      code: const TextStyle(
        color: AppTheme.secondaryLight,
        fontSize: 13,
        backgroundColor: Color(0xFFF5F3F0),
        fontFamily: 'monospace',
      ),
      codeblockDecoration: BoxDecoration(
        color: AppTheme.surfaceMutedLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderLight),
      ),
      horizontalRuleDecoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppTheme.borderLight),
        ),
      ),
    );
  }
}
