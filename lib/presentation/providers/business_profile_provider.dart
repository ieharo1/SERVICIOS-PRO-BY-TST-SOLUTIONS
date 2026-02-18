import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/business_profile_repository.dart';
import '../../domain/entities/business_profile.dart';

final businessProfileRepositoryProvider = Provider((ref) {
  return BusinessProfileRepository();
});

final businessProfileProvider = FutureProvider<BusinessProfile?>((ref) async {
  final repository = ref.watch(businessProfileRepositoryProvider);
  return repository.getProfile();
});

final businessProfileNotifierProvider = StateNotifierProvider<BusinessProfileNotifier, AsyncValue<BusinessProfile?>>((ref) {
  final repository = ref.watch(businessProfileRepositoryProvider);
  return BusinessProfileNotifier(repository);
});

class BusinessProfileNotifier extends StateNotifier<AsyncValue<BusinessProfile?>> {
  final BusinessProfileRepository _repository;

  BusinessProfileNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _repository.getProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveProfile(BusinessProfile profile) async {
    try {
      await _repository.saveProfile(profile);
      await _loadProfile();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await _loadProfile();
  }
}
