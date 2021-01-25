import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import './add-post-page.dart';

// チャット画面用Widget
class ChatPage extends StatelessWidget {

  ChatPage(this.user);

  // ユーザー情報
  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( /* --- 省略 --- */ ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(8),
            child: Text('ログイン情報：${user.email}'),
          ),
          Expanded(
            // FutureBuilder
            // 非同期処理の結果を元にWidgetを作れる
            child: FutureBuilder<QuerySnapshot>(
              // 投稿メッセージ一覧を取得（非同期処理）
              // 投稿日時でソート
              future: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy('date')
                  .get(),
              builder: (context, snapshot) {
                // データが取得できた場合
                if (snapshot.hasData) {
                  final List<DocumentSnapshot> documents =
                      snapshot.data.docs;
                  // 取得した投稿メッセージ一覧を元にリスト表示
                  return ListView(
                    children: documents.map((document) {
                      String formattedDate = "";
                      if (document['date'] is Timestamp) {
                        debugPrint( "date is timestamp");
                        formattedDate = DateFormat('yyyy/MM/dd HH:mm').format(document['date'].toDate());
                      }
                      else{
                        debugPrint( "what is date ?");
                      }
                      return Card(
                        child: ListTile(
                          title: Text(document['text']),
                          subtitle: Text(formattedDate + ":" + document['email']),
                        ),
                      );
                    }).toList(),
                  );
                }
                // データが読込中の場合
                return Center(
                  child: Text('読込中...'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          // 投稿画面に遷移
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return AddPostPage(user);
            }),
          );
        },
      ),
    );
  }
}