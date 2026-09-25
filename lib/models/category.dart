import 'package:html_unescape/html_unescape.dart';

class Category {
  const Category({required this.id, required this.name});

  final int id;
  final String name;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: HtmlUnescape().convert(json['name'] as String),
    );
  }

  /// "Entertainment: Books" -> "Books", "Science & Nature" stays as is.
  /// (The Figma cards show the short form.)
  String get displayName {
    final index = name.indexOf(': ');
    return index == -1 ? name : name.substring(index + 2);
  }
}
