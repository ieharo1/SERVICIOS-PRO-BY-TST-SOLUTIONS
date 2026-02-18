import '../datasources/database_helper.dart';
import '../../domain/entities/quote.dart';
import '../../domain/entities/quote_item.dart';

class QuoteRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Quote>> getAllQuotes() async {
    final db = await _dbHelper.database;
    final result = await db.query('quotes', orderBy: 'created_at DESC');
    
    List<Quote> quotes = [];
    for (var map in result) {
      final items = await _getQuoteItems(map['id'] as int);
      quotes.add(Quote.fromMap(map, items: items));
    }
    return quotes;
  }

  Future<Quote?> getQuoteById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'quotes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (result.isEmpty) return null;
    
    final items = await _getQuoteItems(id);
    return Quote.fromMap(result.first, items: items);
  }

  Future<List<QuoteItem>> _getQuoteItems(int quoteId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'quote_items',
      where: 'quote_id = ?',
      whereArgs: [quoteId],
    );
    
    return result.map((map) => QuoteItem.fromMap(map)).toList();
  }

  Future<List<Quote>> getQuotesByStatus(String status) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'quotes',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'created_at DESC',
    );
    
    List<Quote> quotes = [];
    for (var map in result) {
      final items = await _getQuoteItems(map['id'] as int);
      quotes.add(Quote.fromMap(map, items: items));
    }
    return quotes;
  }

  Future<List<Quote>> getQuotesByClient(int clientId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'quotes',
      where: 'client_id = ?',
      whereArgs: [clientId],
      orderBy: 'created_at DESC',
    );
    
    List<Quote> quotes = [];
    for (var map in result) {
      final items = await _getQuoteItems(map['id'] as int);
      quotes.add(Quote.fromMap(map, items: items));
    }
    return quotes;
  }

  Future<List<Quote>> getQuotesByDateRange(DateTime start, DateTime end) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'quotes',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    
    List<Quote> quotes = [];
    for (var map in result) {
      final items = await _getQuoteItems(map['id'] as int);
      quotes.add(Quote.fromMap(map, items: items));
    }
    return quotes;
  }

  Future<int> insertQuote(Quote quote) async {
    final db = await _dbHelper.database;
    
    final quoteId = await db.insert('quotes', quote.toMap());
    
    for (var item in quote.items) {
      await db.insert('quote_items', item.copyWith(quoteId: quoteId).toMap());
    }
    
    return quoteId;
  }

  Future<int> updateQuote(Quote quote) async {
    final db = await _dbHelper.database;
    
    await db.update(
      'quotes',
      quote.toMap(),
      where: 'id = ?',
      whereArgs: [quote.id],
    );
    
    await db.delete(
      'quote_items',
      where: 'quote_id = ?',
      whereArgs: [quote.id],
    );
    
    for (var item in quote.items) {
      await db.insert('quote_items', item.copyWith(quoteId: quote.id!).toMap());
    }
    
    return quote.id!;
  }

  Future<int> deleteQuote(int id) async {
    final db = await _dbHelper.database;
    await db.delete('quote_items', where: 'quote_id = ?', whereArgs: [id]);
    return await db.delete('quotes', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getQuoteCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM quotes');
    return result.first['count'] as int;
  }

  Future<int> getMonthlyQuoteCount() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM quotes WHERE date >= ?',
      [startOfMonth.toIso8601String()],
    );
    return result.first['count'] as int;
  }

  Future<double> getMonthlyTotal() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final result = await db.rawQuery(
      'SELECT SUM(total) as total FROM quotes WHERE date >= ? AND status = ?',
      [startOfMonth.toIso8601String(), 'Aprobada'],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<String> getNextQuoteNumber() async {
    final counter = await _dbHelper.getSetting('quote_counter');
    final number = int.parse(counter.isEmpty ? '1' : counter);
    final nextNumber = number.toString().padLeft(5, '0');
    return 'COT-$nextNumber';
  }

  Future<void> incrementQuoteCounter() async {
    final counter = await _dbHelper.getSetting('quote_counter');
    final number = int.parse(counter.isEmpty ? '1' : counter);
    await _dbHelper.setSetting('quote_counter', (number + 1).toString());
  }
}
