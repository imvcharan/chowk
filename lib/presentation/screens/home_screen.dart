import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:video_player/video_player.dart';
import '../../services/api_service.dart';
import '../../services/live_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/providers.dart';
import '../widgets/premium_widgets.dart';
import '../widgets/guest_news_card.dart';
import '../widgets/chowk_logo.dart';
import 'live_video_screen.dart';
import '../../core/utils/safe_network_image.dart';
import '../widgets/registration_reminder_dialog.dart';
import '../widgets/auth_modal.dart';
import '../widgets/auth_entry_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentPage = 0;
  String _selectedCategory = 'सभी';
  List<dynamic> _articles = [];
  List<dynamic> _categories = [];
  bool _isHomeLoading = false;

  List<dynamic> _liveUpdates = [];
  Map<String, dynamic>? _primaryLiveStory;
  VideoPlayerController? _liveVideoController;
  Future<void>? _liveVideoInitializeFuture;
  String? _livePreviewError;
  late ScrollController _categoryScrollController;
  late ScrollController _headerCategoryScrollController;
  final GlobalKey _liveUpdatesKey = GlobalKey();
  Timer? _liveTimer;
  Timer? _categoryCarouselTimer;
  bool _hasLiveStream = false;

  final List<String> _fallbackCategories = [
    'राजनीति',
    'खेल',
    'बिजनेस',
    'तकनीक',
    'मनोरंजन',
    'स्वास्थ्य',
    'शिक्षा',
    'विदेश',
    'अपराध',
    'कृषि',
    'पर्यावरण',
  ];

  final List<Map<String, dynamic>> _fallbackFeaturedArticles = [
    {
      'title': 'सरकार ने घोषणा की नई आर्थिक नीति',
      'description':
          'देश की अर्थव्यवस्था को मजबूत करने के लिए केंद्र सरकार ने नई नीति का ऐलान किया है।',
      'category_name': 'राजनीति',
      'author_name': 'Aaj Tak',
      'image_url': 'https://via.placeholder.com/600x400?text=Economy+Update',
      'timeAgo': '5 मिनट पहले',
      'is_featured': true,
    },
    {
      'title': 'क्रिकेट चैंपियनशिप में देश की शानदार जीत',
      'description':
          'भारतीय क्रिकेट टीम ने अंतरराष्ट्रीय चैंपियनशिप में शानदार प्रदर्शन दिखाया।',
      'category_name': 'खेल',
      'author_name': 'Sports Today',
      'image_url': 'https://via.placeholder.com/600x400?text=Cricket+Victory',
      'timeAgo': '15 मिनट पहले',
      'is_featured': true,
    },
  ];

  final List<Map<String, dynamic>> _fallbackArticles = [
    {
      'title': 'शेयर बाजार में तेजी की बयार',
      'description':
          'शेयर बाजार के सूचकांकों में तेजी देखी जा रही है, निवेशकों का भरोसा बना हुआ है।',
      'category_name': 'बिजनेस',
      'author_name': 'Business Daily',
      'image_url': 'https://via.placeholder.com/600x400?text=Stock+Market',
      'timeAgo': '30 मिनट पहले',
    },
    {
      'title': 'बॉलीवुड में नई फिल्म की घोषणा',
      'description':
          'प्रसिद्ध निर्माता ने तीन नई फिल्मों की घोषणा की है, इनमें एक बड़े बजट की फिल्म भी शामिल है।',
      'category_name': 'मनोरंजन',
      'author_name': 'Bollywood Times',
      'image_url': 'https://via.placeholder.com/600x400?text=Bollywood+Announcement',
      'timeAgo': '45 मिनट पहले',
    },
    {
      'title': 'पर्यावरण सुरक्षा के लिए नई पहल',
      'description':
          'सरकार ने पर्यावरण संरक्षण के लिए एक बड़ी पहल की शुरुआत की है।',
      'category_name': 'राजनीति',
      'author_name': 'News India',
      'image_url': 'https://via.placeholder.com/600x400?text=Environment+Initiative',
      'timeAgo': '1 घंटे पहले',
    },
  ];

  List<String> get categories {
    final backendCategories = _categories
        .map((item) => item['name']?.toString())
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .toList();

    if (backendCategories.isNotEmpty) {
      return ['सभी', ...backendCategories];
    }

    return ['सभी', ..._fallbackCategories];
  }

  List<dynamic> get featuredNews {
    final featured = _articles.where((item) => item['is_featured'] == true).toList();
    if (featured.isNotEmpty) {
      return featured;
    }
    return _fallbackFeaturedArticles;
  }

  List<dynamic> get newsList {
    final selected = _selectedCategory;
    final backendItems = selected == 'सभी'
        ? _articles
        : _articles.where((item) => item['category_name']?.toString() == selected).toList();

    if (backendItems.isNotEmpty) {
      return backendItems;
    }

    final fallbackItems = selected == 'सभी'
        ? _fallbackArticles
        : _fallbackArticles.where((item) => item['category_name']?.toString() == selected).toList();
    return fallbackItems;
  }

  final List<Map<String, String>> _liveStories = [
    {
      'label': 'LIVE',
      'title': 'दिल्ली में भारी बारिश, फ्लाइट और मेट्रो सेवाएं प्रभावित',
      'description':
          'मौसम विभाग ने अगले 12 घंटों में और बारिश की चेतावनी जारी की।',
      'tag': 'मौसम',
      'timeAgo': 'अब',
    },
    {
      'title': 'बिहार में किसानों की महापंचायत का बड़ा ऐलान',
      'description':
          'किसान संगठनों ने राष्ट्रीय राजमार्ग पर विरोध प्रदर्शन की तैयारी शुरू कर दी है।',
      'tag': 'कृषि',
      'timeAgo': '12 मिनट पहले',
    },
    {
      'title': 'चर्चा में नया IPL सत्र, पिछली टीमों के बड़े दांव',
      'description':
          'टीमों ने नए खिलाड़ियों के साथ स्पेशल स्ट्रैटजी की घोषणा की है।',
      'tag': 'खेल',
      'timeAgo': '25 मिनट पहले',
    },
    {
      'title': 'सिनेमाघरों में रिलीज़ हुई ब्लॉकबस्टर फिल्म',
      'description': 'पहले दिन की कमाई ने बॉक्स ऑफिस पर रिकॉर्ड तोड़ दिया।',
      'tag': 'मनोरंजन',
      'timeAgo': '35 मिनट पहले',
    },
  ];

  final List<Map<String, String>> _marketNewsItems = [
    {
      'label': 'LIVE',
      'title':
          'चंद्रशेखर 40 घंटे से संसद के बाहर धरने पर बैठे: अखिलेश काली जैकेट पहनकर पहुंचे',
      'location': 'उत्तरप्रदेश',
      'duration': '1:03',
      'image': 'https://via.placeholder.com/200x140?text=Live+Video+1',
    },
    {
      'label': 'LIVE',
      'title':
          'बागपत में त्रिपुरा DGP के शव से लिपटकर रोई पत्नी; मां ने गाल सहलाकर दुलारा',
      'location': 'उत्तरप्रदेश',
      'duration': '1:14',
      'image': 'https://via.placeholder.com/200x140?text=Live+Video+2',
    },
    {
      'title':
          'मॉर्निंग न्यूज ब्रिफ: राहुल-अखिलेश को पुलिस ने धरने से उठाया; जज बोले- चढ़ावा चोरी के दोषियों को मौत की सजा होनी चाहिए',
      'location': 'उत्तरप्रदेश',
      'duration': '3:25',
      'image': 'https://via.placeholder.com/200x140?text=News+Brief',
    },
  ];

  final List<Map<String, String>> _initialLiveUpdates = [
    {
      'title': 'दिल्ली में सोमवार को भारी बारिश के कारण यातायात प्रभावित',
      'updated_at': '1 मिनट पहले',
    },
    {
      'title': 'सरकार ने पेट्रोल-डीजल पर नया टैक्स प्रस्ताव पेश किया',
      'updated_at': '5 मिनट पहले',
    },
    {
      'title': 'क्रिकेट टीम के कप्तान ने आगामी टेस्ट सीरीज़ की घोषणा की',
      'updated_at': '8 मिनट पहले',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _animationController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();

    _categoryScrollController = ScrollController();
    _headerCategoryScrollController = ScrollController();
    _categoryCarouselTimer = Timer.periodic(
      const Duration(milliseconds: 2500),
      (_) => _autoScrollCategoryCarousel(),
    );

    _liveUpdates = List<dynamic>.from(_initialLiveUpdates);
    _setPrimaryLiveStory(_liveStories.first);
    // Fetch initial data and start polling (fallback)
    _loadHomeContent();
    _fetchLiveUpdates();
    _fetchLiveStreams();
    _liveTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) {
        _fetchLiveUpdates();
        _fetchLiveStreams();
      },
    );

    // Initialize LiveService to receive realtime updates from the Pusher-backed backend.
    // If the app key is not configured, the service falls back to the polling endpoint.
    LiveService.instance.init().then((_) {
      if (!mounted) return;
      LiveService.instance.stream.listen((update) {
        if (!mounted) return;
        setState(() {
          final parsed = LiveService.instance.parseIncomingUpdate(update);
          _liveUpdates.insert(0, parsed);
          if (_liveUpdates.length > 100) _liveUpdates = _liveUpdates.sublist(0, 100);
          if (!_hasLiveStream) _setPrimaryLiveStory(parsed);
        });
      });
    });

    // Auto scroll featured news once the first frame is rendered and
    // when the PageController is attached to a PageView.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_pageController.hasClients && featuredNews.isNotEmpty) {
        _pageController.animateToPage(
          (_currentPage + 1) % featuredNews.length,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _categoryScrollController.dispose();
    _headerCategoryScrollController.dispose();
    _liveTimer?.cancel();
    _categoryCarouselTimer?.cancel();
    _disposeLiveVideoController();
    LiveService.instance.dispose();
    super.dispose();
  }

  Future<void> _loadHomeContent() async {
    if (!mounted) return;
    setState(() => _isHomeLoading = true);

    try {
      final newsResponse = await ApiService.getAllNews(limit: 10);
      final categoriesResponse = await ApiService.getCategories();

      if (!mounted) return;
      final newsData = newsResponse['data'];
      setState(() {
        _articles = List<dynamic>.from(newsData is List ? newsData : []);
        _categories = List<dynamic>.from(categoriesResponse);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _articles = [];
        _categories = [];
      });
    } finally {
      if (mounted) setState(() => _isHomeLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final isGuest = !authProvider.isLoggedIn;

        return Scaffold(
          backgroundColor: AppTheme.kagazWhite,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(
              MediaQuery.of(context).padding.top + 120,
            ),
            child: SafeArea(
              top: true,
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPremiumAppBar(),
                  SizedBox(
                    height: 50,
                    child: _buildHeaderCategoryScroller(),
                  ),
                ],
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NOTE: guest banner removed to match Bhaskar layout; live report shown immediately

                  // Live story block like Dainik Bhaskar homepage (show immediately below header)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: _buildLiveStoryBlock(context),
                  ),

                  // Live updates strip (scrolling headlines)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: _buildLiveUpdatesStrip(context),
                  ),

                  // Market ticker card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildMarketTicker(),
                  ),

                  // Market highlights + videos grid
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    child: _buildMarketNewsSection(),
                  ),

                  const SizedBox(height: 24),

                  // Category Filter
                  _buildCategoryFilter(),
                  const SizedBox(height: 20),

                  // News List Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'सभी खबरें',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Icon(Icons.trending_up, color: AppTheme.primaryRed),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // News List
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: _isHomeLoading
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: newsList.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final news = newsList[index];
                              final title = news['title']?.toString() ?? '';
                              final description = news['description']?.toString() ?? '';
                              final imageUrl = news['image_url']?.toString() ?? '';
                              final category = news['category_name']?.toString() ?? 'अन्य';
                              final author = news['author_name']?.toString() ?? 'अज्ञात';
                              final timeAgo = _formatDisplayTime(news['timeAgo'] ?? news['created_at']);

                              if (isGuest) {
                                return GuestNewsCard(
                                  title: title,
                                  description: description,
                                  imageUrl: imageUrl.isNotEmpty ? imageUrl : 'https://via.placeholder.com/600x400?text=News',
                                  category: category,
                                  author: author,
                                  timeAgo: timeAgo.isEmpty ? 'अभी' : timeAgo,
                                  showLimitedPreview: true,
                                  onViewMore: () {
                                    showRegistrationReminder(
                                      context,
                                      onRegisterPressed: () {
                                        Navigator.of(context).pop();
                                        showAuthModal(context);
                                      },
                                      onLoginPressed: () {
                                        Navigator.of(context).pop();
                                        showAuthModal(context);
                                      },
                                    );
                                  },
                                );
                              }

                              return PremiumNewsCard(
                                imageUrl: imageUrl.isNotEmpty ? imageUrl : 'https://via.placeholder.com/600x400?text=News',
                                title: title,
                                description: description,
                                source: author,
                                timeAgo: timeAgo.isEmpty ? 'अभी' : timeAgo,
                                category: category,
                                onTap: () {},
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 20),

                  // Load More Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.more_horiz),
                        label: const Text('और खबरें लोड करें'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildGuestBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryRed.withOpacity(0.9),
            AppTheme.primaryRed.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppShadows.medium],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.star_outline,
                color: AppTheme.softWhite,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'प्रीमियम सदस्य बने',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.softWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'सभी खबरों तक तुरंत पहुंचें, बुकमार्क करें और वैयक्तिकृत अनुभव प्राप्त करें',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.softWhite.withOpacity(0.9),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    showAuthModal(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.softWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'रजिस्टर करें',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.primaryRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    showAuthModal(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.softWhite, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'लॉगिन करें',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.softWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumAppBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.secondaryBorder.withOpacity(0.8),
            width: 1,
          ),
        ),
        boxShadow: AppShadows.smallList,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ChowkLogo(
              size: 16,
              spacing: 4,
              textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
                color: AppTheme.chowkBlack.withOpacity(0.92),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 38,
                    minHeight: 38,
                  ),
                  icon: const Icon(Icons.search, size: 20),
                  color: AppTheme.mutedText,
                ),
                const SizedBox(width: 4),
                const AuthEntryButton(),
                const SizedBox(width: 4),
                Stack(
                  children: [
                    IconButton(
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 38,
                        minHeight: 38,
                      ),
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        size: 20,
                      ),
                      color: AppTheme.chowkOrange,
                    ),
                    Positioned(
                      top: 7,
                      right: 7,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.chowkOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCarousel() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final isGuest = !authProvider.isLoggedIn;
        final featuredItems = featuredNews;

        if (featuredItems.isEmpty) {
          return const SizedBox(height: 340, child: Center(child: Text('No featured articles yet.')));
        }

        return SizedBox(
          height: 340,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: featuredItems.length,
            itemBuilder: (context, index) {
              final item = featuredItems[index];
              final title = item['title']?.toString() ?? '';
              final description = item['description']?.toString() ?? '';
              final imageUrl = item['image_url']?.toString() ?? '';
              final category = item['category_name']?.toString() ?? 'अन्य';
              final author = item['author_name']?.toString() ?? 'अज्ञात';
                              final timeAgo = _formatDisplayTime(item['timeAgo'] ?? item['created_at']);
                        onTap: () {
                          showRegistrationReminder(
                            context,
                            onRegisterPressed: () {
                              Navigator.of(context).pop();
                              showAuthModal(context);
                            },
                            onLoginPressed: () {
                              Navigator.of(context).pop();
                              showAuthModal(context);
                            },
                          );
                        },
                        child: GuestNewsCard(
                          imageUrl: imageUrl.isNotEmpty ? imageUrl : 'https://via.placeholder.com/600x400?text=News',
                          title: title,
                          description: description,
                          category: category,
                          author: author,
                          timeAgo: timeAgo,
                          showLimitedPreview: true,
                          onViewMore: () {
                            showRegistrationReminder(
                              context,
                              onRegisterPressed: () {
                                Navigator.of(context).pop();
                                showAuthModal(context);
                              },
                              onLoginPressed: () {
                                Navigator.of(context).pop();
                                showAuthModal(context);
                              },
                            );
                          },
                        ),
                      )
                    : PremiumNewsCard(
                        imageUrl: imageUrl.isNotEmpty ? imageUrl : 'https://via.placeholder.com/600x400?text=News',
                        title: title,
                        description: description,
                        source: author,
                        timeAgo: timeAgo,
                        category: category,
                        isFeatured: true,
                        onTap: () {},
                      ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatDisplayTime(Object? value) {
    if (value == null) {
      return 'अभी';
    }

    final asString = value.toString();
    if (asString.isEmpty) {
      return 'अभी';
    }

    final parsed = DateTime.tryParse(asString);
    if (parsed == null) {
      return asString;
    }

    final difference = DateTime.now().difference(parsed);
    if (difference.inDays > 0) {
      return '${difference.inDays} दिन पहले';
    }
    if (difference.inHours > 0) {
      return '${difference.inHours} घंटे पहले';
    }
    if (difference.inMinutes > 0) {
      return '${difference.inMinutes} मिनट पहले';
    }

    return 'अभी';
  }

  void _autoScrollCategoryCarousel() {
    if (!_categoryScrollController.hasClients || categories.isEmpty) return;

    final controller = _categoryScrollController;
    final maxExtent = controller.position.maxScrollExtent;
    final currentOffset = controller.offset;
    final scrollBy = 120.0;
    final targetOffset = (currentOffset + scrollBy).clamp(0.0, maxExtent);

    if (currentOffset >= maxExtent - 10) {
      controller.animateTo(
        0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    } else {
      controller.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  void _setPrimaryLiveStory(Map<String, dynamic> story) {
    final rawVideoUrl = story['video_url'] ?? story['videoUrl'] ?? '';
    final videoUrl = rawVideoUrl?.toString().trim() ?? '';

    setState(() {
      _primaryLiveStory = story;
    });

    if (videoUrl.isNotEmpty) {
      _initializeLiveVideoController(videoUrl);
    } else {
      _disposeLiveVideoController();
    }
  }

  Future<void> _initializeLiveVideoController(String url) async {
    _disposeLiveVideoController();

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _liveVideoController = controller;
    _liveVideoInitializeFuture = controller.initialize();

    try {
      await _liveVideoInitializeFuture;
      if (mounted && _liveVideoController == controller) {
        controller.setLooping(true);
        _livePreviewError = null;
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        _livePreviewError = 'Live preview failed: ${e.toString()}';
        _disposeLiveVideoController();
        setState(() {});
      }
    }
  }

  void _disposeLiveVideoController() {
    _liveVideoInitializeFuture = null;
    _liveVideoController?.dispose();
    _liveVideoController = null;
  }

  bool get _hasActiveLiveVideo {
    if (!_hasLiveStream) return false;
    final rawVideoUrl = _primaryLiveStory?['video_url'] ?? _primaryLiveStory?['videoUrl'] ?? '';
    final videoUrl = rawVideoUrl?.toString().trim() ?? '';
    return videoUrl.isNotEmpty;
  }

  Widget _buildLiveStoryMedia(Map<String, dynamic> story) {
    final rawVideoUrl = story['video_url'] ?? story['videoUrl'] ?? '';
    final videoUrl = rawVideoUrl?.toString().trim() ?? '';
    final rawImageUrl = story['image_url'] ?? story['imageUrl'] ?? '';
    final imageUrl = rawImageUrl?.toString().trim() ?? '';

    Widget media;
    if (videoUrl.isNotEmpty && _liveVideoController != null) {
      media = FutureBuilder<void>(
        future: _liveVideoInitializeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              _liveVideoController?.value.isInitialized == true) {
            return VideoPlayer(_liveVideoController!);
          }

          return Container(
            color: AppTheme.mediumGray.withOpacity(0.12),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppTheme.chowkOrange),
              ),
            ),
          );
        },
      );
    } else if (imageUrl.isNotEmpty) {
      media = SafeNetworkImage(
        imageUrl: imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      media = Container(
        color: AppTheme.mediumGray.withOpacity(0.12),
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: AppTheme.mutedText,
            size: 48,
          ),
        ),
      );
    }

    return Stack(
      children: [
        media,
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppTheme.chowkBlack.withOpacity(0.38),
                ],
              ),
            ),
          ),
        ),
        if (_livePreviewError != null && !_hasActiveLiveVideo)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.chowkBlack.withOpacity(0.72),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Preview unavailable',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _livePreviewError!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightGray,
                          height: 1.4,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLiveStoryPlayIcon(Map<String, dynamic> story) {
    final rawVideoUrl = story['video_url'] ?? story['videoUrl'] ?? '';
    final videoUrl = rawVideoUrl?.toString().trim() ?? '';
    if (videoUrl.isEmpty || _liveVideoController == null || !_hasLiveStream) {
      return const SizedBox.shrink();
    }

    final isPlaying = _liveVideoController?.value.isPlaying ?? false;
    return GestureDetector(
      onTap: () {
        if (_liveVideoController == null) return;
        setState(() {
          if (_liveVideoController!.value.isPlaying) {
            _liveVideoController!.pause();
          } else {
            _liveVideoController!.play();
          }
        });
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: AppTheme.chowkBlack.withOpacity(0.65),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.chowkBlack.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 36,
        ),
      ),
    );
  }

  void _openLiveVideoScreen(Map<String, dynamic> story) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LiveVideoScreen(story: story),
      ),
    );
  }

  // Fetch live updates from API
  Future<void> _fetchLiveStreams() async {
    try {
      final streams = await ApiService.getLiveStreams();
      if (!mounted) return;
      _hasLiveStream = streams.isNotEmpty;
      if (streams.isNotEmpty) {
        final stream = streams.first;
        _setPrimaryLiveStory({
          'title': stream['title'] ?? 'Live stream',
          'body': stream['description'] ?? '',
          'videoUrl': stream['playbackUrl'] ?? '',
          'timeAgo': 'LIVE NOW',
          'label': 'LIVE',
        });
      }
    } catch (_) {
      // Live reports remain available when the stream service is offline.
    }
  }

  Future<void> _fetchLiveUpdates() async {
    try {
      final data = await ApiService.getLiveUpdates(limit: 20);
      if (mounted) setState(() {
        _liveUpdates = data;
        if (_liveUpdates.isNotEmpty && !_hasLiveStream) {
          _setPrimaryLiveStory(_liveUpdates.first as Map<String, dynamic>);
        }
      });
    } catch (e) {
      // fallback: keep existing headlines
      if (mounted)
        setState(
          () => _liveUpdates = [
            {
              'updated_at': '1 मिनट पहले',
              'title': 'सोनम वांगचुक के अनशन की टाइमलाइन...',
            },
            {
              'updated_at': '13 मिनट पहले',
              'title':
                  'दिल्ली में सुरक्षा व्यवस्था के कारण 16 मेट्रो स्टेशन बंद',
            },
          ],
        );
    }
  }

  Widget _buildHeaderCategoryScroller() {
    return RawScrollbar(
      controller: _headerCategoryScrollController,
      thumbVisibility: true,
      trackVisibility: false,
      thickness: 3,
      radius: const Radius.circular(6),
      thumbColor: AppTheme.chowkOrange.withOpacity(0.95),
      child: SingleChildScrollView(
        controller: _headerCategoryScrollController,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: PremiumCategoryChip(
                label: category,
                isSelected: _selectedCategory == category,
                onTap: () {
                  setState(() => _selectedCategory = category);
                },
                icon: _headerCategoryIcon(category),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _headerCategoryIcon(String category) {
    switch (category) {
      case 'सभी':
        return Icons.apps;
      case 'राजनीति':
        return Icons.account_balance;
      case 'खेल':
        return Icons.sports_cricket;
      case 'बिजनेस':
        return Icons.trending_up;
      case 'तकनीक':
        return Icons.devices;
      case 'मनोरंजन':
        return Icons.movie;
      case 'स्वास्थ्य':
        return Icons.local_hospital;
      case 'शिक्षा':
        return Icons.school;
      case 'विदेश':
        return Icons.public;
      case 'अपराध':
        return Icons.gavel;
      case 'कृषि':
        return Icons.eco;
      case 'पर्यावरण':
        return Icons.nature;
      default:
        return Icons.category;
    }
  }

  Widget _buildLiveUpdatesStrip(BuildContext context) {
    final updates = _liveUpdates.isNotEmpty
        ? _liveUpdates
        : [
            {
              'title': 'सोनम वांगचुक के अनशन की टाइमलाइन...',
              'updated_at': '1 मिनट पहले',
            },
            {
              'title':
                  'दिल्ली में सुरक्षा व्यवस्था के कारण 16 मेट्रो स्टेशन बंद',
              'updated_at': '13 मिनट पहले',
            },
          ];

    return Container(
      key: _liveUpdatesKey,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.mediumGray),
        boxShadow: AppShadows.smallList,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.chowkOrange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: updates.length,
                separatorBuilder: (_, __) => const SizedBox(width: 24),
                itemBuilder: (context, index) {
                  final update = updates[index];
                  final time =
                      update['updated_at'] ?? update['created_at'] ?? 'अब';
                  final title = update['title'] ?? update['description'] ?? '';
                  return Row(
                    children: [
                      Text(
                        time,
                        style: const TextStyle(
                          color: AppTheme.chowkOrange,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.mutedText),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'सभी देखें',
              style: TextStyle(
                color: AppTheme.chowkOrange,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _marketNewsItems.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.secondaryBorder),
            boxShadow: [
              BoxShadow(
                color: AppTheme.chowkBlack.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item['label'] != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.chowkOrange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item['label']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        Text(
                          item['title'] ?? '',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                height: 1.3,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              constraints: const BoxConstraints(maxWidth: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppTheme.chowkOrange, width: 1.2),
                              ),
                              child: Text(
                                item['location'] ?? 'उत्तरप्रदेश',
                                style: const TextStyle(
                                  color: AppTheme.chowkOrange,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            Container(
                              constraints: const BoxConstraints(minWidth: 60, maxWidth: 90),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.chowkOrange.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                item['duration'] ?? '0:00',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppTheme.chowkOrange,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 100,
                          color: AppTheme.mediumGray.withOpacity(0.15),
                          child: SafeNetworkImage(
                            imageUrl:
                                item['image'] ??
                                'https://via.placeholder.com/200x140',
                            width: 120,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.chowkOrange.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.chowkOrange.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              item['duration'] ?? '0:00',
                              style: const TextStyle(
                                color: AppTheme.chowkOrange,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.chowkOrange.withOpacity(0.95),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['location'] ?? 'उत्तरप्रदेश',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: const [
                      Icon(Icons.share, size: 18, color: AppTheme.chowkBlack),
                      SizedBox(width: 12),
                      Icon(
                        Icons.more_vert,
                        size: 18,
                        color: AppTheme.chowkBlack,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMarketTicker() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.smallList,
        border: Border.all(color: AppTheme.secondaryBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'आज का बाजार',
                style: TextStyle(
                  color: AppTheme.chowkBlack,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  Text(
                    '22 जुलाई, 11:50 AM',
                    style: TextStyle(
                      color: AppTheme.mutedText.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.chowkOrange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Market items horizontally scrollable
          const SizedBox(height: 8),
          Builder(builder: (context) {
            final marketItems = [
              {
                'label': 'सेंसेक्स',
                'value': '76,901.63',
                'change': '-568.48 (0.73%)',
              },
              {
                'label': 'निफ्टी',
                'value': '23,456.78',
                'change': '+128.50 (0.55%)',
              },
              {
                'label': 'बैंक',
                'value': '34,567.89',
                'change': '-45.60 (0.13%)',
              },
            ];

            return SizedBox(
              height: 112,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: marketItems.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = marketItems[index];
                  final change = item['change'] ?? '';
                  final isNegative = change.trim().startsWith('-');
                  final changeColor = isNegative ? AppTheme.primaryRed : AppTheme.accentGreen;

                  return Container(
                    width: 210,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.secondaryBorder),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['label'] ?? '',
                            style: TextStyle(color: AppTheme.mutedText)),
                        const SizedBox(height: 8),
                        Text(item['value'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(item['change'] ?? '',
                            style: TextStyle(
                                color: changeColor, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  );
                },
              ),
            );
          }),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _marketPill('टॉप गेन्स', () {}),
                const SizedBox(width: 8),
                _marketPill('टॉप लूजर्स', () {}),
                const SizedBox(width: 8),
                _marketPill('शेयर सर्च', () {}),
                const SizedBox(width: 8),
                _marketPill('IPO अपडेट', () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _marketPill(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildLiveStoryBlock(BuildContext context) {
    final mainStory = _primaryLiveStory ?? _liveStories.first;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.mediumList,
        border: Border.all(color: AppTheme.secondaryBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.chowkBlack,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.chowkOrange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.fiber_manual_record,
                        color: Colors.white,
                        size: 10,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'LIVE NOW',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    mainStory['title'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: _buildLiveStoryMedia(mainStory),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.chowkBlack.withOpacity(0.72),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.fiber_manual_record,
                                color: Colors.red,
                                size: 10,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'LIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: _buildLiveStoryPlayIcon(mainStory),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _hasActiveLiveVideo ? () => _openLiveVideoScreen(mainStory) : null,
                    icon: const Icon(Icons.play_circle_outline),
                    label: Text(_hasActiveLiveVideo ? 'Watch Live' : 'No active stream'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _hasActiveLiveVideo ? AppTheme.chowkOrange : AppTheme.lightGray,
                      foregroundColor: _hasActiveLiveVideo ? Colors.white : AppTheme.mutedText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                if (!_hasActiveLiveVideo)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.lightGray.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'No active live stream available right now. Check back soon or view the latest updates.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.mutedText,
                                height: 1.5,
                              ),
                        ),
                      ),
                      if (_livePreviewError != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppTheme.chowkBlack.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _livePreviewError!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.chowkBlack,
                                  height: 1.5,
                                ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () {
                            final context = _liveUpdatesKey.currentContext;
                            if (context != null) {
                              Scrollable.ensureVisible(
                                context,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.chowkOrange,
                            side: const BorderSide(color: AppTheme.chowkOrange),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('View live updates'),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      if (mainStory['viewers'] != null) ...[
                        const Icon(Icons.remove_red_eye, size: 18, color: AppTheme.chowkBlack),
                        const SizedBox(width: 6),
                        Text(
                          '${mainStory['viewers']} watching',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.chowkBlack,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(width: 18),
                      ],
                      if (mainStory['tag'] != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.lightGray,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            mainStory['tag']!.toString(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.chowkBlack,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ],
                  ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.kagazWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.secondaryBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'लाइव अपडेट्स',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Row(
                            children: const [
                              Icon(
                                Icons.share,
                                size: 18,
                                color: AppTheme.chowkBlack,
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.more_vert,
                                size: 18,
                                color: AppTheme.chowkBlack,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: _liveUpdates.take(2).map((update) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.chowkOrange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    update['title'] ?? '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppTheme.chowkBlack,
                                          height: 1.5,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  update['updated_at'] ?? '',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: AppTheme.mutedText),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const Divider(
                        height: 1.5,
                        thickness: 1,
                        color: AppTheme.secondaryBorder,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'और देखें',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppTheme.chowkOrange,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          Text(
                            'शेयर करें',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppTheme.chowkBlack,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final doubledCategories = [...categories, ...categories, ...categories];
    return SizedBox(
      height: 50,
      child: SingleChildScrollView(
        controller: _categoryScrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: doubledCategories.map((category) {
              final isSelected = _selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: PremiumCategoryChip(
                  label: category,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() => _selectedCategory = category);
                  },
                  icon: category == 'सभी' ? Icons.apps : null,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
