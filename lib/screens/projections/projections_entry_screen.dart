import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/dao/projections_dao.dart';
import '../../database/dao/category_dao.dart';
import '../../database/dao/payment_status_dao.dart';
import '../../main.dart';

class ProjectionsEntryScreen extends StatefulWidget {
  final Map<String, dynamic>? projection;
  const ProjectionsEntryScreen({Key? key, this.projection}) : super(key: key);

  @override
  State<ProjectionsEntryScreen> createState() => _ProjectionsEntryScreenState();
}

class _ProjectionsEntryScreenState extends State<ProjectionsEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProjectionsDao _projectionsDao = ProjectionsDao();
  final CategoryDao _categoryDao = CategoryDao();
  final PaymentStatusDao _paymentStatusDao = PaymentStatusDao();

  late TextEditingController _descriptionController;
  late TextEditingController _remarksController;
  late TextEditingController _projectedAmountController;
  late TextEditingController _amountPaidController;
  DateTime? _projectionDate;
  int? _selectedCategoryId;
  int? _selectedPaymentStatusId;
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _paymentStatuses = [];

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.projection?['description'] ?? '');
    _remarksController = TextEditingController(text: widget.projection?['remarks'] ?? '');
    _projectedAmountController = TextEditingController(text: widget.projection?['projected_amount']?.toString() ?? '');
    _amountPaidController = TextEditingController(text: widget.projection?['amount_paid']?.toString() ?? '');
    _projectionDate = widget.projection?['projection_date'] != null
      ? DateTime.tryParse(widget.projection!['projection_date'])
      : globalMonthController.value;
    _selectedCategoryId = widget.projection?['category_id'];
    _selectedPaymentStatusId = widget.projection?['payment_status_id'];
    _loadCategories();
    _loadPaymentStatuses();
  }

  Future<void> _loadCategories() async {
    final cats = await _categoryDao.getCategoriesByType('projections');
    setState(() {
      _categories = cats;
    });
  }

  Future<void> _loadPaymentStatuses() async {
    final statuses = await _paymentStatusDao.getPaymentStatusesByType('projections');
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

  Future<void> _saveProjection() async {
    if (_formKey.currentState!.validate() && _projectionDate != null) {
      final projection = {
        'id': widget.projection?['id'],
        'category_id': _selectedCategoryId,
        'description': _descriptionController.text,
        'projection_date': DateFormat('yyyy-MM-dd').format(_projectionDate!),
        'projected_amount': double.tryParse(_projectedAmountController.text),
        'amount_paid': double.tryParse(_amountPaidController.text),
        'payment_status_id': _selectedPaymentStatusId,
        'remarks': _remarksController.text,
      };
      if (widget.projection == null) {
        await _projectionsDao.insertProjection(projection);
      } else {
        await _projectionsDao.updateProjection(projection);
      }
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projection == null ? 'Add Projection' : 'Edit Projection'),
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
                title: const Text('Projection Date'),
                subtitle: Text(_projectionDate != null ? DateFormat('yyyy-MM-dd').format(_projectionDate!) : 'Select date'),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _projectionDate ?? globalMonthController.value,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _projectionDate = picked;
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
                onPressed: _saveProjection,
                child: const Text('Save'),
              ),
              if (_projectionDate == null)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text('Please select a projection date', style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
