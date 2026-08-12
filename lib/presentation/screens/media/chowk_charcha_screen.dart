import 'package:flutter/material.dart';
import 'package:e_news/core/theme/app_theme.dart';

class ChowkCharchaScreen extends StatelessWidget {
  const ChowkCharchaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final discussions = [
      _DiscussionCard(
        title: 'लोकल मुद्दों पर चर्चा',
        subtitle: 'आज की बड़ी बातें • 12 भाग',
      ),
      _DiscussionCard(
        title: 'सरकारी नीतियों पर विशेषज्ञ विचार',
        subtitle: 'एक्सपर्ट बातचीत • 8 भाग',
      ),
      _DiscussionCard(
        title: 'समाज और संस्कृति',
        subtitle: 'सामुदायिक संवाद • 6 भाग',
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.softWhite,
      appBar: AppBar(
        title: const Text('चौक चर्चा'),
        elevation: 0,
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.chowkBlack,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: discussions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = discussions[index];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.mediumGray),
              boxShadow: AppShadows.smallList,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.lightRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: AppTheme.chowkOrange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.chowkBlack,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTheme.chowkOrange,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DiscussionCard {
  final String title;
  final String subtitle;

  const _DiscussionCard({required this.title, required this.subtitle});
}
