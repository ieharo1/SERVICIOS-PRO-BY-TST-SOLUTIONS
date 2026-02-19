import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/quote_provider.dart';
import '../../providers/work_order_provider.dart';
import '../../providers/client_provider.dart';
import '../../widgets/app_drawer.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final quotes = ref.watch(quotesNotifierProvider);
    final orders = ref.watch(workOrdersNotifierProvider);
    final clients = ref.watch(clientsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const AppDrawer(currentRoute: '/reports'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filtro de Fechas',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Desde:'),
                              TextButton(
                                onPressed: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _startDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                  if (date != null) {
                                    setState(() => _startDate = date);
                                  }
                                },
                                child: Text('${_startDate.day}/${_startDate.month}/${_startDate.year}'),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Hasta:'),
                              TextButton(
                                onPressed: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _endDate,
                                    firstDate: _startDate,
                                    lastDate: DateTime.now(),
                                  );
                                  if (date != null) {
                                    setState(() => _endDate = date);
                                  }
                                },
                                child: Text('${_endDate.day}/${_endDate.month}/${_endDate.year}'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            quotes.when(
              data: (quoteList) {
                final filteredQuotes = quoteList.where((q) =>
                    q.date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
                    q.date.isBefore(_endDate.add(const Duration(days: 1)))).toList();
                
                final approvedQuotes = filteredQuotes.where((q) => q.status == 'Aprobada').toList();
                final totalQuotes = filteredQuotes.length;
                final totalAmount = approvedQuotes.fold(0.0, (sum, q) => sum + q.total);
                
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            title: 'Cotizaciones',
                            value: totalQuotes.toString(),
                            icon: Icons.description,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SummaryCard(
                            title: 'Aprobadas',
                            value: approvedQuotes.length.toString(),
                            icon: Icons.check_circle,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            title: 'Ingresos',
                            value: '\$${totalAmount.toStringAsFixed(2)}',
                            icon: Icons.attach_money,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: clients.when(
                            data: (clientList) => _SummaryCard(
                              title: 'Clientes',
                              value: clientList.length.toString(),
                              icon: Icons.people,
                              color: Colors.blue,
                            ),
                            loading: () => const _SummaryCard(
                              title: 'Clientes',
                              value: '-',
                              icon: Icons.people,
                              color: Colors.blue,
                            ),
                            error: (_, __) => const _SummaryCard(
                              title: 'Clientes',
                              value: '0',
                              icon: Icons.people,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
            const SizedBox(height: 24),
            Text(
              'Cotizaciones por Estado',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            quotes.when(
              data: (quoteList) {
                final filteredQuotes = quoteList.where((q) =>
                    q.date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
                    q.date.isBefore(_endDate.add(const Duration(days: 1)))).toList();
                
                final draft = filteredQuotes.where((q) => q.status == 'Borrador').length;
                final sent = filteredQuotes.where((q) => q.status == 'Enviada').length;
                final approved = filteredQuotes.where((q) => q.status == 'Aprobada').length;
                final rejected = filteredQuotes.where((q) => q.status == 'Rechazada').length;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            if (draft > 0) PieChartSectionData(value: draft.toDouble(), title: 'Borrador', color: Colors.grey, radius: 50),
                            if (sent > 0) PieChartSectionData(value: sent.toDouble(), title: 'Enviada', color: Colors.blue, radius: 50),
                            if (approved > 0) PieChartSectionData(value: approved.toDouble(), title: 'Aprobada', color: Colors.green, radius: 50),
                            if (rejected > 0) PieChartSectionData(value: rejected.toDouble(), title: 'Rechazada', color: Colors.red, radius: 50),
                          ],
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                  ),
                );
              },
              loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
              error: (e, _) => SizedBox(height: 200, child: Center(child: Text('Error: $e'))),
            ),
            const SizedBox(height: 24),
            orders.when(
              data: (orderList) {
                final filteredOrders = orderList.where((o) =>
                    o.date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
                    o.date.isBefore(_endDate.add(const Duration(days: 1)))).toList();
                
                final pending = filteredOrders.where((o) => o.status == 'Pendiente').length;
                final inProgress = filteredOrders.where((o) => o.status == 'En proceso').length;
                final completed = filteredOrders.where((o) => o.status == 'Finalizada').length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Órdenes de Trabajo',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sections: [
                                if (pending > 0) PieChartSectionData(value: pending.toDouble(), title: 'Pendiente', color: Colors.orange, radius: 50),
                                if (inProgress > 0) PieChartSectionData(value: inProgress.toDouble(), title: 'En proceso', color: Colors.blue, radius: 50),
                                if (completed > 0) PieChartSectionData(value: completed.toDouble(), title: 'Finalizada', color: Colors.green, radius: 50),
                              ],
                              centerSpaceRadius: 40,
                              sectionsSpace: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
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
                        Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
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
                      '${AppConstants.appName}\n'
                      'Gestión profesional de cotizaciones y órdenes de trabajo.\n'
                      '© 2026 TST Solutions',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
