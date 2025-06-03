import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Text(
              'Finance Management',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pushNamed(context, '/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categories'),
            onTap: () {
              Navigator.pushNamed(context, '/categories');
            },
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Payment Status'),
            onTap: () {
              Navigator.pushNamed(context, '/paymentStatus');
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Income'),
            onTap: () {
              Navigator.pushNamed(context, '/income');
            },
          ),
          ListTile(
            leading: const Icon(Icons.trending_up),
            title: const Text('Projections'),
            onTap: () {
              Navigator.pushNamed(context, '/projections');
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Upcoming Payments'),
            onTap: () {
              Navigator.pushNamed(context, '/upcomingPayments');
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup & Restore'),
            onTap: () {
              Navigator.pushNamed(context, '/backupRestore');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              // Handle logout
            },
          ),
        ],
      ),
    );
  }
}
