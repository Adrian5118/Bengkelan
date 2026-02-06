import 'dart:convert';

import 'package:bengkelan/lib/db/handler.dart';
import 'package:bengkelan/lib/widget_theme.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 32, vertical: 60),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text(
                  "Log In",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const Padding(
                  padding: EdgeInsetsGeometry.symmetric(vertical: 18),
                ),
                const Text("Username"),
                Expanded(
                  child: TextFormField(
                    controller: _usernameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your username";
                      }

                      return null;
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsetsGeometry.symmetric(vertical: 8),
                ),
                const Text("Password"),
                Expanded(
                  child: TextFormField(
                    obscureText: true,
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your password";
                      }

                      return null;
                    },
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "Forgot password?",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                const Padding(
                  padding: EdgeInsetsGeometry.symmetric(vertical: 18),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            var pwBytes = utf8.encode(_passwordController.text);
                            var pwDigest = sha256.convert(pwBytes);

                            int? credId;
                            await DatabaseHandler.get()
                                .getOne(
                                  table: "user_credential",
                                  where: {
                                    "username": _usernameController.text,
                                    "password": pwDigest.toString(),
                                  },
                                )
                                .then((val) {
                                  credId = val["id"] as int?;
                                });

                            if (credId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Incorrect username or password!",
                                  ),
                                ),
                              );

                              return;
                            }

                            Navigator.of(context).pushReplacementNamed(
                              "/dashboard",
                              arguments: {"userId": credId},
                            );
                          }
                        },
                        style: ButtonStyle(backgroundColor: LoginButtonColor()),
                        child: const Text("Log In"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed("/register");
                        },
                        style: ButtonStyle(
                          backgroundColor: RegisterButtonColor(),
                        ),
                        child: const Text("Register"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
