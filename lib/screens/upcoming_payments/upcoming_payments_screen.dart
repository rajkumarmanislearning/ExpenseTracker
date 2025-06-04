import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../database/dao/upcoming_payments_dao.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/month_controller_bar.dart';

import '../../main.dart';
import 'upcoming_payments_entry_screen.dart';

class UpcomingPaymentsScreen extends StatefulWidget {
  const UpcomingPaymentsScreen({super.key});

  @override
  State<UpcomingPaymentsScreen> createState() => _UpcomingPaymentsScreenState();
}

class _UpcomingPaymentsScreenState extends State<UpcomingPaymentsScreen> {
  final UpcomingPaymentsDao _upcomingPaymentsDao = UpcomingPaymentsDao();

  @override
  void initState() {
    super.initState();
    globalMonthController.addListener(_loadUpcomingPayments);
    _loadUpcomingPayments();
  }

  @override
  void dispose() {
    globalMonthController.removeListener(_loadUpcomingPayments);
    super.dispose();
  }

  List<Map<String, dynamic>> _upcomingPaymentsRecords = [];

  void _loadUpcomingPayments() async {
    final month = DateFormat('yyyy-MM').format(globalMonthController.value);
    final payments = await _upcomingPaymentsDao.getUpcomingPaymentsByMonth(month);
    setState(() {
      _upcomingPaymentsRecords = payments;
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalProjected = 0;
    double totalPaid = 0;
    for (final record in _upcomingPaymentsRecords) {
      final projected = record['projected_amount'];
      final paid = record['amount_paid'];
      totalProjected += projected is int ? projected.toDouble() : (projected ?? 0.0);
      totalPaid += paid is int ? paid.toDouble() : (paid ?? 0.0);
    }
    double balance = totalProjected - totalPaid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Payments'),
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
            onMonthChanged: (date) {
              globalMonthController.value = date;
            },
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: globalMonthController.value,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                globalMonthController.value = picked;
              }
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _upcomingPaymentsRecords.length,
              itemBuilder: (context, index) {
                final record = _upcomingPaymentsRecords[index];
                final now = DateTime.now();
                final fromDate = record['upcoming_from_date'] != null ? DateTime.tryParse(record['upcoming_from_date']) : null;
                Color cardColor = Colors.green;
                int daysToGo = 0;
                if (fromDate != null) {
                  daysToGo = fromDate.difference(now).inDays;
                  if (daysToGo < 0) {
                    cardColor = Colors.red;
                  } else if (daysToGo == 0) {
                    cardColor = Colors.yellow;
                  }
                }
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: cardColor.withOpacity(0.2),
                  child: ListTile(
                    leading: Icon(Icons.category, color: Colors.teal),
                    title: Text(record['category_name'] ?? 'No Category', style: Theme.of(context).textTheme.titleMedium),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Description: ${record['description'] ?? ''}'),
                        Text('From: ${record['upcoming_from_date'] ?? ''}'),
                        Text('To: ${record['upcoming_to_date'] ?? ''}'),
                        Text('Renewal: ${record['renewal_date'] ?? ''}'),
                        Text('Projected: ${record['projected_amount'] ?? 0}'),
                        Text('Paid: ${record['amount_paid'] ?? 0}'),
                        Chip(
                          label: Text('Status: ${record['payment_status_name'] ?? ''}'),
                          backgroundColor: cardColor,
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                        Chip(
                          label: Text('Days to Go: $daysToGo'),
                          backgroundColor: daysToGo > 0 ? Colors.green : (daysToGo == 0 ? Colors.yellow : Colors.red),
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
                                builder: (context) => UpcomingPaymentsEntryScreen(payment: record),
                              ),
                            );
                            if (result == true) _loadUpcomingPayments();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await _upcomingPaymentsDao.deleteUpcomingPayment(record['id']);
                            _loadUpcomingPayments();
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
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
              builder: (context) => const UpcomingPaymentsEntryScreen(),
            ),
          );
          if (result == true) _loadUpcomingPayments();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
