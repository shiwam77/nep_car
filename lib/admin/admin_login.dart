import 'package:bechdal_app/admin/admin_signup.dart';
import 'package:bechdal_app/components/large_heading_widget.dart';
import 'package:bechdal_app/constants/colors.dart';
import 'package:bechdal_app/services/auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../constants/validators.dart';
import '../constants/widgets.dart';

class AdminLoginScreen extends StatefulWidget {
  static const String screenId = 'admin_login_screen';
  const AdminLoginScreen({Key? key}) : super(key: key);

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: _body(),
    );
  }

  _body() {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        LargeHeadingWidget(
            size: 300,
            heading: 'Welcome To Admin DashBoard',
            subHeading: 'Sign In to Continue'),
        const LogInForm(),
      ]),
    );
  }
}

class LogInForm extends StatefulWidget {
  const LogInForm({
    Key? key,
  }) : super(key: key);

  @override
  State<LogInForm> createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  Auth authService = Auth();

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final FocusNode _emailNode;
  late final FocusNode _passwordNode;
  final _formKey = GlobalKey<FormState>();
  bool obsecure = true;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailNode = FocusNode();
    _passwordNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailNode.dispose();
    _passwordNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  focusNode: _emailNode,
                  controller: _emailController,
                  validator: (value) {
                    return validateEmail(
                        value, EmailValidator.validate(_emailController.text));
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your Email',
                      hintStyle: TextStyle(
                        color: greyColor,
                        fontSize: 12,
                      ),
                      contentPadding: const EdgeInsets.all(20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  focusNode: _passwordNode,
                  controller: _passwordController,
                  validator: (value) {
                    return validatePassword(value, _passwordController.text);
                  },
                  obscureText: obsecure,
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                          icon: Icon(
                            Icons.remove_red_eye_outlined,
                            color: obsecure ? greyColor : blackColor,
                          ),
                          onPressed: () {
                            setState(() {
                              obsecure = !obsecure;
                            });
                          }),
                      labelText: 'Password',
                      hintText: 'Enter Your Password',
                      hintStyle: TextStyle(
                        color: greyColor,
                        fontSize: 12,
                      ),
                      contentPadding: const EdgeInsets.all(20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
                // Container(
                //   alignment: Alignment.centerRight,
                //   padding: const EdgeInsets.only(
                //     top: 10,
                //     right: 5,
                //   ),
                //   child: InkWell(
                //     onTap: () {
                //       Navigator.pushNamed(
                //           context, ResetPasswordScreen.screenId);
                //     },
                //     child: Text(
                //       'Forgot Password ?',
                //       style: TextStyle(
                //         color: blackColor,
                //         fontSize: 13,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //   ),
                // ),
                const SizedBox(
                  height: 30,
                ),
                roundedButton(
                    context: context,
                    bgColor: secondaryColor,
                    text: 'Sign In',
                    textColor: whiteColor,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await authService.getAdminCredentialEmailAndPassword(
                            context: context,
                            email: _emailController.text,
                            password: _passwordController.text,
                            isLoginUser: true,
                            isAdmin: true);
                      }
                    }),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        RichText(
          text: TextSpan(
            text: 'Don\'t have an account? ',
            children: [
              TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.pushNamed(context, AdminRegisterScreen.screenId);
                  },
                text: 'Create new account',
                style: TextStyle(
                  fontFamily: 'Oswald',
                  fontSize: 14,
                  color: secondaryColor,
                ),
              )
            ],
            style: TextStyle(
              fontFamily: 'Oswald',
              fontSize: 14,
              color: greyColor,
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
