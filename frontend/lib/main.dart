/// App 入口點 - IdeaGeneration
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/idea_provider.dart';
import 'providers/news_provider.dart';
import 'providers/export_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const IdeaGenerationApp());
}

class IdeaGenerationApp extends StatelessWidget {
  const IdeaGenerationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => IdeaProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => ExportProvider()),
      ],
      child: MaterialApp(
        title: 'IdeaGen',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const HomeScreen(),
      ),
    );
  }
}
