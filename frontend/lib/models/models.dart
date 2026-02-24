/// API 資料模型定義

class NewsItem {
  final int id;
  final String title;
  final String link;
  final String? summary;
  final String source;
  final String? publishedAt;
  final List<TagItem> tags;

  const NewsItem({
    required this.id,
    required this.title,
    required this.link,
    this.summary,
    required this.source,
    this.publishedAt,
    this.tags = const [],
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) => NewsItem(
        id: json['id'] as int,
        title: json['title'] as String,
        link: json['link'] as String,
        summary: json['summary'] as String?,
        source: json['source'] as String,
        publishedAt: json['published_at'] as String?,
        tags: (json['tags'] as List<dynamic>? ?? [])
            .map((t) => TagItem.fromJson(t as Map<String, dynamic>))
            .toList(),
      );
}

class TagItem {
  final int id;
  final String name;

  const TagItem({required this.id, required this.name});

  factory TagItem.fromJson(Map<String, dynamic> json) => TagItem(
        id: json['id'] as int,
        name: json['name'] as String,
      );
}

class IdeaItem {
  final int id;
  final String title;
  final String content;
  final String? newsSource1;
  final String? newsSource2;
  final String? devilAudit;
  final String createdAt;

  const IdeaItem({
    required this.id,
    required this.title,
    required this.content,
    this.newsSource1,
    this.newsSource2,
    this.devilAudit,
    required this.createdAt,
  });

  factory IdeaItem.fromJson(Map<String, dynamic> json) => IdeaItem(
        id: json['id'] as int,
        title: json['title'] as String,
        content: json['content'] as String,
        newsSource1: json['news_source_1'] as String?,
        newsSource2: json['news_source_2'] as String?,
        devilAudit: json['devil_audit'] as String?,
        createdAt: json['created_at'] as String,
      );
}

class NewsPair {
  final NewsItem newsA;
  final NewsItem newsB;

  const NewsPair({required this.newsA, required this.newsB});

  factory NewsPair.fromJson(Map<String, dynamic> json) => NewsPair(
        newsA: NewsItem.fromJson(json['news_a'] as Map<String, dynamic>),
        newsB: NewsItem.fromJson(json['news_b'] as Map<String, dynamic>),
      );
}
