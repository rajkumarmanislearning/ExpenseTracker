import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../database/dao/income_dao.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/month_controller_bar.dart';

import '../../main.dart';
import 'income_entry_screen.dart';

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
    double totalProjected = 0;
    double totalPaid = 0;
    for (final record in _incomeRecords) {
      final projected = record['projected_amount'];
      final paid = record['amount_paid'];
      totalProjected += projected is int ? projected.toDouble() : (projected ?? 0.0);
      totalPaid += paid is int ? paid.toDouble() : (paid ?? 0.0);
    }
    double balance = totalProjected - totalPaid;

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
          MonthControllerBar(
            selectedMonth: globalMonthController.value,
            onMonthChanged: (newMonth) {
              globalMonthController.value = newMonth;
            },
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: globalMonthController.value,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                initialEntryMode: DatePickerEntryMode.calendarOnly,
                helpText: 'Select Month',
                fieldLabelText: 'Month',
                fieldHintText: 'Month/Year',
                selectableDayPredicate: (date) => date.day == 1,
              );
              if (picked != null) {
                globalMonthController.value = DateTime(picked.year, picked.month);
              }
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _incomeRecords.length,
              itemBuilder: (context, index) {
                final record = _incomeRecords[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: ListTile(
                    leading: Icon(Icons.category, color: Colors.teal),
                    title: Text(record['description'] ?? record['category_name'] ?? 'No Description', style: Theme.of(context).textTheme.titleMedium),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${record['income_date'] ?? ''}'),
                        Text('Projected: ${record['projected_amount'] ?? 0}'),
                        Text('Received: ${record['amount_paid'] ?? 0}'),
                        Chip(
                          label: Text('Status: ${record['payment_status_name'] ?? ''}'),
                          backgroundColor: Colors.blue,
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IncomeEntryScreen(income: record),
                              ),
                            );
                            if (result == true) _loadIncome();
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
          Container(
            color: Theme.of(context).colorScheme.surfaceVariant,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Projected: $totalProjected', style: Theme.of(context).textTheme.bodyLarge),
                Text('Total Paid: $totalPaid', style: Theme.of(context).textTheme.bodyLarge),
                Text('Balance: $balance', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const IncomeEntryScreen(),
            ),
          );
          if (result == true) _loadIncome();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
