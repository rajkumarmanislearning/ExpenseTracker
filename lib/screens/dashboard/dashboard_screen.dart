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
    // --- Modernized Dashboard Layout ---
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
              // Remove summary bar and use a card view for summary
              _buildSummaryCardView(context),
              const SizedBox(height: 16),
              // _buildDashboardCards(), // Removed as per user request
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

  // Replace summary bar with a card view for summary
  Widget _buildSummaryCardView(BuildContext context) {
    final balance = _incomeProjected - _projectionsPaid;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/income'),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Column(
                  children: [
                    Icon(Icons.attach_money, color: Colors.green, size: 32),
                    const SizedBox(height: 8),
                    Text('Income', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.green)),
                    const SizedBox(height: 4),
                    Text('₹${_incomeProjected.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/projections'),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Column(
                  children: [
                    Icon(Icons.payments, color: Colors.blue, size: 32),
                    const SizedBox(height: 8),
                    Text('Paid', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.blue)),
                    const SizedBox(height: 4),
                    Text('₹${_projectionsPaid.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: balance >= 0 ? Colors.teal[50] : Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Column(
                children: [
                  Icon(Icons.account_balance_wallet, color: balance >= 0 ? Colors.teal : Colors.red, size: 32),
                  const SizedBox(height: 8),
                  Text('Balance', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: balance >= 0 ? Colors.teal : Colors.red)),
                  const SizedBox(height: 4),
                  Text('₹${balance.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: balance >= 0 ? Colors.teal : Colors.red)),
                ],
              ),
            ),
          ),
        ),
      ],
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
          height: 140,
          child: _futureProjections.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text('No future payments found', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _futureProjections.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final data = _futureProjections[index];
                    final value = data['value'] as double;
                    final isZero = value == 0.0;
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: isZero ? Colors.grey[100] : Colors.amber[50],
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Container(
                        width: 180,
                        constraints: const BoxConstraints(minHeight: 100, maxHeight: 120), // Constrain height
                        padding: const EdgeInsets.all(8.0), // Slightly reduce padding
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_month, color: Colors.amber[700]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    data['month'],
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹${value.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isZero ? Colors.grey : Colors.amber[900],
                              ),
                            ),
                            const SizedBox(height: 4),
                            isZero
                                ? Chip(
                                    label: const Text('No payments'),
                                    backgroundColor: Colors.grey[200],
                                    labelStyle: const TextStyle(color: Colors.grey),
                                  )
                                : Chip(
                                    label: const Text('Upcoming'),
                                    backgroundColor: Colors.amber[100],
                                    labelStyle: const TextStyle(color: Colors.amber),
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
