import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:quiver/async.dart'; // ①quiver.asyncライブラリを利用
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'login-page.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

// ログイン画面用Widget
class LoadingPage extends StatefulWidget  {
  
  LoadingPage( {Key key, this.title, this.context}) : super(key: key);

  final String title;
  final BuildContext context;
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {

  _LoadingPageState(){
    this.startTimer();
  }

  // ②カウントを示すインスタンス変数
  int _start = 0;
  int _current = 0;

  // ③ カウントダウン処理を行う関数を定義
  void startTimer() {
    CountdownTimer countDownTimer = new CountdownTimer(
      new Duration(seconds: _start), //初期値
      new Duration(seconds: 1), // 減らす幅
    );

    var sub = countDownTimer.listen(null);
    sub.onData((duration) {
      setState(() {
        _current = _start - duration.elapsed.inSeconds; //毎秒減らしていく
      });
    });

    // ④終了時の処理
    sub.onDone(() {
      logger.v("build : context : " + this.context.toString());
      sub.cancel();
      _current = 0;
      LoginPage.callLoginPage(this.context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // ⑤現在のカウントを表示
            Text("loading..." ),
            /*
            // ⑦カウントダウン関数を実行するボタン
            RaisedButton(
              onPressed: () {
                // startTimer();
                //LoginPage.callLoginPage(context);
              },
              child: Text("start"),
            ),*/
          ],
        ),
      ),
    );
  }

}
