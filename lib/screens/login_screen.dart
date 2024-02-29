import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:social_kakao_app/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late bool isLogged = false;

  @override
  void initState() {
    super.initState();
  }

  Future<bool> checkToken() async {
    try {
      AccessTokenInfo tokenInfo = await UserApi.instance.accessTokenInfo();
      log('토큰 유효성 체크 성공 ${tokenInfo.id} ${tokenInfo.expiresIn}');
      return true;
    } catch (e) {
      if (e is KakaoException && e.isInvalidTokenError()) {
        log('토큰 만료 $e');
        return false;
      } else {
        log('토큰 정보 조회 실패 $e');
        return false;
      }
    }
  }

  /* 카카오 로그인*/
  Future<void> loginAsKakao() async {
    // 카카오톡 실행 가능 여부 확인
    // 카카오톡 실행이 가능하면 카카오톡으로 로그인, 아니면 카카오계정으로 로그인
    if (await isKakaoTalkInstalled()) {
      try {
        await UserApi.instance.loginWithKakaoTalk();

        log('카카오톡으로 로그인 성공');
      } catch (error) {
        log('카카오톡으로 로그인 실패 $error');

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          await UserApi.instance.loginWithKakaoAccount();

          log('카카오계정으로 로그인 성공');
        } catch (error) {
          log('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      try {
        await UserApi.instance.loginWithKakaoAccount();

        log('카카오계정으로 로그인 성공');
      } catch (error) {
        log('카카오계정으로 로그인 실패 $error');
      }
    }
  }

  /* 카카오 로그아웃*/
  Future<void> logoutAskakao() async {
    try {
      await UserApi.instance.logout();
      log('로그아웃 성공, SDK에서 토큰 삭제');
    } catch (error) {
      log('로그아웃 실패, SDK에서 토큰 삭제 $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return checkToken()
        ? const HomeScreen()
        : Scaffold(
            appBar: AppBar(
              title: const Text('로그인'),
              centerTitle: true,
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: loginAsKakao, child: const Text('카카오로그인')),
                const SizedBox(
                  height: 40,
                ),
                ElevatedButton(
                    onPressed: logoutAskakao, child: const Text('카카오로그아웃'))
              ],
            ),
          );
  }
}
