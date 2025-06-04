import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A reusable MonthControllerBar widget for month navigation.
class MonthControllerBar extends StatelessWidget {
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onMonthChanged;
  final VoidCallback? onTap;

  const MonthControllerBar({
    super.key,
    required this.selectedMonth,
    required this.onMonthChanged,
    this.onTap,
  });

  void _goToPreviousMonth() {
    final prevMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
    onMonthChanged(prevMonth);
  }

  void _goToNextMonth() {
    final nextMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
    onMonthChanged(nextMonth);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _goToPreviousMonth,
          ),
          TextButton(
            onPressed: onTap,
            child: Text(DateFormat('MMMM yyyy').format(selectedMonth)),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _goToNextMonth,
          ),
        ],
      ),
    );
  }
}
