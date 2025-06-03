import 'package:flutter/material.dart';
import 'package:finance_management/screens/dashboard/dashboard_screen.dart';
import 'package:finance_management/screens/categories/categories_screen.dart';
import 'package:finance_management/screens/payment_status/payment_status_screen.dart';
import 'package:finance_management/screens/income/income_screen.dart';
import 'package:finance_management/screens/projections/projections_screen.dart';
import 'package:finance_management/screens/upcoming_payments/upcoming_payments_screen.dart';
import 'package:finance_management/database/database_helper.dart';
import 'dart:developer';

// Global ValueNotifier for month filtering
final ValueNotifier<DateTime> globalMonthController = ValueNotifier<DateTime>(DateTime.now());

void main() {
  //DatabaseHelper.initializeSqfliteFactory();
  //log('Sqflite factory initialization called');
  runApp(const FinanceManagementApp());
  //log('FinanceManagementApp started');
}

class FinanceManagementApp extends StatelessWidget {
  const FinanceManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Management',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardScreen(),
        '/income': (context) => const IncomeScreen(),
        '/projections': (context) => const ProjectionsScreen(),
        '/upcomingPayments': (context) => const UpcomingPaymentsScreen(),
        '/categories': (context) => const CategoriesScreen(),
        '/paymentStatus': (context) => const PaymentStatusScreen(),
      },
    );
  }
}
