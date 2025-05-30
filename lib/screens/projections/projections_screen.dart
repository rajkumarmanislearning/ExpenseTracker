import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../database/dao/projections_dao.dart';
import '../../main.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/month_controller_bar.dart';
import 'projections_entry_screen.dart';

class ProjectionsScreen extends StatefulWidget {
  const ProjectionsScreen({super.key});

  @override
  State<ProjectionsScreen> createState() => _ProjectionsScreenState();
}

class _ProjectionsScreenState extends State<ProjectionsScreen> {
  final ProjectionsDao _projectionsDao = ProjectionsDao();

  @override
  void initState() {
    super.initState();
    globalMonthController.addListener(_loadProjections);
    _loadProjections();
  }

  @override
  void dispose() {
    globalMonthController.removeListener(_loadProjections);
    super.dispose();
  }

  List<Map<String, dynamic>> _projectionsRecords = [];

  void _loadProjections() async {
    final month = DateFormat('yyyy-MM').format(globalMonthController.value);
    final projections = await _projectionsDao.getProjectionsByMonth(month);
    setState(() {
      _projectionsRecords = projections;
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalProjected = 0;
    double totalPaid = 0;
    for (final record in _projectionsRecords) {
      totalProjected += (record['projected_amount'] ?? 0) as double;
      totalPaid += (record['amount_paid'] ?? 0) as double;
    }
    double balance = totalProjected - totalPaid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projections'),
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
              itemCount: _projectionsRecords.length,
              itemBuilder: (context, index) {
                final record = _projectionsRecords[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: const Icon(Icons.category), // Optionally use category icon
                    title: Text(record['description'] ?? record['category_name'] ?? 'No Description'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: \t${record['projection_date'] ?? ''}'),
                        Text('Projected: \t${record['projected_amount'] ?? 0}'),
                        Text('Paid: \t${record['amount_paid'] ?? 0}'),
                        Text('Status: \t${record['payment_status_name'] ?? ''}'),
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
                                builder: (context) => ProjectionsEntryScreen(projection: record),
                              ),
                            );
                            if (result == true) _loadProjections();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await _projectionsDao.deleteProjection(record['id']);
                            _loadProjections();
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
                Text('Total Projected: \t$totalProjected'),
                Text('Total Paid: \t$totalPaid'),
                Text('Balance: \t$balance'),
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
              builder: (context) => const ProjectionsEntryScreen(),
            ),
          );
          if (result == true) _loadProjections();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
