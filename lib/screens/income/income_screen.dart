import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../database/dao/income_dao.dart';
import '../../widgets/app_drawer.dart';

import '../../main.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final IncomeDao _incomeDao = IncomeDao();

  @override
  void initState() {
    super.initState();
    globalMonthController.addListener(_loadIncome);
    _loadIncome();
  }

  @override
  void dispose() {
    globalMonthController.removeListener(_loadIncome);
    super.dispose();
  }

  List<Map<String, dynamic>> _incomeRecords = [];

  void _loadIncome() async {
    final month = DateFormat('yyyy-MM').format(globalMonthController.value);
    final income = await _incomeDao.getIncomeByMonth(month);
    setState(() {
      _incomeRecords = income;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Income'),
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
      body: Column(
        children: [
          _buildMonthPickerBar(),
          Expanded(
            child: ListView.builder(
              itemCount: _incomeRecords.length,
              itemBuilder: (context, index) {
                final record = _incomeRecords[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: const Icon(Icons.attach_money),
                    title: Text(record['description'] ?? 'No Description'),
                    subtitle: Text('Date: ${record['income_date']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            // Open edit dialog
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await _incomeDao.deleteIncome(record['id']);
                            _loadIncome();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open add dialog
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMonthPickerBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            // Navigate to previous month
          },
        ),
        TextButton(
          onPressed: () {
            // Open month picker dialog
          },
          child: const Text('May 2025'), // Replace with actual month
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            // Navigate to next month
          },
        ),
      ],
    );
  }
}
