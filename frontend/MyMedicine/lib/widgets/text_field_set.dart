import 'package:flutter/material.dart';

class TextFieldSet extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  TextFieldSet({
    required this.usernameController,
    required this.passwordController,
    Key? key,
  }) : super(key: key);

  final FocusNode usernameFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.deepPurple[50],
      ),
      child: Column(
        children: [
          LoginTextField(
            controller: usernameController,
            hintText: '아이디',
            obscureText: false,
            focusNode: usernameFocusNode,
            nextFocusNode: passwordFocusNode,
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: const Divider(
              height: 1,
            ),
          ),
          LoginTextField(
            controller: passwordController,
            hintText: '비밀번호',
            obscureText: true,
            focusNode: passwordFocusNode,
          ),
        ],
      ),
    );
  }
}

class LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;

  const LoginTextField({
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.focusNode,
    this.nextFocusNode,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      focusNode: focusNode,
      textInputAction:
          nextFocusNode != null ? TextInputAction.next : TextInputAction.done,
      onFieldSubmitted: (_) {
        if (nextFocusNode != null) {
          FocusScope.of(context).requestFocus(nextFocusNode);
        }
      },
      style: const TextStyle(
        fontSize: 15,
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        border: InputBorder.none,
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 15,
          color: Colors.grey,
        ),
      ),
    );
  }
}
