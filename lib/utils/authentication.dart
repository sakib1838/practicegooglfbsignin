
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authentication{


  static Future<FirebaseApp> initializeFirebase({
    required BuildContext context,
  }) async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    // User? user = FirebaseAuth.instance.currentUser;
    //
    // if (user != null) {
    //   print(user.email);
    //   print(user.phoneNumber);
    //   print(user.displayName);
    // }

    return firebaseApp;
  }


  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
    await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
        await auth.signInWithCredential(credential);

        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          // handle the error here
        }
        else if (e.code == 'invalid-credential') {
          // handle the error here
        }
      } catch (e) {
        // handle the error here
      }
    }

    return user;
  }


  static Future<void> signOut({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        Authentication.customSnackBar(
          content: 'Error signing out. Try again.',
        ),
      );
    }
  }

  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }


 static Future<Resource?> signInWithFacebook({required BuildContext context}) async {
   FirebaseAuth _auth = FirebaseAuth.instance;


    try {

      final _instance = FacebookAuth.instance;
      final result = await _instance.login(permissions: ['email']);

      switch (result.status) {
        case LoginStatus.success:
          final OAuthCredential facebookCredential =
          FacebookAuthProvider.credential(result.accessToken!.token);
          //final userCredential =
          // await _auth.signInWithCredential(facebookCredential);
          // print(userCredential.user);
          //return userCredential.user;
          final a = await _auth.signInWithCredential(facebookCredential);
          print(a.user);
          await _instance.getUserData().then((userData) async {
            print(userData);
            await _auth.currentUser!.updateEmail(userData['email']);
          });

          return Resource(status: Status.Success);
        case LoginStatus.cancelled:
          return Resource(status: Status.Cancelled);
        case LoginStatus.failed:
          return Resource(status: Status.Error);
        default:
          return null;
      }

      // final result = await FacebookAuth.i.login(
      //   permissions: ['email', 'public_profile', 'user_birthday', 'user_friends', 'user_gender', 'user_link'],
      // );
      // if (result.status == LoginStatus.success) {
      //   final userData = await FacebookAuth.i.getUserData(
      //     fields: "name,email,picture.width(200),birthday,friends,gender,link",
      //   );
      // }
      // print(_userData);

    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

 // static Future<UserCredential?> signInWithFacebook() async {
 //    final LoginResult result = await FacebookAuth.getInstance().login();
 //    if(result.status == LoginStatus.success){
 //      // Create a credential from the access token
 //      final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.token);
 //      // Once signed in, return the UserCredential
 //      return await FirebaseAuth.instance.signInWithCredential(credential);
 //    }
 //    return null;
 //  }



}

class Resource{

  final Status status;
  Resource({required this.status});
}

enum Status {
  Success,
  Error,
  Cancelled
}