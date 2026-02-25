/// 點子內容區元件（格式化顯示 6 個章節）
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class IdeaContentSection extends StatelessWidget {
  final String content;
  const IdeaContentSection({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
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
        currentSection += '${line}\n';
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
            color: AppTheme.textPrimaryLight,
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
                  color: AppTheme.secondaryLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                content,
                style: const TextStyle(
                  color: AppTheme.textPrimaryLight,
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
