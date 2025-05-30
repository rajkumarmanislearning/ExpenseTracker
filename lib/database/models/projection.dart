class Projection {
  final int id;
  final int categoryId;
  final String description;
  final String projectionDate;
  final double projectedAmount;
  final double? amountPaid;
  final int paymentStatusId;
  final String? remarks;

  Projection({
    required this.id,
    required this.categoryId,
    required this.description,
    required this.projectionDate,
    required this.projectedAmount,
    this.amountPaid,
    required this.paymentStatusId,
    this.remarks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'description': description,
      'projection_date': projectionDate,
      'projected_amount': projectedAmount,
      'amount_paid': amountPaid,
      'payment_status_id': paymentStatusId,
      'remarks': remarks,
    };
  }

  factory Projection.fromMap(Map<String, dynamic> map) {
    return Projection(
      id: map['id'],
      categoryId: map['category_id'],
      description: map['description'],
      projectionDate: map['projection_date'],
      projectedAmount: map['projected_amount'],
      amountPaid: map['amount_paid'],
      paymentStatusId: map['payment_status_id'],
      remarks: map['remarks'],
    );
  }
}
