import 'package:flutter/material.dart';
import 'package:e_news/core/theme/app_theme.dart';
import 'package:e_news/core/utils/safe_network_image.dart';

/// News card widget that shows limited preview for guests
class GuestNewsCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String category;
  final String author;
  final String timeAgo;
  final VoidCallback onViewMore;
  final bool showLimitedPreview;

  const GuestNewsCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.author,
    required this.timeAgo,
    required this.onViewMore,
    this.showLimitedPreview = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: showLimitedPreview ? onViewMore : null,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final hasMaxHeight = constraints.maxHeight.isFinite;
          final imageHeight = hasMaxHeight
              ? (constraints.maxHeight * 0.32).clamp(100.0, 160.0)
              : 200.0;
          final maxDescriptionLines = showLimitedPreview && hasMaxHeight
              ? 1
              : (showLimitedPreview ? 2 : 3);
          final verticalSpacing = hasMaxHeight ? 8.0 : 12.0;

          final contentSection = Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.darkBase,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: verticalSpacing),

                // Description
                Text(
                  description,
                  maxLines: maxDescriptionLines,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.darkBase.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: verticalSpacing),

                // Author and source
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: AppTheme.darkBase.withOpacity(0.5),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        author,
                        style: AppTheme.lightTheme.textTheme.labelSmall
                            ?.copyWith(
                              color: AppTheme.darkBase.withOpacity(0.6),
                            ),
                      ),
                    ),
                  ],
                ),

                if (showLimitedPreview) ...[
                  SizedBox(height: verticalSpacing),
                  // Register CTA button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.primaryRed,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          color: AppTheme.primaryRed,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'पूरी खबर पढ़ने के लिए रजिस्टर करें',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                                color: AppTheme.primaryRed,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.softWhite,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [AppShadows.medium],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Container(
                  height: imageHeight as double,
                  decoration: BoxDecoration(color: Colors.grey[300]),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      SafeNetworkImage(
                        imageUrl: imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      // Overlay
                      if (showLimitedPreview)
                        Container(
                          color: AppTheme.chowkOrange.withOpacity(0.3),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryRed,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock,
                                color: AppTheme.softWhite,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      // Category badge
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryRed,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            category,
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                                  color: AppTheme.softWhite,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                      // Time badge
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.chowkOrange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            timeAgo,
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasMaxHeight)
                  Flexible(child: contentSection)
                else
                  contentSection,
              ],
            ),
          );
        },
      ),
    );
  }
}
