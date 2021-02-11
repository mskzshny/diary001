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
    _displayDate = DateTime.now();
    this.getTodayDiary();
  }

  int _counter = 0;
  int get counter => _counter;

  Stream<QuerySnapshot> _diaryList;
  Stream<QuerySnapshot> get diaryList => _diaryList;

  String _diaryType = "";
  String get diaryType => _diaryType; 

  DateTime _displayDate;
  Timestamp get displayDate => Timestamp.fromDate(_displayDate); 

  void incrementCounter() {
    this._counter++;
    logger.v("provider.counter : " + this._counter.toString());
    notifyListeners();
  }

  void getTodayDiary() {
    logger.v("provider.counter : getTodayDiary");
    var viewDate = Timestamp.fromDate(DateTime.now()); // 現在の日時
    var yyyy = DateFormat('yyyy').format(viewDate.toDate());
    var mm = DateFormat('MM').format(viewDate.toDate());
    var dd = DateFormat('dd').format(viewDate.toDate());

    _diaryList = this.diaryMMddList(yyyy,mm,dd);
    _diaryType = "1年前,2年前,3年前,,,の今日の記事";
    _displayDate = viewDate.toDate();
    notifyListeners();
  }

  void getPrevDiary() {
    Timestamp viewDate = Timestamp.fromDate(this._displayDate.add(Duration(days: 1) * -1));
    var yyyy = DateFormat('yyyy').format(viewDate.toDate());
    var mm = DateFormat('MM').format(viewDate.toDate());
    var dd = DateFormat('dd').format(viewDate.toDate());

    logger.v("provider.counter : getTodayDiary");
    _diaryList = this.diaryMMddList(yyyy,mm,dd);
    _diaryType = "これまでの今日の記事";
    _displayDate = viewDate.toDate();
    notifyListeners();
  }

  void getTomorrowDiary() {
    Timestamp viewDate = Timestamp.fromDate(this._displayDate.add(Duration(days: 1) * 1));
    var yyyy = DateFormat('yyyy').format(viewDate.toDate());
    var mm = DateFormat('MM').format(viewDate.toDate());
    var dd = DateFormat('dd').format(viewDate.toDate());

    logger.v("provider.counter : getTodayDiary");
    _diaryList = this.diaryMMddList(yyyy,mm,dd);
    _diaryType = "これまでの今日の記事";
    _displayDate = viewDate.toDate();
    notifyListeners();
  }
    void getLatestDiary() {
    logger.v("provider.counter : getTodayDiary");
    _diaryList = this.diaryLatestList();
    _diaryType = "直近の日記";
    notifyListeners();

  }

  Stream<QuerySnapshot> diaryMMddList (String yyyy, String mm, String dd){

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