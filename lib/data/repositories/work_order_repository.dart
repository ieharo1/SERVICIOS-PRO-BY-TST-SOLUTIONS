import '../datasources/database_helper.dart';
import '../../domain/entities/work_order.dart';

class WorkOrderRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<WorkOrder>> getAllWorkOrders() async {
    final db = await _dbHelper.database;
    final result = await db.query('work_orders', orderBy: 'created_at DESC');
    
    return result.map((map) => WorkOrder.fromMap(map)).toList();
  }

  Future<WorkOrder?> getWorkOrderById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'work_orders',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (result.isEmpty) return null;
    return WorkOrder.fromMap(result.first);
  }

  Future<List<WorkOrder>> getWorkOrdersByStatus(String status) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'work_orders',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'created_at DESC',
    );
    
    return result.map((map) => WorkOrder.fromMap(map)).toList();
  }

  Future<List<WorkOrder>> getWorkOrdersByClient(int clientId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'work_orders',
      where: 'client_id = ?',
      whereArgs: [clientId],
      orderBy: 'created_at DESC',
    );
    
    return result.map((map) => WorkOrder.fromMap(map)).toList();
  }

  Future<List<WorkOrder>> getWorkOrdersByDateRange(DateTime start, DateTime end) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'work_orders',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    
    return result.map((map) => WorkOrder.fromMap(map)).toList();
  }

  Future<int> insertWorkOrder(WorkOrder workOrder) async {
    final db = await _dbHelper.database;
    return await db.insert('work_orders', workOrder.toMap());
  }

  Future<int> updateWorkOrder(WorkOrder workOrder) async {
    final db = await _dbHelper.database;
    return await db.update(
      'work_orders',
      workOrder.toMap(),
      where: 'id = ?',
      whereArgs: [workOrder.id],
    );
  }

  Future<int> deleteWorkOrder(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('work_orders', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getWorkOrderCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM work_orders');
    return result.first['count'] as int;
  }

  Future<int> getCompletedWorkOrderCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM work_orders WHERE status = 'Finalizada'",
    );
    return result.first['count'] as int;
  }

  Future<int> getMonthlyCompletedCount() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM work_orders WHERE date >= ? AND status = 'Finalizada'",
      [startOfMonth.toIso8601String()],
    );
    return result.first['count'] as int;
  }

  Future<double> getMonthlyWorkOrderTotal() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final result = await db.rawQuery(
      'SELECT SUM(total) as total FROM work_orders WHERE date >= ?',
      [startOfMonth.toIso8601String()],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<String> getNextOrderNumber() async {
    final counter = await _dbHelper.getSetting('order_counter');
    final number = int.parse(counter.isEmpty ? '1' : counter);
    final nextNumber = number.toString().padLeft(5, '0');
    return 'OT-$nextNumber';
  }

  Future<void> incrementOrderCounter() async {
    final counter = await _dbHelper.getSetting('order_counter');
    final number = int.parse(counter.isEmpty ? '1' : counter);
    await _dbHelper.setSetting('order_counter', (number + 1).toString());
  }

  Future<Map<int, double>> getTotalByClient(DateTime start, DateTime end) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT client_id, SUM(total) as total 
      FROM work_orders 
      WHERE date >= ? AND date <= ?
      GROUP BY client_id
    ''', [start.toIso8601String(), end.toIso8601String()]);
    
    Map<int, double> totals = {};
    for (var row in result) {
      totals[row['client_id'] as int] = (row['total'] as num).toDouble();
    }
    return totals;
  }

  Future<Map<String, double>> getMonthlyTotals(int year) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT strftime('%m', date) as month, SUM(total) as total 
      FROM work_orders 
      WHERE strftime('%Y', date) = ?
      GROUP BY strftime('%m', date)
    ''', [year.toString()]);
    
    Map<String, double> totals = {};
    for (var row in result) {
      totals[row['month'] as String] = (row['total'] as num).toDouble();
    }
    return totals;
  }
}
