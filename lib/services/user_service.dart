import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class UserService {
  final String baseUrl = 'https://randomuser.me/api/';
  
  // Default timeout for HTTP requests
  final Duration timeout = const Duration(seconds: 10);
  
  // HTTP client with proper configuration
  http.Client? _client;
  
  http.Client get client {
    _client ??= http.Client();
    return _client!;
  }
  
  // For testing purposes
  void setClient(http.Client newClient) {
    _client = newClient;
  }
  
  Future<List<UserModel>> getUsers({int count = 10}) async {
    try {
      // Use a properly configured HTTP request
      final uri = Uri.parse('$baseUrl?results=$count');
      
      final request = http.Request('GET', uri);
      request.headers['Accept'] = 'application/json';
      request.headers['User-Agent'] = 'Flutter/RandomUserApp';
      
      final streamedResponse = await client.send(request).timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final results = jsonData['results'] as List;
        return results.map((user) => UserModel.fromJson(user)).toList();
      } else {
        throw Exception('Failed to load users: HTTP ${response.statusCode}');
      }
    } on SocketException catch (e) {
      print('Socket exception: $e');
      return _getMockUsers(count);
    } on http.ClientException catch (e) {
      print('Client exception: $e');
      return _getMockUsers(count);
    } on TimeoutException catch (e) {
      print('Timeout exception: $e');
      return _getMockUsers(count);
    } catch (e) {
      print('Unknown error occurred: $e');
      return _getMockUsers(count);
    }
  }

  Future<UserModel> getUserDetails(String userId) async {
    try {
      // The Random User API doesn't support fetching by ID,
      // so we're simulating it by fetching a single user
      final uri = Uri.parse('$baseUrl?uuid=$userId');
      
      final request = http.Request('GET', uri);
      request.headers['Accept'] = 'application/json';
      request.headers['User-Agent'] = 'Flutter/RandomUserApp';
      
      final streamedResponse = await client.send(request).timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final results = jsonData['results'] as List;
        if (results.isNotEmpty) {
          return UserModel.fromJson(results.first);
        } else {
          throw Exception('User not found');
        }
      } else {
        throw Exception('Failed to load user details: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting user details: $e');
      // Return a mock user if we can't get the real one
      return _getMockUser(userId);
    }
  }
  
  // Provide mock data when the API is unavailable
  List<UserModel> _getMockUsers(int count) {
    List<UserModel> mockUsers = [];
    for (int i = 0; i < count; i++) {
      mockUsers.add(_getMockUser('mock-$i'));
    }
    return mockUsers;
  }
  
  UserModel _getMockUser(String id) {
    return UserModel(
      uuid: id,
      firstName: 'User',
      lastName: id,
      email: 'user$id@example.com',
      phone: '(123) 456-7890',
      pictureUrl: 'https://via.placeholder.com/150',
      thumbnailUrl: 'https://via.placeholder.com/50',
      city: 'Sample City',
      country: 'Sample Country',
      streetName: 'Main Street',
      streetNumber: '123',
      postcode: '12345',
      gender: 'other',
      dateOfBirth: DateTime.now().subtract(const Duration(days: 10000)),
    );
  }
  
  void dispose() {
    _client?.close();
    _client = null;
  }
} 