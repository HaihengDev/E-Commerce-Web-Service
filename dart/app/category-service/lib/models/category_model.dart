class Category {
  final String category_id;
  final String category_name;
  final String? description;

  const Category({
    required this.category_id,
    required this.category_name,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'category_id': category_id,
    'category_name': category_name,
    'description': description,
  };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    category_id: json['category_id'] as String,
    category_name: json['category_name'] as String,
    description: json['description'] as String?,
  );
}
