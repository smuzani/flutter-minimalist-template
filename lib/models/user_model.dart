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
    final id = json['id'];
    final name = json['name'];
    final location = json['location'];
    final picture = json['picture'];
    final street = location['street'];
    
    return UserModel(
      uuid: id['value'] ?? id['name'],
      firstName: name['first'],
      lastName: name['last'],
      email: json['email'],
      phone: json['phone'],
      pictureUrl: picture['large'],
      thumbnailUrl: picture['thumbnail'],
      city: location['city'],
      country: location['country'],
      streetName: street['name'],
      streetNumber: street['number'].toString(),
      postcode: location['postcode'].toString(),
      gender: json['gender'],
      dateOfBirth: DateTime.parse(json['dob']['date']),
    );
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
    return UserModel.fromJson(json.decode(jsonString));
  }

  String toJsonString() {
    return json.encode(toJson());
  }
} 