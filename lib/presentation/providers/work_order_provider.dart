import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/work_order_repository.dart';
import '../../domain/entities/work_order.dart';

final workOrderRepositoryProvider = Provider((ref) {
  return WorkOrderRepository();
});

final workOrdersProvider = FutureProvider<List<WorkOrder>>((ref) async {
  final repository = ref.watch(workOrderRepositoryProvider);
  return repository.getAllWorkOrders();
});

final workOrderSearchQueryProvider = StateProvider<String>((ref) => '');

final workOrderStatusFilterProvider = StateProvider<String?>((ref) => null);

final filteredWorkOrdersProvider = FutureProvider<List<WorkOrder>>((ref) async {
  final repository = ref.watch(workOrderRepositoryProvider);
  final query = ref.watch(workOrderSearchQueryProvider);
  final status = ref.watch(workOrderStatusFilterProvider);
  
  List<WorkOrder> orders = await repository.getAllWorkOrders();
  
  if (query.isNotEmpty) {
    orders = orders.where((o) =>
      o.orderNumber.toLowerCase().contains(query.toLowerCase()) ||
      o.clientName.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
  
  if (status != null) {
    orders = orders.where((o) => o.status == status).toList();
  }
  
  return orders;
});

final workOrdersNotifierProvider = StateNotifierProvider<WorkOrdersNotifier, AsyncValue<List<WorkOrder>>>((ref) {
  final repository = ref.watch(workOrderRepositoryProvider);
  return WorkOrdersNotifier(repository);
});

class WorkOrdersNotifier extends StateNotifier<AsyncValue<List<WorkOrder>>> {
  final WorkOrderRepository _repository;

  WorkOrdersNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadWorkOrders();
  }

  Future<void> _loadWorkOrders() async {
    try {
      final orders = await _repository.getAllWorkOrders();
      state = AsyncValue.data(orders);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<int> addWorkOrder(WorkOrder workOrder) async {
    final id = await _repository.insertWorkOrder(workOrder);
    await _repository.incrementOrderCounter();
    await _loadWorkOrders();
    return id;
  }

  Future<void> updateWorkOrder(WorkOrder workOrder) async {
    await _repository.updateWorkOrder(workOrder);
    await _loadWorkOrders();
  }

  Future<void> deleteWorkOrder(int id) async {
    await _repository.deleteWorkOrder(id);
    await _loadWorkOrders();
  }

  Future<String> getNextOrderNumber() async {
    return await _repository.getNextOrderNumber();
  }

  Future<void> refresh() async {
    await _loadWorkOrders();
  }
}
