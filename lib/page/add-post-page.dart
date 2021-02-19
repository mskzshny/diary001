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

  static void setCurrentThisPage(
      BuildContext context, User user, DocumentSnapshot document) async {
    await Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
      // ユーザー情報を渡す
      return MultiProvider(providers: [
        // Injects HomeViewModel into this widgets.
        ChangeNotifierProvider(create: (_) => AddPostViewModel(user, document)),
      ], child: AddPostPage(user));
    }));
  }
}

class _AddPostPageState extends State<AddPostPage> {
  _AddPostPageState(this.user);

  // ユーザー情報
  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('日記を書く'),
      ),
      body: Container(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
                child: TextFormField(
                    decoration: InputDecoration(labelText: ''),
                    // 複数行のテキスト入力
                    keyboardType: TextInputType.multiline,
                    // 最大3行
                    maxLines: null,
                    onChanged: (String value) {
                      setState(() {
                        //Provider.of<AddPostViewModel>(context, listen: false).setMessageText(value);
                      });
                    },
                    controller:
                        Provider.of<AddPostViewModel>(context, listen: false)
                            .diaryTextController)),
            Container(
              width: double.infinity,
              child: RaisedButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: Text('保存'),
                onPressed: () async {
                  final postedDate =
                      Timestamp.fromDate(DateTime.now()); // 現在の日時
                  Provider.of<AddPostViewModel>(context, listen: false)
                      .postDiary(user, postedDate);
                  // 1つ前の画面に戻る
                  DiaryPage.setBackThisPage(context, user);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
