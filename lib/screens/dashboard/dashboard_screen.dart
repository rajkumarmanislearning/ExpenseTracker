import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:finance_management/main.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/month_controller_bar.dart';
import '../../database/dao/income_dao.dart';
import '../../database/dao/projections_dao.dart';
import '../../database/dao/upcoming_payments_dao.dart';
import '../../database/dao/category_dao.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final IncomeDao _incomeDao = IncomeDao();
  final ProjectionsDao _projectionsDao = ProjectionsDao();
  final UpcomingPaymentsDao _upcomingPaymentsDao = UpcomingPaymentsDao();
  final CategoryDao _categoryDao = CategoryDao();

  double _incomeProjected = 0;
  double _projectionsProjected = 0;
  double _projectionsPaid = 0;
  List<Map<String, dynamic>> _futureProjections = [];
  List<Map<String, dynamic>> _currentMonthProjections = [];
  List<Map<String, dynamic>> _upcomingPayments = [];
  Map<int, String> _categoryNames = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    globalMonthController.addListener(_refreshDashboard);
    _loadDashboardData();
  }

  @override
  void dispose() {
    globalMonthController.removeListener(_refreshDashboard);
    super.dispose();
  }

  void _refreshDashboard() {
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() { _loading = true; });
    final month = DateFormat('yyyy-MM').format(globalMonthController.value);
    final income = await _incomeDao.getIncomeByMonth(month);
    final projections = await _projectionsDao.getProjectionsByMonth(month);
    final upcoming = await _upcomingPaymentsDao.getUpcomingPaymentsByMonth(month);
    // For future projections (next 3 months)
    _futureProjections = [];
    for (int i = 1; i <= 3; i++) {
      final futureMonth = DateFormat('yyyy-MM').format(DateTime(globalMonthController.value.year, globalMonthController.value.month + i));
      final futurePayments = await _upcomingPaymentsDao.getUpcomingPaymentsByMonth(futureMonth);
      double sum = 0;
      for (final p in futurePayments) {
        final amt = p['projected_amount'];
        sum += amt is int ? amt.toDouble() : (amt ?? 0.0);
      }
      _futureProjections.add({
        'month': DateFormat('MMMM yyyy').format(DateTime(globalMonthController.value.year, globalMonthController.value.month + i)),
        'value': sum,
      });
    }
    // Current month settlement: projections not paid
    _currentMonthProjections = projections.where((p) => (p['payment_status_name'] ?? '').toLowerCase() != 'paid').toList();
    // Upcoming payments for section
    _upcomingPayments = upcoming;
    // Category names cache
    final allCats = await _categoryDao.getAllCategories();
    _categoryNames = { for (var c in allCats) c['id'] as int : c['name'] as String };
    // Sums
    _incomeProjected = 0;
    for (final i in income) {
      final amt = i['projected_amount'];
      _incomeProjected += amt is int ? amt.toDouble() : (amt ?? 0.0);
    }
    _projectionsProjected = 0;
    _projectionsPaid = 0;
    for (final p in projections) {
      final proj = p['projected_amount'];
      final paid = p['amount_paid'];
      _projectionsProjected += proj is int ? proj.toDouble() : (proj ?? 0.0);
      _projectionsPaid += paid is int ? paid.toDouble() : (paid ?? 0.0);
    }
    setState(() { _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 16),
              _buildDashboardCards(),
              const SizedBox(height: 24),
              _buildFuturePaymentsSection(),
              const SizedBox(height: 24),
              _buildCurrentMonthSettlement(),
              const SizedBox(height: 24),
              _buildUpcomingPaymentsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _buildDashboardCard(
            icon: Icons.attach_money,
            title: 'Income Received',
            value: '₹${_incomeProjected.toStringAsFixed(2)}',
            onTap: () {
              Navigator.pushNamed(context, '/income');
            },
          ),
        ),
        Expanded(
          child: _buildDashboardCard(
            icon: Icons.trending_up,
            title: 'Projections',
            value: '₹${_projectionsProjected.toStringAsFixed(2)}',
            onTap: () {
              Navigator.pushNamed(context, '/projections');
            },
          ),
        ),
        Expanded(
          child: _buildDashboardCard(
            icon: Icons.payments,
            title: 'Paid from Projections',
            value: '₹${_projectionsPaid.toStringAsFixed(2)}',
            onTap: () {},
          ),
        ),       
      ],
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.secondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFuturePaymentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Future Payments',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _futureProjections.length,
            itemBuilder: (context, index) {
              final data = _futureProjections[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['month'],
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${(data['value'] as double).toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.secondary),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentMonthSettlement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Current Month Settlement',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _currentMonthProjections.length,
            itemBuilder: (context, index) {
              final proj = _currentMonthProjections[index];
              final desc = proj['description'] ?? '';
              final catName = _categoryNames[proj['category_id']] ?? '';
              final projDateStr = proj['projection_date'] ?? '';
              final projDate = projDateStr != '' ? DateTime.tryParse(projDateStr) : null;
              final projected = proj['projected_amount'] is int ? (proj['projected_amount'] as int).toDouble() : (proj['projected_amount'] ?? 0.0);
              final paid = proj['amount_paid'] is int ? (proj['amount_paid'] as int).toDouble() : (proj['amount_paid'] ?? 0.0);
              final balance = projected - paid;
              int daysToPay = 0;
              Color daysColor = Colors.green;
              String daysText = '';
              if (projDate != null) {
                daysToPay = projDate.difference(DateTime.now()).inDays;
                if (daysToPay < 0) {
                  daysColor = Colors.red;
                  daysText = '${daysToPay.abs()} days overdue';
                } else if (daysToPay == 0) {
                  daysColor = Colors.yellow;
                  daysText = 'Due today';
                } else {
                  daysColor = Colors.green;
                  daysText = '$daysToPay days left';
                }
              }
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/projections', arguments: {'editId': proj['id']});
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(desc, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(catName),
                        const SizedBox(height: 8),
                        Text('Projection Date: ${projDateStr ?? ''}'),
                        const SizedBox(height: 8),
                        Text('Balance: ₹${balance.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(daysText, style: TextStyle(color: daysColor)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingPaymentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Upcoming Day(s) Payments',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _upcomingPayments.length,
          itemBuilder: (context, index) {
            final pay = _upcomingPayments[index];
            final catName = _categoryNames[pay['category_id']] ?? '';
            final desc = pay['description'] ?? '';
            final fromDateStr = pay['upcoming_from_date'] ?? '';
            final renewalDateStr = pay['renewal_date'] ?? '';
            final projected = pay['projected_amount'] is int ? (pay['projected_amount'] as int).toDouble() : (pay['projected_amount'] ?? 0.0);
            final paid = pay['amount_paid'] is int ? (pay['amount_paid'] as int).toDouble() : (pay['amount_paid'] ?? 0.0);
            final status = pay['payment_status_name'] ?? '';
            final fromDate = fromDateStr != '' ? DateTime.tryParse(fromDateStr) : null;
            int daysToGo = 0;
            Color daysColor = Colors.green;
            if (fromDate != null) {
              daysToGo = fromDate.difference(DateTime.now()).inDays;
              if (daysToGo < 0) {
                daysColor = Colors.red;
              } else {
                daysColor = Colors.green;
              }
            }
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/upcoming_payments', arguments: {'editId': pay['id']});
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(catName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(desc),
                      const SizedBox(height: 8),
                      Text('Upcoming Date: $fromDateStr'),
                      const SizedBox(height: 8),
                      Text('Renewal Date: $renewalDateStr'),
                      const SizedBox(height: 8),
                      Text('Projected Amount: ₹${projected.toStringAsFixed(2)}'),
                      const SizedBox(height: 8),
                      Text('Amount Paid: ₹${paid.toStringAsFixed(2)}'),
                      const SizedBox(height: 8),
                      Text('Status: $status'),
                      const SizedBox(height: 8),
                      Text('Days to go: $daysToGo', style: TextStyle(color: daysColor)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),       
      ],
    );
  }
}
