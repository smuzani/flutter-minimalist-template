import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../utils/app_logger.dart';

// States to represent different UI states
enum ViewState { initial, loading, loaded, error }

// Provider for UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  throw UnimplementedError('Repository must be overridden in the main.dart');
});

// Provider to cache users for quick access
final userCacheProvider = StateProvider<Map<String, UserModel>>((ref) => {});

// Provider for the list of users
final usersProvider = StateNotifierProvider<UsersNotifier, AsyncValue<List<UserModel>>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UsersNotifier(repository, ref);
});

// Provider for selected user details
final selectedUserProvider = StateNotifierProvider<SelectedUserNotifier, AsyncValue<UserModel?>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return SelectedUserNotifier(repository, ref);
});

// Notifier for the users list
class UsersNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  final UserRepository _repository;
  final Ref _ref;
  static const int defaultUserCount = 20; // Increased default count
  
  UsersNotifier(this._repository, this._ref) : super(const AsyncValue.loading()) {
    // Load users when initialized
    loadUsers(count: defaultUserCount);
  }
  
  Future<void> loadUsers({bool forceRefresh = false, int count = defaultUserCount}) async {
    try {
      state = const AsyncValue.loading();
      AppLogger.info('Loading $count users, forceRefresh: $forceRefresh');
      final users = await _repository.getUsers(forceRefresh: forceRefresh, count: count);
      
      // Update the user cache
      final userCache = _ref.read(userCacheProvider);
      final updatedCache = Map<String, UserModel>.from(userCache);
      for (var user in users) {
        updatedCache[user.uuid] = user;
      }
      _ref.read(userCacheProvider.notifier).state = updatedCache;
      
      AppLogger.info('Loaded ${users.length} users');
      state = AsyncValue.data(users);
    } catch (e, stackTrace) {
      AppLogger.error('Error loading users', e, stackTrace);
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
  final Ref _ref;
  
  SelectedUserNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));
  
  Future<void> selectUser(String userId) async {
    try {
      // Set loading state
      state = const AsyncValue.loading();
      
      // Check if we already have this user in the list
      final userCache = _ref.read(userCacheProvider);
      
      if (userCache.containsKey(userId)) {
        // Use the cached user if available
        AppLogger.debug('Using cached user: $userId');
        state = AsyncValue.data(userCache[userId]);
        return;
      }
      
      // Otherwise fetch from repository
      AppLogger.info('Fetching user details for: $userId');
      final user = await _repository.getUserDetails(userId);
      
      // Update the cache
      final updatedCache = Map<String, UserModel>.from(userCache);
      updatedCache[userId] = user;
      _ref.read(userCacheProvider.notifier).state = updatedCache;
      
      // Update state
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      AppLogger.error('Error selecting user', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  void clearSelectedUser() {
    state = const AsyncValue.data(null);
  }
} 