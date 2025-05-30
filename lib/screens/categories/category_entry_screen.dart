import 'package:flutter/material.dart';
import '../../database/dao/category_dao.dart';

class CategoryEntryScreen extends StatefulWidget {
  final Map<String, dynamic>? category;

  const CategoryEntryScreen({super.key, this.category});

  @override
  State<CategoryEntryScreen> createState() => _CategoryEntryScreenState();
}

class _CategoryEntryScreenState extends State<CategoryEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final CategoryDao _categoryDao = CategoryDao();

  String? _selectedType;
  String? _name;
  String? _description;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _selectedType = widget.category!['type'];
      _name = widget.category!['name'];
      _description = widget.category!['description'];
    }
  }

  void _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final category = {
        'type': _selectedType,
        'name': _name,
        'description': _description,
      };

      if (widget.category == null) {
        await _categoryDao.insertCategory(category);
      } else {
        category['id'] = widget.category!['id'];
        await _categoryDao.updateCategory(category);
      }

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
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
                decoration: const InputDecoration(labelText: 'Category Type'),
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
                onPressed: _saveCategory,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
