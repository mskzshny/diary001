import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


var logger = Logger(
  printer: PrettyPrinter(),
);

class LoginViewModel extends ChangeNotifier {

  String _email = "";
  String get email => _email;

  String _password = "";
  String get password => _password;

  LoginViewModel(){
  }

  void setEamil(String email){
   this._email = email;
  }
  void setPassword(String password){
    this._password = password;
  }

  Future<UserCredential> doLogin( ) async {
    // メール/パスワードでログイン
    final FirebaseAuth auth = FirebaseAuth.instance;
    final UserCredential userCredential = await auth.signInWithEmailAndPassword(
      email: this._email,
      password: this._password,
    );
    return userCredential;
  }

}