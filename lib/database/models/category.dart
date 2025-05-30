class Category {
  final int id;
  final String type;
  final String name;
  final String? description;

  Category({
    required this.id,
    required this.type,
    required this.name,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'description': description,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      type: map['type'],
      name: map['name'],
      description: map['description'],
    );
  }
}
