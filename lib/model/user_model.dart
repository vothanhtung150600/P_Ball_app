import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
 late String name;
 late String bio;
 late String birthday;
 late String profilePic;
 late String createdAt;
 late String phoneNumber;
 late String uid;
 late String role;

  UserModel({
    required this.name,
    required this.bio,
    required this.birthday,
    required this.profilePic,
    required this.createdAt,
    required this.phoneNumber,
    required this.uid,
    required this.role
  });

  UserModel.phone({required this.phoneNumber});
  UserModel.profile({required this.profilePic});


 // from map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      bio: map['bio'] ?? '',
      birthday: map['birthday'],
      uid: map['uid'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      createdAt: map['createdAt'] ?? '',
      profilePic: map['profilePic'] ?? '',
      role: map['role'] ?? '',
    );
  }

  // to map
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "uid": uid,
      "bio": bio,
      "birthday" : birthday,
      "profilePic": profilePic,
      "phoneNumber": phoneNumber,
      "createdAt": createdAt,
      "role": role
    };
  }
}
