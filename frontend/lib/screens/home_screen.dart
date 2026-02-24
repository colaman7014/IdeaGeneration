/// 首頁 - 新聞 Slot Machine
/// 顯示兩則隨機新聞卡片，提供「重新抽取」與「Forge It」功能
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/idea_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/news_card.dart';
import 'forge_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 首次進入自動抽取新聞
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IdeaProvider>().fetchRandomPair();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IdeaGen'),
        actions: [
          // 顯示新聞總數徽章（可擴充）
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '3 MIN',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<IdeaProvider>(
        builder: (context, provider, _) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // 標題區
                  const Text(
                    '今天有什麼\n商機在等你？',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '從兩則新聞中，讓 AI 為你挖掘商業洞察',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 錯誤訊息
                  if (provider.errorMessage != null)
                    _ErrorBanner(message: provider.errorMessage!),

                  // 新聞卡片區
                  Expanded(
                    child: _buildNewsArea(context, provider),
                  ),

                  // 底部操作按鈕
                  _buildBottomActions(context, provider),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewsArea(BuildContext context, IdeaProvider provider) {
    // 載入中
    if (provider.state == AppState.loadingNews) {
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
              '正在抽取新聞...',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    // 空白狀態（首次進入前或錯誤後）
    if (provider.newsPair == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.newspaper_outlined,
              size: 48,
              color: AppTheme.textMuted,
            ),
            const SizedBox(height: 16),
            const Text(
              '點擊「重新抽取」開始',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => provider.fetchRandomPair(),
              icon: const Icon(Icons.shuffle, size: 18),
              label: const Text('抽取新聞'),
            ),
          ],
        ),
      );
    }

    // 顯示兩則新聞卡片
    final pair = provider.newsPair!;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          NewsCard(
            news: pair.newsA,
            label: 'A',
            labelColor: AppTheme.secondary,
          ),
          const SizedBox(height: 12),
          // 交叉連結符號
          Row(
            children: [
              Expanded(child: Divider(color: AppTheme.border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 16,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
              Expanded(child: Divider(color: AppTheme.border)),
            ],
          ),
          const SizedBox(height: 12),
          NewsCard(
            news: pair.newsB,
            label: 'B',
            labelColor: AppTheme.primary,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, IdeaProvider provider) {
    final hasNews = provider.newsPair != null;
    final isLoading = provider.isLoading;

    return Column(
      children: [
        const Divider(height: 1),
        const SizedBox(height: 16),
        Row(
          children: [
            // 重新抽取
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : () => provider.fetchRandomPair(),
                icon: const Icon(Icons.shuffle, size: 18),
                label: const Text('重新抽取'),
              ),
            ),
            const SizedBox(width: 12),
            // Forge It — 生成點子
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: (hasNews && !isLoading)
                    ? () => _navigateToForge(context, provider)
                    : null,
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Forge It ⚡'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _navigateToForge(
      BuildContext context, IdeaProvider provider) async {
    await provider.generateIdea();
    if (!mounted) return;
    if (provider.currentIdea != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ForgeScreen()),
      );
    }
  }
}

/// 錯誤橫幅
class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              style: const TextStyle(
                color: AppTheme.danger,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
