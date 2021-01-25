import 'package:flutter/material.dart';

// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
void main() {
  debugPrint('main');
  runApp(App());
}
class App extends StatefulWidget {
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  // Set default `_initialized` and `_error` state to false
  bool _initialized = false;
  bool _error = false;

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    debugPrint('_AppState:initializeFlutterFire');
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch(e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
    //FirebaseAuth auth = FirebaseAuth.instance;
    // ユーザ登録
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: "masakazu.shinya@gmail.com",
        password: "SuperSecretPassword!"
      );
      debugPrint('createUserWithEmailAndPassword');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        debugPrint('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        debugPrint('The account already exists for that email.');
      }
    } catch (e) {
      debugPrint(e);
    }

    // ユーザ認証
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: "masakazu.shinya@gmail.com",
        password: "SuperSecretPassword!"
      );
      debugPrint('createUserWithEmailAndPassword');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }

    User user = FirebaseAuth.instance.currentUser;
    debugPrint( "user : " + user.email );
    debugPrint( "user : " + user.emailVerified.toString() );
    if (!user.emailVerified) {
      // メール認証
      await user.sendEmailVerification();
    }
    else{
      // 認証OK
      debugPrint( "useruid : " + user.uid);
    }

  }

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    // Show error message if initialization failed
    // if(_error) {
    //   return SomethingWentWrong();
    // }

    // Show a loader until FlutterFire is initialized
    // if (!_initialized) {
    //   return Loading();
    // }

    return  MaterialApp(
      title: 'ハロー。ゆずきさん。',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // home: MyHomePage(title: 'Flutter Demo Home Page'),
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('こんにちは新谷柚貴。動的？どこまで動的なのかしら。なのね'),
        ),
        body: new Center(
          child: new Text('ロードできているね。どこまでも動的に表示している。'),
        ),
      ),
    );
  }
}