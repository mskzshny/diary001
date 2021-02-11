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

  DocumentSnapshot _document;

  // 入力した投稿メッセージ
  final _diaryTextController = new TextEditingController();
  TextEditingController get diaryTextController => _diaryTextController;

  AddPostViewModel(this.user, this._document ) {
    var viewDate;
    if( this._document == null ){
      viewDate = Timestamp.fromDate(DateTime.now()); // 現在の日時
    }
    else{
      viewDate = Timestamp.fromDate(this._document['diary_date'].toDate()); // 現在の日時
    }
    var yyyy = DateFormat('yyyy').format(viewDate.toDate());
    var mm = DateFormat('MM').format(viewDate.toDate());
    var dd = DateFormat('dd').format(viewDate.toDate());

    this._diaryTextController.text = "";

    if( this._document == null ){
      // 日記データの取得
      FirebaseFirestore.instance
        .collection('diary')
        .where('user_uid', isEqualTo: user.uid)
        .where('mm', isEqualTo: mm)
        .where('dd', isEqualTo: dd)
        .orderBy('diary_date', descending: true)
        .limit(1)
        .get()
        .then((QuerySnapshot querySnapshot) => {
          // なければ、新規作成あれば、テキストの設定
          if( querySnapshot.docs.length > 0 ) {
            querySnapshot.docs.forEach((doc) {
              if( doc["yyyy"] == yyyy ){
                this._diaryTextController.text = doc["diary"];
              }
            })
          }
        });
    }
    else{
      this._diaryTextController.text = this._document['diary'];
    }
    notifyListeners();
  }

  void setMessageText(String text){
    //_messageText = text;
    this._diaryTextController.text = text;
    notifyListeners();
  }

  void postDiary(User user, Timestamp postedDate) async {
    String yyyy = DateFormat('yyyy').format(postedDate.toDate());
    String mm = DateFormat('MM').format(postedDate.toDate());
    String dd = DateFormat('dd').format(postedDate.toDate());
    Timestamp tPostedDate = Timestamp.fromDate(postedDate.toDate());
    if( this._document != null ){
      yyyy = this._document['yyyy'];
      mm = this._document['mm'];
      dd = this._document['dd'];
      tPostedDate = Timestamp.fromDate(this._document['diary_date'].toDate());
    }

    // 投稿メッセージ用ドキュメント作成
    debugPrint( "postedDate : " + DateFormat('yyyy/MM/dd HH:mm').format(postedDate.toDate()) );
    logger.v("Verbose log");
    await FirebaseFirestore.instance.collection('diary').doc(DateFormat('yyyyMMdd').format(tPostedDate.toDate())+user.uid)
      .set({
        'user_uid': user.uid,
        'diary':  this._diaryTextController.text,
        'diary_date': tPostedDate,
        'yyyy': yyyy,
        'mm': mm,
        'dd': dd
      })
      .then((value){ 
        debugPrint( "post Added" );
      })
      .catchError((error){
        debugPrint( "Failed to add user: $error" );
      });
  }
}