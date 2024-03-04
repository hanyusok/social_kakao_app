import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:social_kakao_app/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /* navigate to loginpage */
  void navigateLogin() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  /* 카카오 로그아웃*/
  Future<void> logoutAskakao() async {
    try {
      await UserApi.instance.logout().then((value) {
        log('$value');
        navigateLogin();
      });
      log('로그아웃 성공, SDK에서 토큰 삭제');
    } catch (error) {
      log('로그아웃 실패, SDK에서 토큰 삭제 $error');
    }
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
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('내용'),
          ),
          const SizedBox(
            height: 40,
          ),
          ElevatedButton(onPressed: logoutAskakao, child: const Text('카카오로그아웃'))
        ],
      ),
    );
  }
}
