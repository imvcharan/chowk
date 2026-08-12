class MockData {
  static List<Map<String, dynamic>> featuredNews() {
    return [
      {
        'id': 1,
        'title': 'मॉक: सरकार ने नई योजना की घोषणा की',
        'slug': 'mock-govt-plan',
        'description': 'यह एक मॉक समाचार विवरण है।',
        'image': 'https://via.placeholder.com/600x400?text=Mock+Featured+1',
        'timeAgo': '5 मिनट पहले',
        'category': 'राजनीति',
        'source': 'Mock Source',
      },
      {
        'id': 2,
        'title': 'मॉक: खेल टीम ने शानदार प्रदर्शन किया',
        'slug': 'mock-sports',
        'description': 'मॉक स्पोर्ट्स न्यूज़',
        'image': 'https://via.placeholder.com/600x400?text=Mock+Featured+2',
        'timeAgo': '15 मिनट पहले',
        'category': 'खेल',
        'source': 'Mock Sports',
      },
    ];
  }

  static List<Map<String, dynamic>> trendingNews() {
    return [
      {'title': 'चुनाव अपडेट'},
      {'title': 'बढ़ती महंगाई'},
      {'title': 'IPL हॉटस्टार'},
    ];
  }

  static List<Map<String, dynamic>> liveUpdates() {
    return [
      {'title': 'दिल्ली में भारी बारिश', 'updated_at': 'अब'},
      {'title': 'नयी आर्थिक नीति का ऐलान', 'updated_at': '5 मिनट पहले'},
      {'title': 'क्रिकेट में नया अपडेट', 'updated_at': '10 मिनट पहले'},
    ];
  }

  static Map<String, dynamic> allNews({int page = 1, int limit = 20}) {
    final items = List.generate(limit, (i) {
      final id = (page - 1) * limit + i + 1;
      return {
        'id': id,
        'title': 'मॉक समाचार #$id',
        'slug': 'mock-news-$id',
        'description': 'यह मॉक समाचार का सार है।',
        'image': 'https://via.placeholder.com/600x400?text=News+$id',
        'timeAgo': '${i + 1} घंटे पहले',
        'category': 'लोकल',
        'source': 'Mock Agency',
      };
    });

    return {'data': items, 'meta': {'page': page, 'limit': limit}};
  }
}
