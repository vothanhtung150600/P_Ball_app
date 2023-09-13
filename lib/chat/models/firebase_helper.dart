import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/user_model.dart';

class FirebaseHelper {
  static Future<UserModel?> getUserModelById(String? uid) async {
    // log("id: $id");
    UserModel? userModel;
    Map<String, dynamic>? userMap;
    await FirebaseFirestore.instance
        .collection('users')
        .where("uid", isEqualTo: uid)
        .get()
        .then((value) {
      return userMap = value.docs[0].data();
    });

    if (userMap != null) {
      userModel = UserModel.fromMap(userMap as Map<String, dynamic>);
    } else {
      // log("snap data is null");
    }
    return userModel;
  }
}
