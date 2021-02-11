import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

class AddPostViewModel extends ChangeNotifier {
  // ユーザー情報
  final User user;

  // 入力した投稿メッセージ
  String _messageText = '';
  String get messageText => _messageText;

  AddPostViewModel(this.user){

  }

  void setMessageText(String text){
    _messageText = text;
    notifyListeners();
  }

  void postDiary(User user, Timestamp postedDate) async {
    final yyyy = DateFormat('yyyy').format(postedDate.toDate());
    final mm = DateFormat('MM').format(postedDate.toDate());
    final dd = DateFormat('dd').format(postedDate.toDate());

    // 投稿メッセージ用ドキュメント作成
    debugPrint( "postedDate : " + DateFormat('yyyy/MM/dd HH:mm').format(postedDate.toDate()) );
    logger.v("Verbose log");
    await FirebaseFirestore.instance.collection('diary').doc(DateFormat('yyyyMMdd').format(postedDate.toDate())+user.uid)
      .set({
        'user_uid': user.uid,
        'diary': this._messageText,
        'diary_date': postedDate,
        'yyyy': yyyy,
        'mm': mm,
        'dd': dd
      })
      .then((value) => print("post Added"))
      .catchError((error) => print("Failed to add user: $error"));
  }
}