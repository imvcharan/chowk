class NewsModel {
  final int id;
  final String title;
  final String description;
  final String content;
  final String imageUrl;
  final String source;
  final String category;
  final String author;
  final DateTime publishedAt;
  final String slug;
  final bool isFeatured;

  NewsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.imageUrl,
    required this.source,
    required this.category,
    required this.author,
    required this.publishedAt,
    required this.slug,
    this.isFeatured = false,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['image_url'] ?? 'https://via.placeholder.com/400x300?text=News',
      source: json['source'] ?? 'Aaj Tak',
      category: json['category'] ?? 'अन्य',
      author: json['author'] ?? 'अज्ञात',
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'])
          : DateTime.now(),
      slug: json['slug'] ?? '',
      isFeatured: json['is_featured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'image_url': imageUrl,
      'source': source,
      'category': category,
      'author': author,
      'published_at': publishedAt.toIso8601String(),
      'slug': slug,
      'is_featured': isFeatured,
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);

    if (difference.inMinutes < 1) {
      return 'अभी';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} मिनट पहले';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} घंटे पहले';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} दिन पहले';
    } else {
      return publishedAt.toString().split(' ')[0];
    }
  }
}
