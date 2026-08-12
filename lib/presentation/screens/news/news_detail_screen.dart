import 'package:flutter/material.dart';
import 'package:e_news/core/theme/app_theme.dart';
import 'package:e_news/core/utils/safe_network_image.dart';
import 'package:e_news/presentation/widgets/premium_widgets.dart';
import 'package:e_news/services/tts_service.dart';

class NewsDetailScreen extends StatefulWidget {
  final String title;
  final String content;
  final String imageUrl;
  final String source;
  final String category;
  final String publishedTime;
  final String author;

  const NewsDetailScreen({
    super.key,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.source,
    required this.category,
    required this.publishedTime,
    required this.author,
  });

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isBookmarked = false;
  bool _isLiked = false;
  bool _isSpeaking = false;
  final _tts = TtsService.instance;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    // Initialize TTS and handlers
    _tts.setHandlers(
      onStart: () => setState(() => _isSpeaking = true),
      onComplete: () => setState(() => _isSpeaking = false),
      onError: (msg) {
        setState(() => _isSpeaking = false);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('TTS error: $msg')));
        }
      },
    );
    _tts.init();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softWhite,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Premium App Bar with Image
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.white,
                shape: BoxShape.circle,
                boxShadow: AppShadows.mediumList,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.darkBase),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            actions: [
              // Play/Pause TTS button
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.mediumList,
                ),
                child: IconButton(
                  icon: Icon(
                    _isSpeaking ? Icons.pause : Icons.play_arrow,
                    color: AppTheme.darkBase,
                  ),
                  onPressed: () async {
                    if (_isSpeaking) {
                      await _tts.stop();
                      setState(() => _isSpeaking = false);
                      return;
                    }

                    final textToSpeak = '${widget.title}. ${widget.content}';
                    try {
                      await _tts.speak(textToSpeak);
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('TTS failed: $e')),
                        );
                      }
                    }
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.mediumList,
                ),
                child: IconButton(
                  icon: Icon(Icons.share, color: AppTheme.darkBase),
                  onPressed: _shareNews,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  SafeNetworkImage(
                    imageUrl: widget.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryRed,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Container(
              color: AppTheme.softWhite,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.title,
                    style: Theme.of(
                      context,
                    ).textTheme.displayMedium?.copyWith(height: 1.3),
                  ),
                  const SizedBox(height: 16),

                  // Meta Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.mediumGray),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMetaRow(Icons.newspaper, 'स्रोत', widget.source),
                        const SizedBox(height: 12),
                        _buildMetaRow(Icons.person, 'लेखक', widget.author),
                        const SizedBox(height: 12),
                        _buildMetaRow(
                          Icons.schedule,
                          'प्रकाशित',
                          widget.publishedTime,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      _buildActionButton(
                        icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                        label: 'पसंद',
                        onTap: () => setState(() => _isLiked = !_isLiked),
                        isActive: _isLiked,
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        icon: _isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        label: 'सहेजें',
                        onTap: () =>
                            setState(() => _isBookmarked = !_isBookmarked),
                        isActive: _isBookmarked,
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        icon: Icons.share,
                        label: 'साझा करें',
                        onTap: _shareNews,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  PremiumDivider(padding: EdgeInsets.zero),
                  const SizedBox(height: 20),

                  // Article Content
                  Text(
                    'संपूर्ण लेख',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.content,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.darkBase,
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Related News Section
                  Text(
                    'संबंधित खबरें',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _buildRelatedNewsCard(
                    'सरकार ने नई घोषणा की',
                    'राजनीति',
                    '30 मिनट पहले',
                  ),
                  const SizedBox(height: 12),
                  _buildRelatedNewsCard(
                    'अर्थव्यवस्था में सुधार',
                    'बिजनेस',
                    '1 घंटे पहले',
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryRed),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.lightText,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.darkBase,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.lightRed : AppTheme.white,
            border: Border.all(
              color: isActive ? AppTheme.primaryRed : AppTheme.mediumGray,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isActive ? AppTheme.primaryRed : AppTheme.mutedText,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isActive ? AppTheme.primaryRed : AppTheme.mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRelatedNewsCard(String title, String category, String time) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.mediumGray),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const SafeNetworkImage(
              imageUrl: 'https://via.placeholder.com/100x100?text=News',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.lightRed,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryRed,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkBase,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.lightText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _shareNews() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('समाचार साझा किए जा रहे हैं...'),
        backgroundColor: AppTheme.accentBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
