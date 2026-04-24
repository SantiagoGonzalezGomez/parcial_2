

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../views/dashboard/dashboard_view.dart';
import '../views/accidents/accidents_view.dart';
import '../views/establishments/establishments_list_view.dart';
import '../views/establishments/establishment_detail_view.dart';
import '../views/establishments/establishment_form_view.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'dashboard',
            builder: (context, state) => const DashboardView(),
          ),
          GoRoute(
            path: '/accidents',
            name: 'accidents',
            builder: (context, state) => const AccidentsView(),
          ),
          GoRoute(
            path: '/establishments',
            name: 'establishments',
            builder: (context, state) => const EstablishmentsListView(),
          ),
          GoRoute(
            path: '/establishments/new',
            name: 'establishment-new',
            builder: (context, state) => const EstablishmentFormView(),
          ),
          GoRoute(
            path: '/establishments/:id',
            name: 'establishment-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return EstablishmentDetailView(id: id);
            },
          ),
          GoRoute(
            path: '/establishments/:id/edit',
            name: 'establishment-edit',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return EstablishmentFormView(id: id);
            },
          ),
        ],
      ),
    ],
  );
});

class AppShell extends StatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<_NavItem> _items = const [
    _NavItem(label: 'Dashboard', icon: Icons.dashboard, path: '/'),
    _NavItem(label: 'Accidentes', icon: Icons.warning_amber, path: '/accidents'),
    _NavItem(label: 'Parkings', icon: Icons.local_parking, path: '/establishments'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          context.go(_items[index].path);
        },
        destinations: _items
            .map((item) => NavigationDestination(
                  icon: Icon(item.icon),
                  label: item.label,
                ))
            .toList(),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final String path;
  const _NavItem({
    required this.label,
    required this.icon,
    required this.path,
  });
}