import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE business_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        company_name TEXT NOT NULL,
        logo_path TEXT,
        phone TEXT NOT NULL,
        email TEXT NOT NULL,
        address TEXT NOT NULL,
        ruc TEXT NOT NULL,
        signature_path TEXT,
        currency TEXT NOT NULL,
        tax_rate REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        identification TEXT,
        phone TEXT NOT NULL,
        email TEXT NOT NULL,
        address TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE quotes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quote_number TEXT NOT NULL UNIQUE,
        client_id INTEGER NOT NULL,
        client_name TEXT NOT NULL,
        status TEXT NOT NULL,
        date TEXT NOT NULL,
        valid_until TEXT NOT NULL,
        notes TEXT,
        subtotal REAL NOT NULL,
        tax_rate REAL NOT NULL,
        tax_amount REAL NOT NULL,
        total REAL NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (client_id) REFERENCES clients (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE quote_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quote_id INTEGER NOT NULL,
        description TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        total REAL NOT NULL,
        FOREIGN KEY (quote_id) REFERENCES quotes (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE work_orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_number TEXT NOT NULL UNIQUE,
        quote_id INTEGER,
        quote_number TEXT NOT NULL,
        client_id INTEGER NOT NULL,
        client_name TEXT NOT NULL,
        status TEXT NOT NULL,
        date TEXT NOT NULL,
        observations TEXT,
        client_signature_path TEXT,
        total REAL NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (client_id) REFERENCES clients (id),
        FOREIGN KEY (quote_id) REFERENCES quotes (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await db.insert('settings', {'key': 'quote_counter', 'value': '1'});
    await db.insert('settings', {'key': 'order_counter', 'value': '1'});
    await db.insert('settings', {'key': 'dark_mode', 'value': 'false'});
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  Future<String> getSetting(String key) async {
    final db = await instance.database;
    final result = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    if (result.isEmpty) return '';
    return result.first['value'] as String;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await instance.database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
