class UpcomingPayment {
  final int id;
  final int categoryId;
  final String description;
  final String upcomingFromDate;
  final String upcomingToDate;
  final String renewalDate;
  final double projectedAmount;
  final double? amountPaid;
  final int paymentStatusId;
  final String? remarks;

  UpcomingPayment({
    required this.id,
    required this.categoryId,
    required this.description,
    required this.upcomingFromDate,
    required this.upcomingToDate,
    required this.renewalDate,
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
      'upcoming_from_date': upcomingFromDate,
      'upcoming_to_date': upcomingToDate,
      'renewal_date': renewalDate,
      'projected_amount': projectedAmount,
      'amount_paid': amountPaid,
      'payment_status_id': paymentStatusId,
      'remarks': remarks,
    };
  }

  factory UpcomingPayment.fromMap(Map<String, dynamic> map) {
    return UpcomingPayment(
      id: map['id'],
      categoryId: map['category_id'],
      description: map['description'],
      upcomingFromDate: map['upcoming_from_date'],
      upcomingToDate: map['upcoming_to_date'],
      renewalDate: map['renewal_date'],
      projectedAmount: map['projected_amount'],
      amountPaid: map['amount_paid'],
      paymentStatusId: map['payment_status_id'],
      remarks: map['remarks'],
    );
  }
}
