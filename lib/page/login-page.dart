import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'diary-page.dart';
import 'login-view-model.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

// ログイン画面用Widget
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();

  static void callLoginPage(BuildContext context) async {
    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) {
        // ユーザー情報を渡す
        return MultiProvider(
          providers: [
            // Injects HomeViewModel into this widgets.
            ChangeNotifierProvider(create: (_) => LoginViewModel()),
          ],
          child: LoginPage()
        );
      }),
      (Route<dynamic> route) => false,
      );
  }
}

class _LoginPageState extends State<LoginPage> {
  // メッセージ表示用
  // String infoText = '';

  // 入力したメールアドレス・パスワード
  // String email = '';
  // String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // メールアドレス入力
              TextFormField(
                decoration: InputDecoration(labelText: 'メールアドレス'),
                onChanged: (String value) {
                  setState(() {
                    // email = value;
                    Provider.of<LoginViewModel>(context, listen: false).setEmail(value);
                  });
                },
              ),
              // パスワード入力
              TextFormField(
                decoration: InputDecoration(labelText: 'パスワード'),
                obscureText: true,
                onChanged: (String value) {
                  setState(() {
                    //password = value;
                    Provider.of<LoginViewModel>(context, listen: false).setPassword(value);
                  });
                },
              ),
              Container(
                padding: EdgeInsets.all(8),
                // メッセージ表示
                child: Text( Provider.of<LoginViewModel>(context, listen: false).infoText),
              ),
              Container(
                width: double.infinity,
                // ユーザー登録ボタン
                child: RaisedButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: Text('ユーザー登録'),
                  onPressed: () async {
                    logger.v("onPressed: " );
                    try {
                      UserCredential userCredential = await Provider.of<LoginViewModel>(context, listen: false).createUser();
                      // ユーザー登録に成功した場合
                      // チャット画面に遷移＋ログイン画面を破棄
                      DiaryPage.callDiaryPage(context,userCredential.user);
                    } catch (e) {
                      // ユーザー登録に失敗した場合
                      setState(() {
                        Provider.of<LoginViewModel>(context, listen: false).setInfoText("登録に失敗しました：${e.message}");
                      });
                    }
                  },
                ),
              ),
              Container(
                width: double.infinity,
                // ログイン登録ボタン
                child: OutlineButton(
                  textColor: Colors.blue,
                  child: Text('ログイン'),
                  onPressed: () async {
                    logger.v("onPressed: " );
                    try {
                      // メール/パスワードでログイン
                      UserCredential userCredential = await Provider.of<LoginViewModel>(context, listen: false).doLogin();
                      // ログインに成功した場合
                      // チャット画面に遷移＋ログイン画面を破棄
                      DiaryPage.callDiaryPage(context,userCredential.user);
                    } catch (e) {
                      // ユーザー登録に失敗した場合
                      setState(() {
                        Provider.of<LoginViewModel>(context, listen: false).setInfoText("ログインに失敗しました：${e.message}");
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}



