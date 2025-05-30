import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/dao/upcoming_payments_dao.dart';
import '../../database/dao/category_dao.dart';
import '../../database/dao/payment_status_dao.dart';
import '../../main.dart';

class UpcomingPaymentsEntryScreen extends StatefulWidget {
  final Map<String, dynamic>? payment;
  const UpcomingPaymentsEntryScreen({Key? key, this.payment}) : super(key: key);

  @override
  State<UpcomingPaymentsEntryScreen> createState() => _UpcomingPaymentsEntryScreenState();
}

class _UpcomingPaymentsEntryScreenState extends State<UpcomingPaymentsEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final UpcomingPaymentsDao _upcomingPaymentsDao = UpcomingPaymentsDao();
  final CategoryDao _categoryDao = CategoryDao();
  final PaymentStatusDao _paymentStatusDao = PaymentStatusDao();

  late TextEditingController _descriptionController;
  late TextEditingController _remarksController;
  late TextEditingController _projectedAmountController;
  late TextEditingController _amountPaidController;
  DateTime? _upcomingFromDate;
  DateTime? _upcomingToDate;
  DateTime? _renewalDate;
  int? _selectedCategoryId;
  int? _selectedPaymentStatusId;
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _paymentStatuses = [];

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.payment?['description'] ?? '');
    _remarksController = TextEditingController(text: widget.payment?['remarks'] ?? '');
    _projectedAmountController = TextEditingController(text: widget.payment?['projected_amount']?.toString() ?? '');
    _amountPaidController = TextEditingController(text: widget.payment?['amount_paid']?.toString() ?? '');
    _upcomingFromDate = widget.payment?['upcoming_from_date'] != null
      ? DateTime.tryParse(widget.payment!['upcoming_from_date'])
      : globalMonthController.value;
    _upcomingToDate = widget.payment?['upcoming_to_date'] != null
      ? DateTime.tryParse(widget.payment!['upcoming_to_date'])
      : globalMonthController.value;
    _renewalDate = widget.payment?['renewal_date'] != null
      ? DateTime.tryParse(widget.payment!['renewal_date'])
      : globalMonthController.value;
    _selectedCategoryId = widget.payment?['category_id'];
    _selectedPaymentStatusId = widget.payment?['payment_status_id'];
    _loadCategories();
    _loadPaymentStatuses();
  }

  Future<void> _loadCategories() async {
    final cats = await _categoryDao.getCategoriesByType('upcoming');
    setState(() {
      _categories = cats;
    });
  }

  Future<void> _loadPaymentStatuses() async {
    final statuses = await _paymentStatusDao.getPaymentStatusesByType('upcoming');
    setState(() {
      _paymentStatuses = statuses;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _remarksController.dispose();
    _projectedAmountController.dispose();
    _amountPaidController.dispose();
    super.dispose();
  }

  Future<void> _savePayment() async {
    if (_formKey.currentState!.validate() && _upcomingFromDate != null && _upcomingToDate != null && _renewalDate != null) {
      final payment = {
        'id': widget.payment?['id'],
        'category_id': _selectedCategoryId,
        'description': _descriptionController.text,
        'upcoming_from_date': DateFormat('yyyy-MM-dd').format(_upcomingFromDate!),
        'upcoming_to_date': DateFormat('yyyy-MM-dd').format(_upcomingToDate!),
        'renewal_date': DateFormat('yyyy-MM-dd').format(_renewalDate!),
        'projected_amount': double.tryParse(_projectedAmountController.text),
        'amount_paid': double.tryParse(_amountPaidController.text),
        'payment_status_id': _selectedPaymentStatusId,
        'remarks': _remarksController.text,
      };
      if (widget.payment == null) {
        await _upcomingPaymentsDao.insertUpcomingPayment(payment);
      } else {
        await _upcomingPaymentsDao.updateUpcomingPayment(payment);
      }
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.payment == null ? 'Add Upcoming Payment' : 'Edit Upcoming Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                items: _categories.map((cat) => DropdownMenuItem<int>(
                  value: cat['id'],
                  child: Text(cat['name']),
                )).toList(),
                onChanged: (value) => setState(() => _selectedCategoryId = value),
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              TextFormField(
                controller: _projectedAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Projected Amount'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a projected amount' : null,
              ),
              TextFormField(
                controller: _amountPaidController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount Paid'),
              ),
              DropdownButtonFormField<int>(
                value: _selectedPaymentStatusId,
                items: _paymentStatuses.map((status) => DropdownMenuItem<int>(
                  value: status['id'],
                  child: Text(status['name']),
                )).toList(),
                onChanged: (value) => setState(() => _selectedPaymentStatusId = value),
                decoration: const InputDecoration(labelText: 'Payment Status'),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: _remarksController,
                decoration: const InputDecoration(labelText: 'Remarks'),
              ),
              ListTile(
                title: const Text('Upcoming From Date'),
                subtitle: Text(_upcomingFromDate != null ? DateFormat('yyyy-MM-dd').format(_upcomingFromDate!) : 'Select date'),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _upcomingFromDate ?? globalMonthController.value,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _upcomingFromDate = picked;
                      });
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('Upcoming To Date'),
                subtitle: Text(_upcomingToDate != null ? DateFormat('yyyy-MM-dd').format(_upcomingToDate!) : 'Select date'),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _upcomingToDate ?? globalMonthController.value,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _upcomingToDate = picked;
                      });
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('Renewal Date'),
                subtitle: Text(_renewalDate != null ? DateFormat('yyyy-MM-dd').format(_renewalDate!) : 'Select date'),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _renewalDate ?? globalMonthController.value,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _renewalDate = picked;
                      });
                    }
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _savePayment,
                child: const Text('Save'),
              ),
              if (_upcomingFromDate == null || _upcomingToDate == null || _renewalDate == null)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text('Please select all dates', style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
