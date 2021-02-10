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

class DiaryViewModel extends ChangeNotifier {
  DiaryViewModel(this.user);

  // ユーザー情報
  final User user;

  int _counter = 0;
  int get counter => _counter;

  final _actionController = StreamController<void>();
  Sink<void> get increment => _actionController.sink;

  final _countController = StreamController<QuerySnapshot>();
  //Stream<QuerySnapshot> get diaryList => _countController.stream;

  Stream<QuerySnapshot> _diaryList;

  Stream<QuerySnapshot> get diaryList => _diaryList;

  Stream<QuerySnapshot> diaryLatestList () {
    return FirebaseFirestore.instance
        .collection('diary')
        .where('user_uid', isEqualTo: user.uid)
        .orderBy('diary_date', descending: true)
        .limit(30).snapshots();
  }

  Stream<QuerySnapshot> diaryMMddList (){
    var viewDate = Timestamp.fromDate(DateTime.now()); // 現在の日時
    var yyyy = DateFormat('yyyy').format(viewDate.toDate());
    var mm = DateFormat('MM').format(viewDate.toDate());
    var dd = DateFormat('dd').format(viewDate.toDate());


    return FirebaseFirestore.instance
        .collection('diary')
        .where('user_uid', isEqualTo: user.uid)
        .where('mm', isEqualTo: mm)
        .where('dd', isEqualTo: dd)
        .orderBy('diary_date', descending: true)
        .limit(30).snapshots();
  }

  void incrementCounter() {
    this._counter++;
    logger.v("provider.counter : " + this._counter.toString());
    notifyListeners();
  }

  void getTodayDiary() {
    logger.v("provider.counter : getTodayDiary");
    _diaryList = this.diaryMMddList();
    notifyListeners();

  }

  void getLatestDiary() {
    logger.v("provider.counter : getTodayDiary");
    _diaryList = this.diaryLatestList();
    notifyListeners();

  }

/*
  void getTodayDiary(String user_uid, String mm, String dd){
    FirebaseFirestore.instance
      .collection('diary')
      .where('user_uid', isEqualTo: user_uid)
      .where('mm', isEqualTo: mm)
      .where('dd', isEqualTo: dd)
      .orderBy('diary_date', descending: true)
      .limit(30)
      .then( 
        this.diaryList = value
      );
  }*/
  void dispose() {
    _actionController.close();
    _countController.close();
  }
}