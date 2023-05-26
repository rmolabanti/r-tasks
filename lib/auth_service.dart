import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'login_page.dart';
import 'AppHome.dart';

class AuthService {

  //Determine if the user is authenticated.
  handleAuthState() {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            log('User is signed in!');
            User? user = snapshot.data;
            if(user!=null){
              return AppHome(user:user);
            }
          }
          log('User is currently signed out!');
          return const LoginPage();
        });
  }

  Future<UserCredential> signInWithGoogle() async {
    // Create a new provider
    GoogleAuthProvider googleProvider = GoogleAuthProvider();
    //googleProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');
    //googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithPopup(googleProvider);
  }

  //Sign out
  signOut() {
    FirebaseAuth.instance.signOut();
  }
}
