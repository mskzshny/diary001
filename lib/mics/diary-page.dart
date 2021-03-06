import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'add-post-page.dart';
import 'diary-view-model.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

// チャット画面用Widget
class DiaryPage extends StatelessWidget  {


  DiaryPage(this.user);

  // ユーザー情報
  final User user;

  void _handlePressed(){
  }

/*
  @override
  void initState(){}

  @override
  State createState(){}
*/

  @override
  Widget build(BuildContext context) {
    logger.v("build : user_uid : " + user.uid);
    var viewDate = Timestamp.fromDate(DateTime.now()); // 現在の日時
    var yyyy = DateFormat('yyyy').format(viewDate.toDate());
    var mm = DateFormat('MM').format(viewDate.toDate());
    var dd = DateFormat('dd').format(viewDate.toDate());

    return Scaffold(
      appBar: AppBar(  
        title: Text("Diary 001"),
        actions:[
          IconButton(
            icon: Icon(Icons.android),
            color: Colors.white,
            onPressed: Provider.of<DiaryViewModel>(context, listen: false).incrementCounter,
          ),
          IconButton(
            icon: Icon(Icons.android),
            color: Colors.white,
            onPressed: Provider.of<DiaryViewModel>(context, listen: false).incrementCounter,
          ),
          IconButton(
            icon: Icon(Icons.android),
            color: Colors.white,
            onPressed: Provider.of<DiaryViewModel>(context, listen: false).incrementCounter,
          ),
        ]
      ), 
      
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(8),
            child: Text('ログイン情報：${user.email}'+Provider.of<DiaryViewModel>(context).counter.toString())
            //child: Text('ログイン情報：${user.email}')
          ),
          Expanded(
            
            // FutureBuilder
            // 非同期処理の結果を元にWidgetを作れる
            child: FutureBuilder<QuerySnapshot>(

              // 投稿メッセージ一覧を取得（非同期処理）
              // 投稿日時でソート
              future: FirebaseFirestore.instance
                  .collection('diary')
                  .where('user_uid', isEqualTo: user.uid)
                  .where('mm', isEqualTo: mm)
                  .where('dd', isEqualTo: dd)
                  .orderBy('diary_date', descending: true)
                  .limit(30)
                  .get(),
                  //.catchError((error) => print("Failed to add user: $error")),
                  /*
                  .collection('diary')
                  .where('user_uid', isEqualTo: user.uid)
                  .orderBy('diary_date', descending: true)
                  .limit(30)

                  .where('user_uid', isEqualTo: user.uid)
                  .where('user_uid', whereIn: [user.uid])
                  .orderBy('diary_date', descending: true)

                  .orderBy('user_uid').startAt([user.uid]).endAt([user.uid])
                  .orderBy('user_uid',   descending: true)
                  .orderBy('diary_date', descending: true)
                  .startAt([{'user_uid': user.uid}])
                  .limit(30)
                  .get(),
                  */
              builder: (context, snapshot) {
                logger.v("user_uid : " + user.uid);
                String loading_message = '読込中...';
                // データが取得できた場合
                if (snapshot.hasData) {
                  final List<DocumentSnapshot> documents =
                      snapshot.data.docs;
                  // 取得した投稿メッセージ一覧を元にリスト表示
                  return ListView(
                    children: documents.map((document) {
                      String formattedDate = "";
                      if (document['diary_date'] is Timestamp) {
                        debugPrint( "date is timestamp");
                        formattedDate = DateFormat('yyyy/MM/dd').format(document['diary_date'].toDate());
                      }
                      else{
                        debugPrint( "what is date ?");
                      }
                      return Card( 
                        child: InkWell(
                          child: ListTile(
                            title: Text(document['diary']),
                            subtitle: Text(formattedDate),
                          ),
                          onTap: Provider.of<DiaryViewModel>(context, listen: false).incrementCounter
                        )
                      );
                    }).toList(),
                  );
                }
                else {
                  logger.v("no data");
                  loading_message = 'no data';

                }
                // データが読込中の場合
                return Center(
                  child: Text(loading_message),
                );
              },
            ),
          ),
        ],
      ),
      /*
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          // rProvider.of<DiaryViewModel>(context, listen: false).incrementCounter();
          // 投稿画面に遷移
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return AddPostPage(user);
            }),
          );
        },
      )*/
    );
  }
}