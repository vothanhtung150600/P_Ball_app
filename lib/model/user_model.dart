import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
 late String name;
 late String bio;
 late String birthday;
 late String profilePic;
 late String createdAt;
 late String phoneNumber;
 late String uid;
 late String status;

  UserModel({
    required this.name,
    required this.bio,
    required this.birthday,
    required this.profilePic,
    required this.createdAt,
    required this.phoneNumber,
    required this.uid,
    required this.status
  });

  UserModel.phone({required this.phoneNumber});
  UserModel.profile({required this.profilePic});


 // from map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? map['name'] as String ?? '',
      bio: map['bio'] ?? map['bio'] as String ?? '',
      birthday: map['birthday'] ?? map['birthday'] as String ?? '',
      uid: map['uid'] ?? map['uid'] as String ?? '',
      phoneNumber: map['phoneNumber'] ?? map['phoneNumber'] as String ?? '',
      createdAt: map['createdAt'] ?? map['createdAt'] as String ?? '',
      profilePic: map['profilePic'] ?? map['profilePic'] as String ?? '',
      status: map['status'] ?? map['status'] as String ?? '',
    );
  }

  // to map
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "name": name,
      "uid": uid,
      "bio": bio,
      "birthday" : birthday,
      "profilePic": profilePic,
      "phoneNumber": phoneNumber,
      "createdAt": createdAt,
      "status": status,
    };
  }
}
