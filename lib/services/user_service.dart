import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:math';
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
      // Use a properly configured HTTP request with results parameter
      final uri = Uri.parse('$baseUrl?results=$count');
      
      print('Fetching $count users from: $uri');
      
      final request = http.Request('GET', uri);
      request.headers['Accept'] = 'application/json';
      request.headers['User-Agent'] = 'Flutter/RandomUserApp';
      
      final streamedResponse = await client.send(request).timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final results = jsonData['results'] as List;
        print('Received ${results.length} users from API');
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
      // but we can try to use the seed parameter to get consistent results
      final uri = Uri.parse('$baseUrl?seed=$userId');
      
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
    print('Generating $count mock users');
    List<UserModel> mockUsers = [];
    for (int i = 0; i < count; i++) {
      mockUsers.add(_getMockUser('mock-$i'));
    }
    return mockUsers;
  }
  
  // Random generators for mock data
  final Random _random = Random();
  final List<String> _mockFirstNames = [
    'John', 'Jane', 'Michael', 'Emily', 'David', 
    'Sarah', 'Robert', 'Lisa', 'William', 'Emma',
    'Thomas', 'Olivia', 'James', 'Sophia', 'Daniel'
  ];
  
  final List<String> _mockLastNames = [
    'Smith', 'Johnson', 'Williams', 'Brown', 'Jones',
    'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez',
    'Taylor', 'Thomas', 'Wilson', 'Anderson', 'Clark'
  ];
  
  final List<String> _mockCities = [
    'New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix',
    'Philadelphia', 'San Antonio', 'San Diego', 'Dallas', 'San Jose',
    'London', 'Tokyo', 'Paris', 'Berlin', 'Sydney'
  ];
  
  final List<String> _mockCountries = [
    'United States', 'Canada', 'United Kingdom', 'Australia', 'Germany',
    'France', 'Japan', 'Italy', 'Spain', 'Mexico',
    'Brazil', 'India', 'China', 'Russia', 'South Africa'
  ];
  
  final List<String> _mockStreetNames = [
    'Main Street', 'Park Avenue', 'Broadway', 'Oak Lane', 'Maple Drive',
    'Cedar Road', 'Pine Street', 'Elm Street', 'Washington Avenue', 'Lincoln Road',
    'Highland Drive', 'Lakeview Avenue', 'Willow Lane', 'River Road', 'Sunset Boulevard'
  ];
  
  UserModel _getMockUser(String id) {
    final firstName = _mockFirstNames[_random.nextInt(_mockFirstNames.length)];
    final lastName = _mockLastNames[_random.nextInt(_mockLastNames.length)];
    final city = _mockCities[_random.nextInt(_mockCities.length)];
    final country = _mockCountries[_random.nextInt(_mockCountries.length)];
    final streetName = _mockStreetNames[_random.nextInt(_mockStreetNames.length)];
    final streetNumber = (10 + _random.nextInt(990)).toString();
    final postcode = (10000 + _random.nextInt(90000)).toString();
    final email = '${firstName.toLowerCase()}.${lastName.toLowerCase()}@example.com';
    final gender = _random.nextBool() ? 'male' : 'female';
    
    // Generate a random date of birth between 18-80 years ago
    final daysToSubtract = 365 * (18 + _random.nextInt(62));
    final dateOfBirth = DateTime.now().subtract(Duration(days: daysToSubtract));
    
    // Generate a random phone number
    final areaCode = 100 + _random.nextInt(900);
    final firstPart = 100 + _random.nextInt(900);
    final secondPart = 1000 + _random.nextInt(9000);
    final phone = '($areaCode) $firstPart-$secondPart';
    
    return UserModel(
      uuid: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      pictureUrl: 'https://randomuser.me/api/portraits/${gender == 'male' ? 'men' : 'women'}/${_random.nextInt(99)}.jpg',
      thumbnailUrl: 'https://randomuser.me/api/portraits/thumb/${gender == 'male' ? 'men' : 'women'}/${_random.nextInt(99)}.jpg',
      city: city,
      country: country,
      streetName: streetName,
      streetNumber: streetNumber,
      postcode: postcode,
      gender: gender,
      dateOfBirth: dateOfBirth,
    );
  }
  
  void dispose() {
    _client?.close();
    _client = null;
  }
} 