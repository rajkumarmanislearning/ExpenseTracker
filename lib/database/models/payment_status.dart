class PaymentStatus {
  final int id;
  final String type;
  final String name;
  final String? description;

  PaymentStatus({
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

  factory PaymentStatus.fromMap(Map<String, dynamic> map) {
    return PaymentStatus(
      id: map['id'],
      type: map['type'],
      name: map['name'],
      description: map['description'],
    );
  }
}
