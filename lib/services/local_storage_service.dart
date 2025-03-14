import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';

class LocalStorageService {
  static const String usersKey = 'cached_users';
  static Database? _database;

  // Initialize database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'users_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE users(uuid TEXT PRIMARY KEY, data TEXT)',
        );
      },
    );
  }

  // Cache users using shared preferences for the list
  Future<void> cacheUsers(List<UserModel> users) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> userJsons = users.map((user) => user.toJsonString()).toList();
      await prefs.setStringList(usersKey, userJsons);
      
      // Also save to SQLite for more detailed access
      final db = await database;
      final batch = db.batch();
      
      for (var user in users) {
        batch.insert(
          'users',
          {'uuid': user.uuid, 'data': user.toJsonString()},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      
      await batch.commit(noResult: true);
    } catch (e) {
      print('Error caching users: $e');
    }
  }

  // Get cached users list
  Future<List<UserModel>?> getCachedUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJsons = prefs.getStringList(usersKey);
      
      if (userJsons != null && userJsons.isNotEmpty) {
        return userJsons
            .map((jsonString) => UserModel.fromJsonString(jsonString))
            .toList();
      }
    } catch (e) {
      print('Error getting cached users: $e');
    }
    return null;
  }

  // Get specific user from SQLite
  Future<UserModel?> getCachedUserById(String uuid) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'uuid = ?',
        whereArgs: [uuid],
      );
      
      if (maps.isNotEmpty) {
        return UserModel.fromJsonString(maps.first['data'] as String);
      }
    } catch (e) {
      print('Error getting cached user by ID: $e');
    }
    return null;
  }

  // Clear cache
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(usersKey);
    
    final db = await database;
    await db.delete('users');
  }
} 