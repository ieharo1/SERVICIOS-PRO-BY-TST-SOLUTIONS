import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/client_repository.dart';
import '../../domain/entities/client.dart';

final clientRepositoryProvider = Provider((ref) {
  return ClientRepository();
});

final clientsProvider = FutureProvider<List<Client>>((ref) async {
  final repository = ref.watch(clientRepositoryProvider);
  return repository.getAllClients();
});

final clientSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredClientsProvider = FutureProvider<List<Client>>((ref) async {
  final repository = ref.watch(clientRepositoryProvider);
  final query = ref.watch(clientSearchQueryProvider);
  
  if (query.isEmpty) {
    return repository.getAllClients();
  }
  return repository.searchClients(query);
});

final clientsNotifierProvider = StateNotifierProvider<ClientsNotifier, AsyncValue<List<Client>>>((ref) {
  final repository = ref.watch(clientRepositoryProvider);
  return ClientsNotifier(repository);
});

class ClientsNotifier extends StateNotifier<AsyncValue<List<Client>>> {
  final ClientRepository _repository;

  ClientsNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadClients();
  }

  Future<void> _loadClients() async {
    try {
      final clients = await _repository.getAllClients();
      state = AsyncValue.data(clients);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<int> addClient(Client client) async {
    final id = await _repository.insertClient(client);
    await _loadClients();
    return id;
  }

  Future<void> updateClient(Client client) async {
    await _repository.updateClient(client);
    await _loadClients();
  }

  Future<void> deleteClient(int id) async {
    await _repository.deleteClient(id);
    await _loadClients();
  }

  Future<void> refresh() async {
    await _loadClients();
  }
}
