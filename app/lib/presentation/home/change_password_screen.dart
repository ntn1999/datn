import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_demo/configs/colors.dart';

import '../../blocs/change_password/change_password_bloc.dart';
import '../../datasource/network/apis.dart';
import '../login/login_screen.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) =>
                ChangePasswordBloc(ChangePasswordInitState(), Api()))
      ],
      child: const BodyChangePassword(),
    );
  }
}

class BodyChangePassword extends StatefulWidget {
  const BodyChangePassword({Key? key}) : super(key: key);

  @override
  _BodyChangePasswordState createState() => _BodyChangePasswordState();
}

class _BodyChangePasswordState extends State<BodyChangePassword> {
  int currentPos = 0;
  final List<String> imageList = [
    "assets/images/introduce1.jpg",
    "assets/images/introduce2.png",
    "assets/images/introduce3.jpg",
  ];

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController passwordNew = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  late bool _obscureText;
  late bool _obscureText2;

  ChangePasswordBloc? loginBloc;
  Api? api;

  @override
  void initState() {
    loginBloc = BlocProvider.of<ChangePasswordBloc>(context);
    _obscureText = false;
    _obscureText2 = false;
  }

  void _passwordVisible() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _passwordNewVisible() {
    setState(() {
      _obscureText2 = !_obscureText2;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final msg = BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
        builder: (context, state) {
      if (state is ChangePasswordLoadingState) {
        return const CircularProgressIndicator();
      } else if (state is ChangePasswordErrorState) {
        return Text(
          state.message,
          style: TextStyle(color: Colors.red),
        );
      } else {
        return Container();
      }
    });

    return Scaffold(
      body: BlocListener<ChangePasswordBloc, ChangePasswordState>(
        listener: (context, state) {
          if (state is ChangePasswordSuccessState) {
            showAlertDialog(context);
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => LoginScreen()),
            // );
          }
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
          color: Colors.white,
          constraints: const BoxConstraints.expand(),
          child: SingleChildScrollView(
            child: Form(
              key: _formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.height * 0.08,
                  ),
                  Text(
                    'Change password',
                    style: Theme.of(context).textTheme.caption!.copyWith(
                          color: Colors.blue,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(
                    height: size.height * 0.08,
                  ),
                  TextFormField(
                    controller: email,
                    onChanged: (value) {
                      _formkey.currentState!.validate();
                    },
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return 'Please a Enter';
                      } else if (!RegExp(
                              r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+(.)+[a-zA-Z0-9-]*$')
                          .hasMatch(value)) {
                        return 'Please a valid Email';
                      }
                    },
                    onSaved: (String? value) {
                      email = value as TextEditingController;
                    },
                    cursorColor: kPrimaryColor,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.person,
                        color: kPrimaryColor,
                      ),
                      hintText: "Email",
                      labelText: "Email",
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xffCED0D2), width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(6))),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: password,
                    obscureText: !_obscureText,
                    onChanged: (value) {
                      _formkey.currentState!.validate();
                    },
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return 'Please a Enter Password';
                      } else if (value!.length < 6) {
                        return 'password is too short ';
                      }
                      return null;
                    },
                    cursorColor: kPrimaryColor,
                    decoration: InputDecoration(
                      hintText: "Mật khẩu cũ",
                      labelText: "Mật khẩu cũ",
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: kPrimaryColor,
                      ),
                      suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: kPrimaryColor,
                          ),
                          onPressed: _passwordVisible),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: const Color(0xffCED0D2).withOpacity(0.2)),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(6))),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: passwordNew,
                    obscureText: !_obscureText2,
                    onChanged: (value) {
                      _formkey.currentState!.validate();
                    },
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return 'Please a Enter Password';
                      } else if (value!.length < 6) {
                        return 'password is too short ';
                      }
                      return null;
                    },
                    cursorColor: kPrimaryColor,
                    decoration: InputDecoration(
                      hintText: "Mật khẩu mới",
                      labelText: "Mật khẩu mới",
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: kPrimaryColor,
                      ),
                      suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText2
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: kPrimaryColor,
                          ),
                          onPressed: _passwordNewVisible),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: const Color(0xffCED0D2).withOpacity(0.2)),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(6))),
                    ),
                  ),
                  SizedBox(
                    height: 64,
                  ),
                  SizedBox(
                    width: size.width,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                      child: ElevatedButton(
                        child: const Text(
                          "Change Password",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          if (_formkey.currentState!.validate()) {
                            return loginBloc!.add(ChangePasswordButtonPressed(
                                email: email.text,
                                oldPassword: password.text,
                                newPassword: passwordNew.text));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            primary: kPrimaryColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 20),
                            textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: msg,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Change success"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
