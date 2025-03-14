import 'dart:convert';

class UserModel {
  final String uuid;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String pictureUrl;
  final String thumbnailUrl;
  final String city;
  final String country;
  final String streetName;
  final String streetNumber;
  final String postcode;
  final String gender;
  final DateTime dateOfBirth;

  UserModel({
    required this.uuid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.pictureUrl,
    required this.thumbnailUrl,
    required this.city,
    required this.country,
    required this.streetName,
    required this.streetNumber,
    required this.postcode,
    required this.gender,
    required this.dateOfBirth,
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      final id = json['id'] ?? {};
      final name = json['name'] ?? {};
      final location = json['location'] ?? {};
      final picture = json['picture'] ?? {};
      final street = location['street'] ?? {};
      
      return UserModel(
        uuid: _safeValue(id['value']) ?? _safeValue(id['name']) ?? 'unknown-${DateTime.now().millisecondsSinceEpoch}',
        firstName: _safeValue(name['first']) ?? 'Unknown',
        lastName: _safeValue(name['last']) ?? 'User',
        email: _safeValue(json['email']) ?? 'unknown@example.com',
        phone: _safeValue(json['phone']) ?? '(000) 000-0000',
        pictureUrl: _safeValue(picture['large']) ?? 'https://via.placeholder.com/150',
        thumbnailUrl: _safeValue(picture['thumbnail']) ?? 'https://via.placeholder.com/50',
        city: _safeValue(location['city']) ?? 'Unknown City',
        country: _safeValue(location['country']) ?? 'Unknown Country',
        streetName: _safeValue(street['name']) ?? 'Unknown Street',
        streetNumber: _safeValue(street['number']?.toString()) ?? '0',
        postcode: _safeValue(location['postcode']?.toString()) ?? '00000',
        gender: _safeValue(json['gender']) ?? 'other',
        dateOfBirth: _parseDateSafely(json['dob']?['date']),
      );
    } catch (e) {
      print('Error parsing user data: $e');
      print('Problematic JSON: $json');
      // Return fallback user data if parsing fails
      return UserModel(
        uuid: 'error-${DateTime.now().millisecondsSinceEpoch}',
        firstName: 'Error',
        lastName: 'User',
        email: 'error@example.com',
        phone: '(000) 000-0000',
        pictureUrl: 'https://via.placeholder.com/150',
        thumbnailUrl: 'https://via.placeholder.com/50',
        city: 'Error City',
        country: 'Error Country',
        streetName: 'Error Street',
        streetNumber: '0',
        postcode: '00000',
        gender: 'other',
        dateOfBirth: DateTime.now(),
      );
    }
  }

  // Helper method to safely parse string values
  static String? _safeValue(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }
  
  // Helper method to safely parse dates
  static DateTime _parseDateSafely(dynamic dateString) {
    if (dateString == null) return DateTime.now();
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'pictureUrl': pictureUrl,
      'thumbnailUrl': thumbnailUrl,
      'city': city,
      'country': country,
      'streetName': streetName,
      'streetNumber': streetNumber,
      'postcode': postcode,
      'gender': gender,
      'dateOfBirth': dateOfBirth.toIso8601String(),
    };
  }

  factory UserModel.fromJsonString(String jsonString) {
    try {
      return UserModel.fromJson(json.decode(jsonString));
    } catch (e) {
      print('Error parsing JSON string: $e');
      return UserModel(
        uuid: 'error-${DateTime.now().millisecondsSinceEpoch}',
        firstName: 'Error',
        lastName: 'User',
        email: 'error@example.com',
        phone: '(000) 000-0000',
        pictureUrl: 'https://via.placeholder.com/150',
        thumbnailUrl: 'https://via.placeholder.com/50',
        city: 'Error City',
        country: 'Error Country',
        streetName: 'Error Street',
        streetNumber: '0',
        postcode: '00000',
        gender: 'other',
        dateOfBirth: DateTime.now(),
      );
    }
  }

  String toJsonString() {
    return json.encode(toJson());
  }
} 