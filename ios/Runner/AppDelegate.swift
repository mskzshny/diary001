import UIKit
import Flutter

import Firebase
// import FirebaseCore
// import FirebaseCoreDiagnostics
// import FirebaseCore
// import FirebaseAnalytics
import FirebaseAuth
import FirebaseFirestore

// import firebase_core
// import cloud_firestore
// import firebase_auth

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if FirebaseApp.app() == nil {
         FirebaseApp.configure()
     }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
