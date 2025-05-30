class Income {
  final int id;
  final int categoryId;
  final String description;
  final String incomeDate;
  final double projectedAmount;
  final double? amountPaid;
  final int paymentStatusId;
  final String? remarks;

  Income({
    required this.id,
    required this.categoryId,
    required this.description,
    required this.incomeDate,
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
      'income_date': incomeDate,
      'projected_amount': projectedAmount,
      'amount_paid': amountPaid,
      'payment_status_id': paymentStatusId,
      'remarks': remarks,
    };
  }

  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'],
      categoryId: map['category_id'],
      description: map['description'],
      incomeDate: map['income_date'],
      projectedAmount: map['projected_amount'],
      amountPaid: map['amount_paid'],
      paymentStatusId: map['payment_status_id'],
      remarks: map['remarks'],
    );
  }
}
