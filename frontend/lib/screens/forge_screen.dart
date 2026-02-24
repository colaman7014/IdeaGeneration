/// Forge \u9801\u9762 - AI \u9ede\u5b50\u5c55\u793a\u8207\u9b54\u9b3c\u5be9\u8a08
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/idea_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/error_banner.dart';
import '../widgets/idea_title_section.dart';
import '../widgets/idea_content_section.dart';
import '../widgets/sources_section.dart';
import '../widgets/devil_audit_section.dart';
import '../widgets/forge_bottom_actions.dart';
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
          // \u532f\u51fa\u6309\u9215
          Consumer<IdeaProvider>(
            builder: (context, provider, _) {
              return IconButton(
                icon: const Icon(Icons.ios_share_outlined),
                tooltip: '\u532f\u51fa Markdown',
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
                '\u9ede\u5b50\u5c1a\u672a\u751f\u6210',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                // \u4e3b\u8981\u5167\u5bb9\u6372\u52d5\u5340
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        // \u9ede\u5b50\u6a19\u984c
                        IdeaTitleSection(title: idea.title),
                        const SizedBox(height: 20),
                        // \u9ede\u5b50\u5167\u5bb9
                        IdeaContentSection(content: idea.content),
                        const SizedBox(height: 24),
                        // \u4f86\u6e90\u65b0\u805e\u6a19\u7c64
                        if (idea.newsSource1 != null || idea.newsSource2 != null)
                          SourcesSection(
                            source1: idea.newsSource1,
                            source2: idea.newsSource2,
                          ),
                        const SizedBox(height: 24),
                        // \u9b54\u9b3c\u5be9\u8a08\u7d50\u679c\uff08\u82e5\u5df2\u57f7\u884c\uff09
                        if (idea.devilAudit != null)
                          DevilAuditSection(audit: idea.devilAudit!),
                        // \u932f\u8aa4\u8a0a\u606f
                        if (provider.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          ErrorBanner(message: provider.errorMessage!),
                        ],
                        const SizedBox(height: 100), // \u5e95\u90e8 padding
                      ],
                    ),
                  ),
                ),
                // \u5e95\u90e8\u64cd\u4f5c\u5340
                ForgeBottomActions(provider: provider),
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
