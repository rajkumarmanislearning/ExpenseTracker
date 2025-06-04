import 'package:flutter/material.dart';
import '../../database/dao/category_dao.dart';
import '../../widgets/app_drawer.dart';
import 'category_entry_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final CategoryDao _categoryDao = CategoryDao();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  List<Map<String, dynamic>> _categories = [];

  void _loadCategories() async {
    final categories = await _categoryDao.getAllCategories();
    setState(() {
      _categories = categories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushNamed(context, '/');
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: ListTile(
                    leading: Icon(Icons.category, color: Colors.deepPurple),
                    title: Text(category['name'], style: Theme.of(context).textTheme.titleMedium),
                    subtitle: Text(category['description'] ?? ''),
                    trailing: Chip(
                      label: Text(category['type']),
                      backgroundColor: category['type'] == 'income' ? Colors.green : (category['type'] == 'projections' ? Colors.blue : Colors.orange),
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      // Optionally open edit
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CategoryEntryScreen(),
            ),
          );
          if (result == true) {
            _loadCategories();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
