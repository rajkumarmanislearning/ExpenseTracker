import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../database/dao/upcoming_payments_dao.dart';
import '../../widgets/app_drawer.dart';

import '../../main.dart';

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
          _buildMonthPickerBar(),
          Expanded(
            child: ListView.builder(
              itemCount: _upcomingPaymentsRecords.length,
              itemBuilder: (context, index) {
                final record = _upcomingPaymentsRecords[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: const Icon(Icons.schedule),
                    title: Text(record['description'] ?? 'No Description'),
                    subtitle: Text('Upcoming Date: ${record['upcoming_from_date']}'),
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
