import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/work_order_provider.dart';

class WorkOrdersScreen extends ConsumerWidget {
  const WorkOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(filteredWorkOrdersProvider);
    final searchQuery = ref.watch(workOrderSearchQueryProvider);
    final statusFilter = ref.watch(workOrderStatusFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Órdenes de Trabajo'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/orders/new'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar órdenes...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => ref.read(workOrderSearchQueryProvider.notifier).state = '',
                          )
                        : null,
                  ),
                  onChanged: (value) => ref.read(workOrderSearchQueryProvider.notifier).state = value,
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Todos'),
                        selected: statusFilter == null,
                        onSelected: (_) => ref.read(workOrderStatusFilterProvider.notifier).state = null,
                      ),
                      const SizedBox(width: 8),
                      ...AppConstants.orderStatuses.map((status) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(status),
                          selected: statusFilter == status,
                          onSelected: (_) => ref.read(workOrderStatusFilterProvider.notifier).state = status,
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: orders.when(
              data: (orderList) {
                if (orderList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.build_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('No hay órdenes', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => context.push('/orders/new'),
                          icon: const Icon(Icons.add),
                          label: const Text('Nueva Orden'),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.read(workOrdersNotifierProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: orderList.length,
                    itemBuilder: (context, index) {
                      final order = orderList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(order.orderNumber),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(order.clientName),
                              Text('\$${order.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          trailing: _OrderStatusChip(status: order.status),
                          onTap: () => context.push('/orders/edit/${order.id}'),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/orders/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _OrderStatusChip extends StatelessWidget {
  final String status;
  const _OrderStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'Pendiente': color = Colors.orange; break;
      case 'En proceso': color = Colors.blue; break;
      case 'Finalizada': color = Colors.green; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 12)),
    );
  }
}
