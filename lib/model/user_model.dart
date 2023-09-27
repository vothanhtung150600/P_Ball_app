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
 late String main_text;
 late dynamic likeby;
 late int comment_count;
 late Timestamp updateAT;



 UserModel({
    required this.name,
    required this.bio,
    required this.birthday,
    required this.profilePic,
    required this.createdAt,
    required this.phoneNumber,
    required this.uid,
    required this.status,
  });

  UserModel.phone({required this.phoneNumber});
  UserModel.profile({required this.profilePic});
  UserModel.chatmain({
   required this.name,
   required this.profilePic,
   required this.updateAT,
   required this.uid,
   required this.main_text,
   required this.likeby,
   required this.comment_count,
    required this.status,
  });


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


 factory UserModel.frommain(Map<String, dynamic> map) {
   return UserModel.chatmain(
     name: map['name'] ?? map['name'] as String ?? '',
     uid: map['uid'] ?? map['uid'] as String ?? '',
     profilePic: map['profilePic'] ?? map['profilePic'] as String ?? '',
     updateAT: map['createdAt'] ?? map['createdAt'] as Timestamp ?? '',
     main_text: map['main_text'] ?? map['main_text'] as String ?? '',
     likeby: map['likeby'] ?? map['likeby'] as dynamic ?? '',
     comment_count: map['comment_count'] ?? map['comment_count'] as int ?? '',
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
