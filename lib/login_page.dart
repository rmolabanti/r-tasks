import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:url_launcher/url_launcher.dart';

import 'auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  _launchURL() async {
    const url = 'https://www.raghumolabanti.com/privacy-policy';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        leading: Image.asset('assets/rm_300_300_orange.png', fit: BoxFit.cover),
        title: const Text("RM Tasks"),
        backgroundColor: const Color.fromARGB(255,255,145,77),
      ),
      body: Container(
        width: size.width,
        height: size.height,
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: size.height * 0.2,
            bottom: size.height * 0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SignInButton(
              Buttons.Google,
              onPressed: () {
                AuthService().signInWithGoogle();
              },
            ),
            TextButton(
              onPressed: _launchURL,
              style: TextButton.styleFrom(backgroundColor: Colors.orange[50]),
              child: const Text('Privacy Policy'), // Button text
            ),
          ],
        ),
      ),
    );
  }
}
