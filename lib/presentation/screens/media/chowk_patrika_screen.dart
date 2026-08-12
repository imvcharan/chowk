import 'package:flutter/material.dart';
import 'package:e_news/core/theme/app_theme.dart';

class ChowkPatrikaScreen extends StatelessWidget {
  const ChowkPatrikaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _PdfItem(
        title: 'नवीनतम अंक',
        subtitle: 'PDF • 4.2 MB',
        fileName: 'chowk_latest.pdf',
      ),
      _PdfItem(
        title: 'विशेष प्रकाशन',
        subtitle: 'PDF • 6.8 MB',
        fileName: 'special_issue.pdf',
      ),
      _PdfItem(
        title: 'शहर अपडेट',
        subtitle: 'PDF • 2.1 MB',
        fileName: 'city_update.pdf',
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.softWhite,
      appBar: AppBar(
        title: const Text('चौक पत्रिका'),
        elevation: 0,
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.chowkBlack,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
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
                    Icons.picture_as_pdf,
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
                Column(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.visibility_outlined,
                        color: AppTheme.chowkOrange,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.download_outlined,
                        color: AppTheme.chowkOrange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PdfItem {
  final String title;
  final String subtitle;
  final String fileName;

  const _PdfItem({
    required this.title,
    required this.subtitle,
    required this.fileName,
  });
}
