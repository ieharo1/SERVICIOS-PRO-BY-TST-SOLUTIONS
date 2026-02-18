import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/quote_repository.dart';
import '../../domain/entities/quote.dart';

final quoteRepositoryProvider = Provider((ref) {
  return QuoteRepository();
});

final quotesProvider = FutureProvider<List<Quote>>((ref) async {
  final repository = ref.watch(quoteRepositoryProvider);
  return repository.getAllQuotes();
});

final quoteSearchQueryProvider = StateProvider<String>((ref) => '');

final quoteStatusFilterProvider = StateProvider<String?>((ref) => null);

final filteredQuotesProvider = FutureProvider<List<Quote>>((ref) async {
  final repository = ref.watch(quoteRepositoryProvider);
  final query = ref.watch(quoteSearchQueryProvider);
  final status = ref.watch(quoteStatusFilterProvider);
  
  List<Quote> quotes = await repository.getAllQuotes();
  
  if (query.isNotEmpty) {
    quotes = quotes.where((q) =>
      q.quoteNumber.toLowerCase().contains(query.toLowerCase()) ||
      q.clientName.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
  
  if (status != null) {
    quotes = quotes.where((q) => q.status == status).toList();
  }
  
  return quotes;
});

final quotesNotifierProvider = StateNotifierProvider<QuotesNotifier, AsyncValue<List<Quote>>>((ref) {
  final repository = ref.watch(quoteRepositoryProvider);
  return QuotesNotifier(repository);
});

class QuotesNotifier extends StateNotifier<AsyncValue<List<Quote>>> {
  final QuoteRepository _repository;

  QuotesNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    try {
      final quotes = await _repository.getAllQuotes();
      state = AsyncValue.data(quotes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<int> addQuote(Quote quote) async {
    final id = await _repository.insertQuote(quote);
    await _repository.incrementQuoteCounter();
    await _loadQuotes();
    return id;
  }

  Future<void> updateQuote(Quote quote) async {
    await _repository.updateQuote(quote);
    await _loadQuotes();
  }

  Future<void> deleteQuote(int id) async {
    await _repository.deleteQuote(id);
    await _loadQuotes();
  }

  Future<String> getNextQuoteNumber() async {
    return await _repository.getNextQuoteNumber();
  }

  Future<void> refresh() async {
    await _loadQuotes();
  }
}
