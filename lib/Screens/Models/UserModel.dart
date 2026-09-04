import 'dart:io';

class User {
  String? phone;
  String? name;
  String? password;
  File? profile_image;
  String? profilePath;
  List<User>? chatMessages;
  String? status;
  int unReadMessages = 0;

  User({
    this.phone,
    this.name,
    this.password,
    this.profile_image,
    this.profilePath,
    this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'phone': phone,
      'name': name,
      'password': password,
      'profile_image': profile_image,
      'profilePath': profilePath,
      'status': status,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      phone: map['phone'],
      name: map['name'],
      password: map['password'],
      profile_image: map['profile_image'],
      profilePath: map['profilePath'],
      status: map['status'],
    );
  }
}
