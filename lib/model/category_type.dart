class CategoryType {
  final int id;
  final String name;
  final bool isActive;

  CategoryType({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory CategoryType.fromJson(Map<String, dynamic> json) {
    return CategoryType(
      id: json['id'],
      name: json['name'],
      isActive: json['is_active'] ?? true,
    );
  }
}
