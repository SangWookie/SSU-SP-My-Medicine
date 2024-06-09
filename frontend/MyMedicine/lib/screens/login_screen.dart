import 'package:flutter/material.dart';
import 'package:medicineapp/screens/home_screen.dart';
import 'package:medicineapp/screens/signup_screen.dart';
import 'package:medicineapp/widgets/text_field_set.dart';
import 'package:medicineapp/services/api_services.dart';
// import 'package:medicineapp/widgets/prescription_widget.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final Function func;

  LoginScreen({
    Key? key,
    required this.func,
  }) : super(key: key);

  // ApiService 인스턴스 생성
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/logos/MM_logo.png',
                    width: 250,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextFieldSet(
                    usernameController: usernameController,
                    passwordController: passwordController,
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        // 아이디와 비밀번호 가져오기
                        String username = usernameController.text;
                        String password = passwordController.text;

                        // 아이디와 비밀번호가 비어있는지 확인
                        if (username.isEmpty || password.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('아이디와 비밀번호를 입력하세요.'),
                            ),
                          );
                          return;
                        }
                        // 서버에 로그인 요청 보내기
                        int uid = await _apiService.login(username, password);
                        // int uid = 1;
                        if (uid == -401) {
                          //비밀번호 불일치
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('비밀번호가 올바르지 않습니다.'),
                            ),
                          );
                        } else if (uid == -409) {
                          //존재하지 않는 아이디
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('존재하지 않는 아이디입니다.'),
                            ),
                          );
                          // 로그인 성공 시 홈 화면으로 이동
                        } else if (uid != -1) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(
                                uid: uid,
                                func: func,
                              ),
                            ),
                          );
                        } else {
                          // 로그인 실패 시 에러 메시지 표시
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('로그인에 실패했습니다.\n다시 시도해주세요.'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        '로그인',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpScreen()),
                          );
                        },
                        child: const Text(
                          '회원가입',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
