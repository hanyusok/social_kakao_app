import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:social_kakao_app/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  fb.User? _user;
  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((event) {
      setState(() {
        _user = event;
      });
    });
  }

  /* navigate to loginpage */
  void navigateLogin() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  /* 카카오 로그아웃*/
  Future<void> logoutAsSns() async {
    try {
      await UserApi.instance.logout().then((value) {
        log('$value');
        /* firebase logout*/
        fb.FirebaseAuth.instance.signOut();
        log('firebase 로그아웃!');
        navigateLogin();
      });
      log('로그아웃 성공, SDK에서 토큰 삭제');
    } catch (error) {
      log('로그아웃 실패, SDK에서 토큰 삭제 $error');
    }
    fb.FirebaseAuth.instance.signOut();
    log('firebase 로그아웃!');
    navigateLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내용'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(_user!.displayName ?? '기본'),
          ),
          const SizedBox(
            height: 40,
          ),
          ElevatedButton(onPressed: logoutAsSns, child: const Text('로그아웃'))
        ],
      ),
    );
  }
}
