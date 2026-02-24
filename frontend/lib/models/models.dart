/// API 資料模型定義
/// 包含 toJson、copyWith、DateTime、== 運算子

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'link': link,
        'summary': summary,
        'source': source,
        'published_at': publishedAt,
        'tags': tags.map((t) => t.toJson()).toList(),
      };

  NewsItem copyWith({
    int? id,
    String? title,
    String? link,
    String? summary,
    String? source,
    String? publishedAt,
    List<TagItem>? tags,
  }) =>
      NewsItem(
        id: id ?? this.id,
        title: title ?? this.title,
        link: link ?? this.link,
        summary: summary ?? this.summary,
        source: source ?? this.source,
        publishedAt: publishedAt ?? this.publishedAt,
        tags: tags ?? this.tags,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewsItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          link == other.link;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ link.hashCode;

  @override
  String toString() => 'NewsItem(id: $id, title: $title, source: $source)';
}

class TagItem {
  final int id;
  final String name;

  const TagItem({required this.id, required this.name});

  factory TagItem.fromJson(Map<String, dynamic> json) => TagItem(
        id: json['id'] as int,
        name: json['name'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  TagItem copyWith({
    int? id,
    String? name,
  }) =>
      TagItem(
        id: id ?? this.id,
        name: name ?? this.name,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'TagItem(id: $id, name: $name)';
}

class IdeaItem {
  final int id;
  final String title;
  final String content;
  final String? newsSource1;
  final String? newsSource2;
  final String? devilAudit;
  final DateTime createdAt;

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
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'news_source_1': newsSource1,
        'news_source_2': newsSource2,
        'devil_audit': devilAudit,
        'created_at': createdAt.toIso8601String(),
      };

  IdeaItem copyWith({
    int? id,
    String? title,
    String? content,
    String? newsSource1,
    String? newsSource2,
    String? devilAudit,
    DateTime? createdAt,
  }) =>
      IdeaItem(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        newsSource1: newsSource1 ?? this.newsSource1,
        newsSource2: newsSource2 ?? this.newsSource2,
        devilAudit: devilAudit ?? this.devilAudit,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdeaItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title;

  @override
  int get hashCode => id.hashCode ^ title.hashCode;

  @override
  String toString() =>
      'IdeaItem(id: $id, title: $title, createdAt: $createdAt)';
}

class NewsPair {
  final NewsItem newsA;
  final NewsItem newsB;

  const NewsPair({required this.newsA, required this.newsB});

  factory NewsPair.fromJson(Map<String, dynamic> json) => NewsPair(
        newsA: NewsItem.fromJson(json['news_a'] as Map<String, dynamic>),
        newsB: NewsItem.fromJson(json['news_b'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'news_a': newsA.toJson(),
        'news_b': newsB.toJson(),
      };

  NewsPair copyWith({
    NewsItem? newsA,
    NewsItem? newsB,
  }) =>
      NewsPair(
        newsA: newsA ?? this.newsA,
        newsB: newsB ?? this.newsB,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewsPair &&
          runtimeType == other.runtimeType &&
          newsA == other.newsA &&
          newsB == other.newsB;

  @override
  int get hashCode => newsA.hashCode ^ newsB.hashCode;

  @override
  String toString() => 'NewsPair(newsA: ${newsA.id}, newsB: ${newsB.id})';
}
