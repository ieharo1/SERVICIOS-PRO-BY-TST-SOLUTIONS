import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/screens/clients/clients_screen.dart';
import '../presentation/screens/clients/client_form_screen.dart';
import '../presentation/screens/quotes/quotes_screen.dart';
import '../presentation/screens/quotes/quote_form_screen.dart';
import '../presentation/screens/orders/work_orders_screen.dart';
import '../presentation/screens/orders/work_order_form_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/reports/reports_screen.dart';
import '../presentation/widgets/main_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/clients',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ClientsScreen(),
          ),
          routes: [
            GoRoute(
              path: 'new',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) => const ClientFormScreen(),
            ),
            GoRoute(
              path: 'edit/:id',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return ClientFormScreen(clientId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/quotes',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: QuotesScreen(),
          ),
          routes: [
            GoRoute(
              path: 'new',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) => const QuoteFormScreen(),
            ),
            GoRoute(
              path: 'edit/:id',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return QuoteFormScreen(quoteId: id);
              },
            ),
            GoRoute(
              path: 'convert/:id',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return QuoteFormScreen(quoteId: id, convertToOrder: true);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/orders',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: WorkOrdersScreen(),
          ),
          routes: [
            GoRoute(
              path: 'new',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) => const WorkOrderFormScreen(),
            ),
            GoRoute(
              path: 'edit/:id',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return WorkOrderFormScreen(workOrderId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/reports',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ReportsScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/profile',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
