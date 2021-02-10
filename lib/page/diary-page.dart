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

// Diary画面用Widget
class DiaryPage extends StatelessWidget  {

  // ユーザー情報
  final User user;

  DiaryPage(this.user){
  }


  void _handlePressed(){
  }

  @override
  Widget build(BuildContext context) {
    logger.v("build : user_uid : " + user.uid);

    return Scaffold(
      appBar: AppBar(  
        title: Text("Diary 001"),
        actions:[
          IconButton(
            icon: Icon(Icons.today),
            color: Colors.white,
          ),
          IconButton(
            icon: Icon(Icons.today),
            color: Colors.white,
            onPressed: Provider.of<DiaryViewModel>(context, listen: false).getTodayDiary,
          ),
          IconButton(
            icon: Icon(Icons.new_releases),
            color: Colors.white,
            onPressed: Provider.of<DiaryViewModel>(context, listen: false).getLatestDiary,
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
            child: Text(Provider.of<DiaryViewModel>(context).diaryType+" ログイン情報：${user.email}")
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: Provider.of<DiaryViewModel>(context).diaryList,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                String loadingMessage = '読込中...';
                // データが取得できた場合
                if (snapshot.hasData) {
                  final List<DocumentSnapshot> documents = snapshot.data.docs;
                  // 取得した投稿メッセージ一覧を元にリスト表示
                  return ListView(
                    children: documents.map((document) {
                      String formattedDate = "";
                      if (document['diary_date'] is Timestamp) {
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
                  loadingMessage = 'no data';

                }
                // データが読込中の場合
                return Center(
                  child: Text(loadingMessage),
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
      )
    );
  }
}

void callDiaryPage(BuildContext context, User user) async {
  await Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) {
      // ユーザー情報を渡す
      return MultiProvider(
        providers: [
          // Injects HomeViewModel into this widgets.
          ChangeNotifierProvider(create: (_) => DiaryViewModel(user)),
        ],
        child: DiaryPage(user)
      );
    }),
    (Route<dynamic> route) => false,
    );
}