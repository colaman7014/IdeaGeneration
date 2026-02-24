/// 匯出頁面 - Markdown 預覽與複製
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../providers/idea_provider.dart';
import '../theme/app_theme.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  String? _markdownContent;
  bool _isLoading = true;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _loadMarkdown();
  }

  Future<void> _loadMarkdown() async {
    final provider = context.read<IdeaProvider>();
    final content = await provider.exportMarkdown();
    if (mounted) {
      setState(() {
        _markdownContent = content;
        _isLoading = false;
      });
    }
  }

  Future<void> _copyToClipboard() async {
    if (_markdownContent == null) return;
    await Clipboard.setData(ClipboardData(text: _markdownContent!));
    if (!mounted) return;
    setState(() => _copied = true);
    // 2 秒後重置複製狀態
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('匯出'),
        actions: [
          // 複製按鈕
          if (_markdownContent != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: _copied ? null : _copyToClipboard,
                icon: Icon(
                  _copied ? Icons.check_circle_outline : Icons.copy_outlined,
                  size: 18,
                  color: _copied ? AppTheme.secondary : AppTheme.textSecondary,
                ),
                label: Text(
                  _copied ? '已複製！' : '複製',
                  style: TextStyle(
                    color: _copied ? AppTheme.secondary : AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppTheme.primary,
              strokeWidth: 2,
            ),
            SizedBox(height: 16),
            Text(
              '正在產生 Markdown...',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_markdownContent == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppTheme.textMuted,
            ),
            const SizedBox(height: 16),
            const Text(
              '無法產生匯出內容',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                setState(() => _isLoading = true);
                _loadMarkdown();
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('重試'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 提示列
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppTheme.border)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 14,
                color: AppTheme.textMuted,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  '此格式可直接貼入 Obsidian 或任何 Markdown 編輯器',
                  style: TextStyle(
                    color: AppTheme.textMuted,
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
            data: _markdownContent!,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            styleSheet: _buildMarkdownStyleSheet(),
          ),
        ),
        // 底部複製按鈕
        _buildCopyButton(),
      ],
    );
  }

  Widget _buildCopyButton() {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.background,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: ElevatedButton.icon(
        onPressed: _copied ? null : _copyToClipboard,
        icon: Icon(
          _copied ? Icons.check_circle_outline : Icons.copy_outlined,
          size: 18,
        ),
        label: Text(_copied ? '已複製到剪貼板 ✓' : '複製 Markdown'),
        style: _copied
            ? ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondary,
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
        color: AppTheme.textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.3,
      ),
      h2: const TextStyle(
        color: AppTheme.secondary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
      h3: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      p: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 15,
        height: 1.6,
      ),
      listBullet: const TextStyle(
        color: AppTheme.secondary,
        fontSize: 15,
      ),
      blockquoteDecoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        border: const Border(
          left: BorderSide(color: AppTheme.secondary, width: 3),
        ),
      ),
      blockquotePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      code: const TextStyle(
        color: AppTheme.secondary,
        fontSize: 13,
        backgroundColor: Color(0xFF1E2A1E),
        fontFamily: 'monospace',
      ),
      codeblockDecoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      horizontalRuleDecoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppTheme.border),
        ),
      ),
    );
  }
}
