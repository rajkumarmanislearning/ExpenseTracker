import 'package:flutter/material.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/categories/categories_screen.dart';
import 'screens/payment_status/payment_status_screen.dart';
import 'screens/income/income_screen.dart';
import 'screens/projections/projections_screen.dart';
import 'screens/upcoming_payments/upcoming_payments_screen.dart';

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
        '/categories': (context) => const CategoriesScreen(),
        '/paymentStatus': (context) => const PaymentStatusScreen(),
        '/income': (context) => const IncomeScreen(),
        '/projections': (context) => const ProjectionsScreen(),
        '/upcomingPayments': (context) => const UpcomingPaymentsScreen(),
      },
    );
  }
}
