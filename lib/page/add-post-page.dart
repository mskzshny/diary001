import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import 'diary-page.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

// 投稿画面用Widget
class AddPostPage extends StatefulWidget {
  // 引数からユーザー情報を受け取る
  AddPostPage(this.user);
  // ユーザー情報
  final User user;
  @override
  _AddPostPageState createState() => _AddPostPageState(user);
}
class _AddPostPageState extends State<AddPostPage> {

  _AddPostPageState(this.user);

  // ユーザー情報
  final User user;

  // 入力した投稿メッセージ
  String messageText = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('チャット投稿'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // 投稿メッセージ入力
              TextFormField(
                decoration: InputDecoration(labelText: '投稿メッセージ'),
                // 複数行のテキスト入力
                keyboardType: TextInputType.multiline,
                // 最大3行
                maxLines: 3,
                onChanged: (String value) {
                  setState(() {
                    messageText = value;
                  });
                },
              ),
              Container(
                width: double.infinity,
                child: RaisedButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: Text('投稿'),
                  onPressed: () async {
                    final postedDate =
                        Timestamp.fromDate(DateTime.now()); // 現在の日時
                    final yyyy = DateFormat('yyyy').format(postedDate.toDate());
                    final mm = DateFormat('MM').format(postedDate.toDate());
                    final dd = DateFormat('dd').format(postedDate.toDate());

                    // 投稿メッセージ用ドキュメント作成
                    debugPrint( "postedDate : " + DateFormat('yyyy/MM/dd HH:mm').format(postedDate.toDate()) );
                    logger.v("Verbose log");
                    await FirebaseFirestore.instance.collection('diary').doc(DateFormat('yyyyMMdd').format(postedDate.toDate())+user.uid)
                      .set({
                        'user_uid': user.uid,
                        'diary': messageText,
                        'diary_date': postedDate,
                        'yyyy': yyyy,
                        'mm': mm,
                        'dd': dd
                      })
                      .then((value) => print("post Added"))
                      .catchError((error) => print("Failed to add user: $error"));
                    // 1つ前の画面に戻る
                    /*
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        return DiaryPage(user);
                      }),
                    );
                    */
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => DiaryPage(user)),
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}