import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'diary-page.dart';
import 'add-post-view-model.dart';

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
                maxLines: null,
                onChanged: (String value) {
                  setState(() {
                    Provider.of<AddPostViewModel>(context, listen: false).setMessageText(value);
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
                    final postedDate = Timestamp.fromDate(DateTime.now()); // 現在の日時
                    Provider.of<AddPostViewModel>(context, listen: false).postDiary(user,postedDate);
                    // 1つ前の画面に戻る
                    DiaryPage.callDiaryPage(context,user);
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

void callAddPostPage(BuildContext context, User user) async {
  await Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) {
      // ユーザー情報を渡す
      return MultiProvider(
        providers: [
          // Injects HomeViewModel into this widgets.
          ChangeNotifierProvider(create: (_) => AddPostViewModel(user)),
        ],
        child: AddPostPage(user)
      );
    }),
    (Route<dynamic> route) => false,
    );
}