import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../database/dao/projections_dao.dart';
import '../../main.dart';
import '../../widgets/app_drawer.dart';

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
          _buildMonthPickerBar(),
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
                    leading: const Icon(Icons.trending_up),
                    title: Text(record['description'] ?? 'No Description'),
                    subtitle: Text('Date: ${record['projection_date']}'),
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
