import 'package:flutter/material.dart';
import '../../database/dao/payment_status_dao.dart';

class PaymentStatusEntryScreen extends StatefulWidget {
  final Map<String, dynamic>? status;

  const PaymentStatusEntryScreen({super.key, this.status});

  @override
  State<PaymentStatusEntryScreen> createState() => _PaymentStatusEntryScreenState();
}

class _PaymentStatusEntryScreenState extends State<PaymentStatusEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final PaymentStatusDao _paymentStatusDao = PaymentStatusDao();

  String? _selectedType;
  String? _name;
  String? _description;

  @override
  void initState() {
    super.initState();
    if (widget.status != null) {
      _selectedType = widget.status!['type'];
      _name = widget.status!['name'];
      _description = widget.status!['description'];
    }
  }

  void _savePaymentStatus() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final status = {
        'type': _selectedType,
        'name': _name,
        'description': _description,
      };

      if (widget.status == null) {
        await _paymentStatusDao.insertPaymentStatus(status);
      } else {
        status['id'] = widget.status!['id'];
        await _paymentStatusDao.updatePaymentStatus(status);
      }

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.status == null ? 'Add Payment Status' : 'Edit Payment Status'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: const [
                  DropdownMenuItem(value: 'income', child: Text('Income')),
                  DropdownMenuItem(value: 'projections', child: Text('Projections')),
                  DropdownMenuItem(value: 'upcoming', child: Text('Upcoming')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Type'),
                validator: (value) => value == null ? 'Please select a type' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Name is required' : null,
                onSaved: (value) => _name = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (value) => _description = value,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _savePaymentStatus,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
