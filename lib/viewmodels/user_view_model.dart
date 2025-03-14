import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

// States to represent different UI states
enum ViewState { initial, loading, loaded, error }

// Provider for UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  throw UnimplementedError('Repository must be overridden in the main.dart');
});

// Provider for the list of users
final usersProvider = StateNotifierProvider<UsersNotifier, AsyncValue<List<UserModel>>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UsersNotifier(repository);
});

// Provider for selected user details
final selectedUserProvider = StateNotifierProvider<SelectedUserNotifier, AsyncValue<UserModel?>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return SelectedUserNotifier(repository);
});

// Notifier for the users list
class UsersNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  final UserRepository _repository;
  
  UsersNotifier(this._repository) : super(const AsyncValue.loading()) {
    // Load users when initialized
    loadUsers();
  }
  
  Future<void> loadUsers({bool forceRefresh = false, int count = 10}) async {
    try {
      state = const AsyncValue.loading();
      final users = await _repository.getUsers(forceRefresh: forceRefresh, count: count);
      state = AsyncValue.data(users);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  Future<void> refreshUsers() async {
    await loadUsers(forceRefresh: true);
  }
}

// Notifier for the selected user
class SelectedUserNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final UserRepository _repository;
  
  SelectedUserNotifier(this._repository) : super(const AsyncValue.data(null));
  
  Future<void> selectUser(String userId) async {
    try {
      state = const AsyncValue.loading();
      final user = await _repository.getUserDetails(userId);
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  void clearSelectedUser() {
    state = const AsyncValue.data(null);
  }
} 