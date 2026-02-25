/// 魔鬼審計展示區元件
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DevilAuditSection extends StatelessWidget {
  final String audit;
  const DevilAuditSection({super.key, required this.audit});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.dangerLight.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dangerLight.withOpacity(0.25)),
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
                  color: AppTheme.dangerLight.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '\ud83d\udd25 \u9b54\u9b3c\u5be9\u8a08',
                  style: TextStyle(
                    color: AppTheme.dangerLight,
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
              color: AppTheme.textPrimaryLight,
              fontSize: 14,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
