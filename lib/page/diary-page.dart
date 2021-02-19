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
class DiaryPage extends StatelessWidget {
  // ユーザー情報
  final User user;

  DiaryPage(this.user) {}

  @override
  Widget build(BuildContext context) {
    logger.v("build : user_uid : " + user.uid);

    return Scaffold(
        appBar: AppBar(title: Text("Diary 001"), actions: [
          // 前の日の日記を表示
          IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: Provider.of<DiaryViewModel>(context, listen: false)
                .getPrevDiary,
          ),
          // 今日の日記を表示
          IconButton(
              icon: Icon(Icons.today),
              color: Colors.white,
              //onPressed: Provider.of<DiaryViewModel>(context, listen: false)
              //    .getTodayDiary,
              onPressed: () => _selectDate(context)),
          // 次の日の日記を表示
          IconButton(
            icon: Icon(Icons.arrow_forward),
            color: Colors.white,
            onPressed: Provider.of<DiaryViewModel>(context, listen: false)
                .getTomorrowDiary,
          ),
          // 最新の日記を表示
          IconButton(
            icon: Icon(Icons.new_releases),
            color: Colors.white,
            onPressed: Provider.of<DiaryViewModel>(context, listen: false)
                .getLatestDiary,
          ),
        ]),
        body: Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(8),
                child: Text("これまでの" +
                    DateFormat('MM月dd日').format(
                        Provider.of<DiaryViewModel>(context)
                            .displayDate
                            .toDate()))),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: Provider.of<DiaryViewModel>(context).diaryList,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  String loadingMessage = 'loading...';
                  // Diaryがない場合、取得できなかった場合。
                  loadingMessage = 'no data';

                  // データ取得判定
                  if (snapshot.hasData) {
                    // データが取得できた場合
                    final List<DocumentSnapshot> documents = snapshot.data.docs;
                    // 取得したDiary一覧をリスト表示
                    return ListView(
                      children: documents.map((document) {
                        String formattedDate = "";
                        if (document['diary_date'] is Timestamp) {
                          formattedDate = DateFormat('yyyy/MM/dd')
                              .format(document['diary_date'].toDate());
                        } else {
                          debugPrint("what is date ?");
                        }
                        return Card(
                            child: InkWell(
                          child: ListTile(
                            title: Text(formattedDate),
                            subtitle: Text(document['diary']),
                          ),
                          onLongPress: () {
                            logger.v("onLongPress");
                            AddPostPage.setCurrentThisPage(
                                context, user, document);
                          },
                        ));
                      }).toList(),
                    );
                  } else {
                    // Diaryがない場合、取得できなかった場合。
                    logger.v("no data");
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
              AddPostPage.setCurrentThisPage(context, user, null);
            }));
  }

  // 表示する日付の選択。
  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: new DateTime(2016),
        lastDate: new DateTime.now().add(new Duration(days: 360)));
    if (picked != null) {
      Provider.of<DiaryViewModel>(context, listen: false)
          .getSelectedDateDiary(picked);
    }
  }

  static void setCurrentThisPage(BuildContext context, User user) async {
    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) {
        // ユーザー情報を渡す
        return MultiProvider(providers: [
          // Injects HomeViewModel into this widgets.
          ChangeNotifierProvider(create: (_) => DiaryViewModel(user)),
        ], child: DiaryPage(user));
      }),
      (Route<dynamic> route) => false,
    );
  }

  static void setBackThisPage(BuildContext context, User user) async {
    await Navigator.pop(context);
    // Provider.of<DiaryViewModel>(context, listen: false).reflesh();
  }
}
