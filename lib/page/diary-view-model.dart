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
  // ユーザー情報
  final User user;

  DiaryViewModel(this.user){
    this.getTodayDiary();
  }

  int _counter = 0;
  int get counter => _counter;

  Stream<QuerySnapshot> _diaryList;
  Stream<QuerySnapshot> get diaryList => _diaryList;

  String _diaryType = "";
  String get diaryType => _diaryType; 

  void incrementCounter() {
    this._counter++;
    logger.v("provider.counter : " + this._counter.toString());
    notifyListeners();
  }

  void getTodayDiary() {
    logger.v("provider.counter : getTodayDiary");
    _diaryList = this.diaryMMddList();
    _diaryType = "1年前,2年前,3年前,,,の今日の記事";
    notifyListeners();
  }

  void getLatestDiary() {
    logger.v("provider.counter : getTodayDiary");
    _diaryList = this.diaryLatestList();
    _diaryType = "直近の日記";
    notifyListeners();

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

  Stream<QuerySnapshot> diaryLatestList () {
    return FirebaseFirestore.instance
        .collection('diary')
        .where('user_uid', isEqualTo: user.uid)
        .orderBy('diary_date', descending: true)
        .limit(30).snapshots();
  }

  void dispose() {
  }
}