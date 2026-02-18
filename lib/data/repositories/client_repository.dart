import 'package:sqflite/sqflite.dart';
import '../datasources/database_helper.dart';
import '../../domain/entities/client.dart';

class ClientRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Client>> getAllClients() async {
    final db = await _dbHelper.database;
    final result = await db.query('clients', orderBy: 'name ASC');
    
    return result.map((map) => Client(
      id: map['id'] as int?,
      name: map['name'] as String,
      identification: map['identification'] as String?,
      phone: map['phone'] as String,
      email: map['email'] as String,
      address: map['address'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    )).toList();
  }

  Future<Client?> getClientById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (result.isEmpty) return null;
    
    final map = result.first;
    return Client(
      id: map['id'] as int?,
      name: map['name'] as String,
      identification: map['identification'] as String?,
      phone: map['phone'] as String,
      email: map['email'] as String,
      address: map['address'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Future<List<Client>> searchClients(String query) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'clients',
      where: 'name LIKE ? OR identification LIKE ? OR phone LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    
    return result.map((map) => Client(
      id: map['id'] as int?,
      name: map['name'] as String,
      identification: map['identification'] as String?,
      phone: map['phone'] as String,
      email: map['email'] as String,
      address: map['address'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    )).toList();
  }

  Future<int> insertClient(Client client) async {
    final db = await _dbHelper.database;
    return await db.insert('clients', {
      'name': client.name,
      'identification': client.identification,
      'phone': client.phone,
      'email': client.email,
      'address': client.address,
      'created_at': client.createdAt.toIso8601String(),
    });
  }

  Future<int> updateClient(Client client) async {
    final db = await _dbHelper.database;
    return await db.update(
      'clients',
      {
        'name': client.name,
        'identification': client.identification,
        'phone': client.phone,
        'email': client.email,
        'address': client.address,
      },
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }

  Future<int> deleteClient(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getClientDocumentCount(int clientId) async {
    final db = await _dbHelper.database;
    final quoteCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM quotes WHERE client_id = ?',
      [clientId],
    )) ?? 0;
    final orderCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM work_orders WHERE client_id = ?',
      [clientId],
    )) ?? 0;
    return quoteCount + orderCount;
  }
}
