import 'dart:async';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/local_storage_service.dart';

class UserRepository {
  final UserService _userService;
  final LocalStorageService _localStorageService;
  
  UserRepository({
    required UserService userService, 
    required LocalStorageService localStorageService
  }) : _userService = userService, 
       _localStorageService = localStorageService;

  // Get users with option to force refresh from network
  Future<List<UserModel>> getUsers({bool forceRefresh = false, int count = 10}) async {
    // Try to get from cache first unless forceRefresh is true
    if (!forceRefresh) {
      final cachedUsers = await _localStorageService.getCachedUsers();
      if (cachedUsers != null && cachedUsers.isNotEmpty) {
        print('Using cached users data: ${cachedUsers.length} users');
        
        // If we have fewer cached users than requested, force refresh
        if (cachedUsers.length < count) {
          print('Cached users count (${cachedUsers.length}) is less than requested count ($count), forcing refresh');
          return _fetchAndCacheUsers(count);
        }
        
        return cachedUsers;
      }
    }
    
    // If not in cache or forceRefresh, attempt to fetch from network
    return _fetchAndCacheUsers(count);
  }
  
  // Helper to fetch and cache users
  Future<List<UserModel>> _fetchAndCacheUsers(int count) async {
    try {
      print('Fetching users from network: requesting $count users');
      final users = await _userService.getUsers(count: count);
      
      // Cache the data for future use if we have a successful result
      if (users.isNotEmpty) {
        await _localStorageService.cacheUsers(users);
        print('Cached ${users.length} users');
      }
      
      return users;
    } catch (e) {
      print('Network error: $e');
      
      // Always try to return cached data as fallback in case of error
      final cachedUsers = await _localStorageService.getCachedUsers();
      if (cachedUsers != null && cachedUsers.isNotEmpty) {
        print('Falling back to cached data: ${cachedUsers.length} users');
        return cachedUsers;
      }
      
      // If we have no cached data and network failed, let the service provide mock data
      return _userService.getUsers(count: count);
    }
  }
  
  // Get single user details
  Future<UserModel> getUserDetails(String userId) async {
    try {
      // Try to get from cache first
      final cachedUser = await _localStorageService.getCachedUserById(userId);
      if (cachedUser != null) {
        print('Using cached user details for: $userId');
        return cachedUser;
      }
      
      // If not in cache, fetch from network
      print('Fetching user details from network for: $userId');
      final user = await _userService.getUserDetails(userId);
      
      // Update the cache with this single user
      await _localStorageService.cacheUsers([user]);
      return user;
    } catch (e) {
      print('Error getting user details: $e');
      // Let the service provide the user (it will return mock data if needed)
      return _userService.getUserDetails(userId);
    }
  }
  
  // Clear all cached data
  Future<void> clearCache() async {
    await _localStorageService.clearCache();
    print('Cache cleared');
  }
} 