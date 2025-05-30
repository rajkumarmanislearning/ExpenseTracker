import 'package:flutter/material.dart';
import '../../database/dao/payment_status_dao.dart';
import '../../widgets/app_drawer.dart';
import 'payment_status_entry_screen.dart';

class PaymentStatusScreen extends StatefulWidget {
  const PaymentStatusScreen({super.key});

  @override
  State<PaymentStatusScreen> createState() => _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends State<PaymentStatusScreen> {
  final PaymentStatusDao _paymentStatusDao = PaymentStatusDao();

  @override
  void initState() {
    super.initState();
    _loadPaymentStatuses();
  }

  List<Map<String, dynamic>> _paymentStatuses = [];

  void _loadPaymentStatuses() async {
    final statuses = await _paymentStatusDao.getAllPaymentStatuses();
    setState(() {
      _paymentStatuses = statuses;
    });
  }

  void _navigateToEntryScreen({Map<String, dynamic>? status}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentStatusEntryScreen(status: status),
      ),
    );
    if (result == true) {
      _loadPaymentStatuses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Status'),
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
      body: ListView.builder(
        itemCount: _paymentStatuses.length,
        itemBuilder: (context, index) {
          final status = _paymentStatuses[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: const Icon(Icons.payment),
              title: Text(status['name']),
              subtitle: Text(status['description'] ?? ''),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _navigateToEntryScreen(status: status),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await _paymentStatusDao.deletePaymentStatus(status['id']);
                      _loadPaymentStatuses();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEntryScreen(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
