import 'dart:developer';
// import 'dart:html';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:social_kakao_app/screens/home_screen.dart';
// import 'package:social_kakao_app/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  // final fb.User? _user;
  @override
  void initState() {
    super.initState();
    _auth.authStateChanges();
    // .listen((event) {
    //   setState(() {
    //     _user = event;
    //   });
    // });
  }

  /* navigate to homepage */
  void navigateHome() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()));
  }

  /* 카카오 로그인*/
  Future<void> loginAsKakao() async {
    // 카카오톡 실행 가능 여부 확인
    // 카카오톡 실행이 가능하면 카카오톡으로 로그인, 아니면 카카오계정으로 로그인
    if (await isKakaoTalkInstalled()) {
      try {
        OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
        log('카카오톡으로 로그인 성공');
        /* firebase Auth login ID token*/
        final provider = fb.OAuthProvider('oidc.socialkakao');
        final credential = provider.credential(
            idToken: token.idToken, accessToken: token.accessToken);
        _auth.signInWithCredential(credential).then((_) => navigateHome());
        log('firebase 로그인 성공');
        // });
      } catch (error) {
        log('카카오톡으로 로그인 실패 $error');

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
          log('카카오계정으로 로그인 성공');
          /* firebase Auth login ID token*/
          final provider = fb.OAuthProvider('oidc.socialkakao');
          final credential = provider.credential(
              idToken: token.idToken, accessToken: token.accessToken);
          _auth.signInWithCredential(credential).then((_) => navigateHome());

          log('firebase 로그인 성공');
        } catch (error) {
          log('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      try {
        OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
        log('카카오계정으로 로그인 성공');
        /* firebase Auth login ID token*/
        final provider = fb.OAuthProvider('oidc.socialkakao');
        final credential = provider.credential(
            idToken: token.idToken, accessToken: token.accessToken);
        _auth.signInWithCredential(credential).then((_) => navigateHome());

        log('firebase 로그인 성공');
      } catch (error) {
        log('카카오계정으로 로그인 실패 $error');
      }
    }
  }

  /* Google sign in*/
  Future<void> loginAsGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final googleCredential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      await _auth.signInWithCredential(googleCredential).then((value) {
        log('$value');
        navigateHome();
      });
    } catch (e) {
      //
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(onPressed: loginAsKakao, child: const Text('카카오로그인')),
          const SizedBox(
            height: 40,
          ),
          // ElevatedButton(
          //     onPressed: loginAsGoogle, child: const Text('Google Sign')),
          SignInButton(Buttons.google, onPressed: loginAsGoogle)
        ],
      ),
    );
  }
}
