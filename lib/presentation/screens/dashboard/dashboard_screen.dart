import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/client_provider.dart';
import '../../providers/quote_provider.dart';
import '../../providers/work_order_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    ref.read(clientsNotifierProvider.notifier).refresh();
    ref.read(quotesNotifierProvider.notifier).refresh();
    ref.read(workOrdersNotifierProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(clientsNotifierProvider);
    final quotes = ref.watch(quotesNotifierProvider);
    final orders = ref.watch(workOrdersNotifierProvider);
    
    final monthlyQuotes = quotes.when(
      data: (data) => data.where((q) {
        final now = DateTime.now();
        return q.date.year == now.year && q.date.month == now.month;
      }).length,
      loading: () => 0,
      error: (_, __) => 0,
    );
    
    final completedOrders = orders.when(
      data: (data) => data.where((o) => o.status == 'Finalizada').length,
      loading: () => 0,
      error: (_, __) => 0,
    );
    
    final estimatedIncome = quotes.when(
      data: (data) {
        final now = DateTime.now();
        return data
            .where((q) => q.date.year == now.year && q.date.month == now.month && q.status == 'Aprobada')
            .fold(0.0, (sum, q) => sum + q.total);
      },
      loading: () => 0.0,
      error: (_, __) => 0.0,
    );
    
    final clientCount = clients.when(
      data: (data) => data.length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appNameShort),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenido',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Resumen de tu negocio',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.3,
                children: [
                  _DashboardCard(
                    title: 'Clientes',
                    value: clientCount.toString(),
                    icon: Icons.people,
                    color: Colors.blue,
                    onTap: () => context.go('/clients'),
                  ),
                  _DashboardCard(
                    title: 'Cotizaciones',
                    value: monthlyQuotes.toString(),
                    subtitle: 'Este mes',
                    icon: Icons.description,
                    color: Colors.orange,
                    onTap: () => context.go('/quotes'),
                  ),
                  _DashboardCard(
                    title: 'Órdenes',
                    value: completedOrders.toString(),
                    subtitle: 'Completadas',
                    icon: Icons.check_circle,
                    color: Colors.green,
                    onTap: () => context.go('/orders'),
                  ),
                  _DashboardCard(
                    title: 'Ingresos',
                    value: '\$${estimatedIncome.toStringAsFixed(2)}',
                    subtitle: 'Este mes',
                    icon: Icons.attach_money,
                    color: Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Accesos Rápidos',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.person_add,
                      label: 'Nuevo Cliente',
                      onTap: () => context.push('/clients/new'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.add_comment,
                      label: 'Nueva Cotización',
                      onTap: () => context.push('/quotes/new'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.build,
                      label: 'Nueva Orden',
                      onTap: () => context.push('/orders/new'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.store,
                      label: 'Mi Perfil',
                      onTap: () => context.push('/profile'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Acerca de la App',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'SERVICIOS PRO BY TST SOLUTIONS\n'
                        'Gestión profesional de cotizaciones y órdenes de trabajo.\n'
                        '© 2024 TST Solutions',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _DashboardCard({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  if (onTap != null)
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
