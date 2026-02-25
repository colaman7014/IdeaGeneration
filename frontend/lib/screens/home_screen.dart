/// 首頁 - 新聞 Slot Machine
/// 顯示兩則隨機新聞卡片，提供「重新抽取」與「Forge It」功能
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../providers/idea_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/error_banner.dart';
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
      context.read<NewsProvider>().fetchRandomPair();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IdeaGen'),
        actions: [
          // 顯示 3 分鐘標誌
          const Padding(
            padding: EdgeInsets.only(right: 16),
                child: Center(
              child: Text(
                '3 MIN',
                style: TextStyle(
                  color: AppTheme.primaryLight
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<NewsProvider>(
        builder: (context, newsProvider, _) {
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
                      color: AppTheme.textPrimaryLight,
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
                      color: AppTheme.textSecondaryLight,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 錯誤訊息
                  if (newsProvider.errorMessage != null)
                    ErrorBanner(message: newsProvider.errorMessage!),

                  // 新聞卡片區
                  Expanded(
                    child: _buildNewsArea(context, newsProvider),
                  ),

                  // 底部操作按鈕
                  _buildBottomActions(context, newsProvider),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewsArea(BuildContext context, NewsProvider newsProvider) {
    // 載入中
    if (newsProvider.state == NewsState.loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppTheme.primaryLight,
              strokeWidth: 2,
            ),
            SizedBox(height: 16),
            Text(
              '正在抽取新聞...',
              style: TextStyle(color: AppTheme.textSecondaryLight, fontSize: 14),
            ),
          ],
        ),
      );
    }

    // 空白狀態（首次進入前或錯誤後）
    if (newsProvider.newsPair == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.newspaper_outlined,
              size: 48,
              color: AppTheme.textMutedLight,
            ),
            const SizedBox(height: 16),
            const Text(
              '點擊「重新抽取」開始',
              style: TextStyle(color: AppTheme.textSecondaryLight, fontSize: 15),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => newsProvider.fetchRandomPair(),
              icon: const Icon(Icons.shuffle, size: 18),
              label: const Text('抽取新聞'),
            ),
          ],
        ),
      );
    }

    // 顯示兩則新聞卡片
    final pair = newsProvider.newsPair!;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          NewsCard(
            news: pair.newsA,
            label: 'A',
            labelColor: AppTheme.secondaryLight,
          ),
          const SizedBox(height: 12),
          // 交叉連結符號
          Row(
            children: [
              Expanded(child: Divider(color: AppTheme.borderLight)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceMutedLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 16,
                    color: AppTheme.textMutedLight,
                  ),
                ),
              ),
              Expanded(child: Divider(color: AppTheme.borderLight)),
            ],
          ),
          const SizedBox(height: 12),
          NewsCard(
            news: pair.newsB,
            label: 'B',
            labelColor: AppTheme.primaryLight,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, NewsProvider newsProvider) {
    final hasNews = newsProvider.newsPair != null;
    final ideaProvider = context.read<IdeaProvider>();
    final isLoading = newsProvider.isLoading || ideaProvider.isLoading;

    return Column(
      children: [
        const Divider(height: 1),
        const SizedBox(height: 16),
        Row(
          children: [
            // 重新抽取
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isLoading
                    ? null
                    : () => newsProvider.fetchRandomPair(),
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
                    ? () => _navigateToForge(context, newsProvider)
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
      BuildContext context, NewsProvider newsProvider) async {
    final ideaProvider = context.read<IdeaProvider>();
    // 將新聞對傳遞給 IdeaProvider，然後生成點子
    ideaProvider.setNewsPair(newsProvider.newsPair!);
    await ideaProvider.generateIdea();
    if (!mounted) return;
    if (ideaProvider.currentIdea != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ForgeScreen()),
      );
    }
  }
}
