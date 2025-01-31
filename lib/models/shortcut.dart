class Shortcut {
  final String key;
  final String url;
  final String description;

  Shortcut({
    required this.key,
    required this.url,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'key': key,
        'url': url,
        'description': description,
      };

  factory Shortcut.fromJson(Map<String, dynamic> json) => Shortcut(
        key: json['key'],
        url: json['url'],
        description: json['description'],
      );
}
