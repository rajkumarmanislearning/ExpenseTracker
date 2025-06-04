import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/dao/income_dao.dart';
import '../../database/dao/category_dao.dart';
import '../../database/dao/payment_status_dao.dart';
import '../../main.dart';

class IncomeEntryScreen extends StatefulWidget {
  final Map<String, dynamic>? income;

  const IncomeEntryScreen({super.key, this.income});

  @override
  State<IncomeEntryScreen> createState() => _IncomeEntryScreenState();
}

class _IncomeEntryScreenState extends State<IncomeEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final IncomeDao _incomeDao = IncomeDao();
  final CategoryDao _categoryDao = CategoryDao();
  final PaymentStatusDao _paymentStatusDao = PaymentStatusDao();

  late TextEditingController _descriptionController;
  late TextEditingController _remarksController;
  late TextEditingController _projectedAmountController;
  late TextEditingController _amountPaidController;
  DateTime? _incomeDate;
  int? _selectedCategoryId;
  int? _selectedPaymentStatusId;
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _paymentStatuses = [];

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.income?['description'] ?? '');
    _remarksController = TextEditingController(text: widget.income?['remarks'] ?? '');
    _projectedAmountController = TextEditingController(text: widget.income?['projected_amount']?.toString() ?? '');
    _amountPaidController = TextEditingController(text: widget.income?['amount_paid']?.toString() ?? '');
    _incomeDate = widget.income?['income_date'] != null
      ? DateTime.tryParse(widget.income!['income_date'])
      : globalMonthController.value;
    _selectedCategoryId = widget.income?['category_id'];
    _selectedPaymentStatusId = widget.income?['payment_status_id'];
    _loadCategories();
    _loadPaymentStatuses();
  }

  Future<void> _loadCategories() async {
    final cats = await _categoryDao.getCategoriesByType('income');
    setState(() {
      _categories = cats;
    });
  }

  Future<void> _loadPaymentStatuses() async {
    final statuses = await _paymentStatusDao.getPaymentStatusesByType('income');
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

  Future<void> _saveIncome() async {
    if (_formKey.currentState!.validate() && _incomeDate != null) {
      final income = {
        'id': widget.income?['id'],
        'category_id': _selectedCategoryId,
        'description': _descriptionController.text,
        'income_date': DateFormat('yyyy-MM-dd').format(_incomeDate!),
        'projected_amount': double.tryParse(_projectedAmountController.text),
        'amount_paid': double.tryParse(_amountPaidController.text),
        'payment_status_id': _selectedPaymentStatusId,
        'remarks': _remarksController.text,
      };

      if (widget.income == null) {
        await _incomeDao.insertIncome(income);
      } else {
        await _incomeDao.updateIncome(income);
      }

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.income == null ? 'Add Income' : 'Edit Income'),
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
                decoration: InputDecoration(
                  labelText: 'Category',
                  filled: true,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
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
                decoration: InputDecoration(
                  labelText: 'Description',
                  filled: true,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              TextFormField(
                controller: _remarksController,
                decoration: const InputDecoration(labelText: 'Remarks'),
              ),
              ListTile(
                title: const Text('Income Date'),
                subtitle: Text(_incomeDate != null ? DateFormat('yyyy-MM-dd').format(_incomeDate!) : 'Select date'),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _incomeDate ?? globalMonthController.value,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _incomeDate = picked;
                      });
                    }
                  },
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _saveIncome,
                child: const Text('Save'),
              ),
              if (_incomeDate == null)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text('Please select an income date', style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
