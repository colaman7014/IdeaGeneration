/// 點子標題區元件
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class IdeaTitleSection extends StatelessWidget {
  final String title;
  const IdeaTitleSection({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            '\u26a1 AI \u751f\u6210\u9ede\u5b50',
            style: TextStyle(
              color: AppTheme.primaryLight,
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
            color: AppTheme.textPrimaryLight,
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
