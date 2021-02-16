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

// 日記データ
class DiaryViewModel extends ChangeNotifier {
  // ユーザー情報
  final User user;

  // コンストラクタ
  DiaryViewModel(this.user) {
    _displayDate = DateTime.now();
    this.getTodayDiary();
  }

  // 日記一覧保持する
  Stream<QuerySnapshot> _diaryList;
  Stream<QuerySnapshot> get diaryList => _diaryList;

  // 取得する日記のタイプを保持する
  String _diaryType = "";
  String get diaryType => _diaryType;

  // 日記で表示する日付を保持する。
  DateTime _displayDate;
  Timestamp get displayDate => Timestamp.fromDate(_displayDate);

  // 今日の日記を取得する。
  void getTodayDiary() {
    logger.v("DiaryViewModel.getTodayDiary");
    var viewDate = Timestamp.fromDate(DateTime.now()); // 現在の日時
    var yyyy = DateFormat('yyyy').format(viewDate.toDate());
    var mm = DateFormat('MM').format(viewDate.toDate());
    var dd = DateFormat('dd').format(viewDate.toDate());

    _diaryList = this.diaryMMddList(yyyy, mm, dd);
    _diaryType = "1年前,2年前,3年前,,,の今日の記事";
    _displayDate = viewDate.toDate();
    notifyListeners();
  }

  // 前日の日記を取得する。
  void getPrevDiary() {
    logger.v("DiaryViewModel.getPrevDiary");
    Timestamp viewDate =
        Timestamp.fromDate(this._displayDate.add(Duration(days: 1) * -1));
    var yyyy = DateFormat('yyyy').format(viewDate.toDate());
    var mm = DateFormat('MM').format(viewDate.toDate());
    var dd = DateFormat('dd').format(viewDate.toDate());

    _diaryList = this.diaryMMddList(yyyy, mm, dd);
    _diaryType = "これまでの今日の記事";
    _displayDate = viewDate.toDate();
    notifyListeners();
  }

  // 翌日の日記を取得する。
  void getTomorrowDiary() {
    logger.v("DiaryViewModel.getTomorrowDiary");
    Timestamp viewDate =
        Timestamp.fromDate(this._displayDate.add(Duration(days: 1) * 1));
    var yyyy = DateFormat('yyyy').format(viewDate.toDate());
    var mm = DateFormat('MM').format(viewDate.toDate());
    var dd = DateFormat('dd').format(viewDate.toDate());

    _diaryList = this.diaryMMddList(yyyy, mm, dd);
    _diaryType = "これまでの今日の記事";
    _displayDate = viewDate.toDate();
    notifyListeners();
  }

  // 指定する日付の日記を取得する。
  void getSelectedDateDiary(DateTime selectedDate) {
    logger.v("DiaryViewModel.getSelectedDateDiary");
    Timestamp viewDate = Timestamp.fromDate(selectedDate);
    var yyyy = DateFormat('yyyy').format(viewDate.toDate());
    var mm = DateFormat('MM').format(viewDate.toDate());
    var dd = DateFormat('dd').format(viewDate.toDate());

    _diaryList = this.diaryMMddList(yyyy, mm, dd);
    _diaryType = "これまでの今日の記事";
    _displayDate = viewDate.toDate();
    notifyListeners();
  }

  // 直近の日記を取得する。
  void getLatestDiary() {
    logger.v("DiaryViewModel.getTodayDiary");
    _diaryList = this.diaryLatestList();
    _diaryType = "直近の日記";
    notifyListeners();
  }

  // 所定の日付の日記を取得する。
  Stream<QuerySnapshot> diaryMMddList(String yyyy, String mm, String dd) {
    return FirebaseFirestore.instance
        .collection('diary')
        .where('user_uid', isEqualTo: user.uid)
        .where('mm', isEqualTo: mm)
        .where('dd', isEqualTo: dd)
        .orderBy('diary_date', descending: true)
        .limit(30)
        .snapshots();
  }

  // 最近の日記を取得する
  Stream<QuerySnapshot> diaryLatestList() {
    logger.v("DiaryViewModel.diaryLatestList");
    return FirebaseFirestore.instance
        .collection('diary')
        .where('user_uid', isEqualTo: user.uid)
        .orderBy('diary_date', descending: true)
        .limit(30)
        .snapshots();
  }

  // リロードする
  void reflesh() {
    logger.v("provider.counter : reflesh");
    notifyListeners();
  }

  void dispose() {}
}
