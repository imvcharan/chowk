import 'package:flutter/material.dart';
import 'package:e_news/core/theme/app_theme.dart';

class PodcastScreen extends StatelessWidget {
  const PodcastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final podcasts = [
      _PodcastItem(title: 'चौक शाम की बात', subtitle: '20 मिनट • नई एपिसोड'),
      _PodcastItem(
        title: 'राजनीति की सरल समझ',
        subtitle: '15 मिनट • आज की विशेष बातचीत',
      ),
      _PodcastItem(title: 'बिजनेस ब्रीफिंग', subtitle: '12 मिनट • बाजार अपडेट'),
    ];

    return Scaffold(
      backgroundColor: AppTheme.softWhite,
      appBar: AppBar(
        title: const Text('पॉडकास्ट'),
        elevation: 0,
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.chowkBlack,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: podcasts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = podcasts[index];
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
                    Icons.podcasts,
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
                const Icon(Icons.play_arrow, color: AppTheme.chowkOrange),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PodcastItem {
  final String title;
  final String subtitle;

  const _PodcastItem({required this.title, required this.subtitle});
}
