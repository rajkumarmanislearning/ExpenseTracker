import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:finance_management/main.dart';
import '../../widgets/app_drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    globalMonthController.addListener(_refreshDashboard);
  }

  @override
  void dispose() {
    globalMonthController.removeListener(_refreshDashboard);
    super.dispose();
  }

  void _refreshDashboard() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
              _buildMonthPickerBar(),
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

  Widget _buildMonthPickerBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            globalMonthController.value = DateTime(
              globalMonthController.value.year,
              globalMonthController.value.month - 1,
            );
          },
        ),
        TextButton(
          onPressed: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: globalMonthController.value,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (selectedDate != null) {
              globalMonthController.value = selectedDate;
            }
          },
          child: Text(
            DateFormat('MMMM yyyy').format(globalMonthController.value),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            globalMonthController.value = DateTime(
              globalMonthController.value.year,
              globalMonthController.value.month + 1,
            );
          },
        ),
      ],
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
            value: '₹0',
            onTap: () {
              Navigator.pushNamed(context, '/income');
            },
          ),
        ),
        Expanded(
          child: _buildDashboardCard(
            icon: Icons.trending_up,
            title: 'Projections',
            value: '₹0',
            onTap: () {
              Navigator.pushNamed(context, '/projections');
            },
          ),
        ),
        Expanded(
          child: _buildDashboardCard(
            icon: Icons.payments,
            title: 'Paid from Projections',
            value: '₹0',
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
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5, // Replace with actual data count
            itemBuilder: (context, index) {
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: InkWell(
                  onTap: () {
                    // Navigate to Projections screen and open edit dialog
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Description'), // Replace with actual data
                        const SizedBox(height: 8),
                        Text('Category Name'), // Replace with actual data
                        const SizedBox(height: 8),
                        Text('Balance: ₹0'), // Replace with actual data
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
          itemCount: 5, // Replace with actual data count
          itemBuilder: (context, index) {
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Category'), // Replace with actual data
                    const SizedBox(height: 8),
                    Text('Description'), // Replace with actual data
                    const SizedBox(height: 8),
                    Text('Upcoming Date: May 30, 2025'), // Replace with actual data
                    const SizedBox(height: 8),
                    Text('Renewal Date: June 30, 2025'), // Replace with actual data
                    const SizedBox(height: 8),
                    Text('Projected Amount: ₹0'), // Replace with actual data
                    const SizedBox(height: 8),
                    Text('Amount Paid: ₹0'), // Replace with actual data
                  ],
                ),
              ),
            );
          },
        ),       
      ],
    );
  }

  Widget _buildFuturePaymentsSection() {
    final now = DateTime.now();
    final futureMonths = List.generate(3, (index) {
      final month = DateTime(now.year, now.month + index, 1);
      return {
        'month': DateFormat('MMM-yyyy').format(month),
        'value': '₹${(index + 1) * 1000}',
      };
    });

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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: futureMonths.map((data) {
            return Expanded(
              child: Card(
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
                        data['month']!,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data['value']!,
                        style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.secondary),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
