import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iot_demo/blocs/login/login_bloc.dart';
import 'package:iot_demo/configs/colors.dart';
import 'package:iot_demo/presentation/home/home_screen.dart';
import 'package:iot_demo/presentation/signup/signup_screen.dart';

import '../../datasource/network/apis.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LoginBloc(LoginInitState(), Api()))
      ],
      child: const BodyLogin(),
    );
  }
}

class BodyLogin extends StatefulWidget {
  const BodyLogin({Key? key}) : super(key: key);

  @override
  _BodyLoginState createState() => _BodyLoginState();
}

class _BodyLoginState extends State<BodyLogin> {
  int currentPos = 0;
  final List<String> imageList = [
    "assets/images/introduce_3.jpg",
    "assets/images/introduce_2.png",
    "assets/images/introduce_1.png",
  ];

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  late bool _obscureText;

  LoginBloc? loginBloc;
  Api? api;

  @override
  void initState() {
    loginBloc = BlocProvider.of<LoginBloc>(context);
    email.text = 'giang114@gmail.com';
    password.text = '123456a';
    _obscureText = false;
  }

  void _passwordVisible() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final msg = BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
      if (state is LoginLoadingState) {
        return const CircularProgressIndicator();
      } else if (state is LoginErrorState) {
        return Text(state.message, style: TextStyle(color: Colors.red),);
      } else {
        return Container();
      }
    });

    return Scaffold(
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccessState) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          }
        },
        child:  Container(
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
          color: Colors.white,
          constraints: const BoxConstraints.expand(),
          child: SingleChildScrollView(
            child: Form(
              key: _formkey,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 60, 0, 30),
                    child: Text("Welcome back !",
                        style: TextStyle(fontSize: 22, color: Color(0xff333333))),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CarouselSlider(
                          options: CarouselOptions(
                              enlargeCenterPage: true,
                              pauseAutoPlayOnTouch: true,
                              enableInfiniteScroll: false,
                              autoPlay: true,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  currentPos = index;
                                });
                              }),
                          items: imageList
                              .map((e) => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              fit: StackFit.expand,
                              children: <Widget>[
                                Image.asset(
                                  e,
                                  width: size.width * 0.8,
                                  height: size.height * 0.4,
                                  fit: BoxFit.cover,
                                )
                              ],
                            ),
                          ))
                              .toList(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: imageList.map((url) {
                            int index = imageList.indexOf(url);
                            return Container(
                              width: 9.0,
                              height: 9.0,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 5.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: currentPos == index
                                    ? const Color.fromRGBO(0, 0, 0, 0.9)
                                    : const Color.fromRGBO(163, 161, 161, 0.4),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height*0.08,
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
                      hintText: "Mật khẩu",
                      labelText: "Mật khẩu",
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
                          borderRadius: const BorderRadius.all(Radius.circular(6))),
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints.loose(
                      const Size(double.infinity, 50),
                    ),
                    alignment: AlignmentDirectional.centerEnd,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:  [
                        TextButton(
                          onPressed: (){
                          },
                          child: const Text(
                          "Forgot password?",
                          style: TextStyle(fontSize: 16, color: Colors.black45),
                        ),),
                        TextButton(
                          onPressed: (){
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) {
                            //       return const SignUpScreen();
                            //     },
                            //   ),
                            // );
                          },
                          child: const Text(
                            "SignUp",
                            style: TextStyle(fontSize: 16, color: Colors.black45, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.075,
                  ),
                  SizedBox(
                    width: size.width * 0.8,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                      child: ElevatedButton(
                        child: const Text(
                          "Sign In",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          if (_formkey.currentState!.validate()) {
                            return loginBloc!.add(LoginButtonPressed(
                                email: email.text, password: password.text));
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
                  // Container(
                  //   margin: EdgeInsets.symmetric(vertical: size.height * 0.04),
                  //   width: size.width * 0.8,
                  //   child: Row(
                  //     children: const <Widget>[
                  //       Expanded(
                  //         child: Divider(
                  //           color: Color(0xFFD9D9D9),
                  //           height: 1.5,
                  //         ),
                  //       ),
                  //       Padding(
                  //         padding: EdgeInsets.symmetric(horizontal: 10),
                  //         child: Text(
                  //           "OR",
                  //           style: TextStyle(
                  //             color: Colors.black54,
                  //             fontWeight: FontWeight.w600,
                  //           ),
                  //         ),
                  //       ),
                  //       Expanded(
                  //         child: Divider(
                  //           color: Color(0xFFD9D9D9),
                  //           height: 1.5,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: <Widget>[
                  //       GestureDetector(
                  //         onTap: () {},
                  //         child: Container(
                  //           margin: EdgeInsets.symmetric(horizontal: 20),
                  //           padding: EdgeInsets.all(16),
                  //           decoration: BoxDecoration(
                  //             color: Colors.white70,
                  //             boxShadow: [
                  //               BoxShadow(
                  //                 color: Colors.blueGrey.withOpacity(0.3),
                  //                 spreadRadius: 2,
                  //                 blurRadius: 2,
                  //                 offset: Offset(0, 3), // changes position of shadow
                  //               ),
                  //             ],
                  //             border: Border.all(
                  //               width: 2,
                  //               color: Colors.blue.withOpacity(0.5),
                  //             ),
                  //             shape: BoxShape.circle,
                  //           ),
                  //           child: SvgPicture.asset(
                  //             "assets/icons/facebook.svg",
                  //             height: 21,
                  //             width: 21,
                  //           ),
                  //         ),
                  //       ),
                  //       GestureDetector(
                  //         onTap: () {},
                  //         child: Container(
                  //           margin: EdgeInsets.symmetric(horizontal: 20),
                  //           padding: EdgeInsets.all(16),
                  //           decoration: BoxDecoration(
                  //             color: Colors.white70,
                  //             boxShadow: [
                  //               BoxShadow(
                  //                 color: Colors.blueGrey.withOpacity(0.3),
                  //                 spreadRadius: 2,
                  //                 blurRadius: 2,
                  //                 offset: Offset(0, 3), // changes position of shadow
                  //               ),
                  //             ],
                  //             border: Border.all(
                  //               width: 2,
                  //               color: Colors.blue.withOpacity(0.5),
                  //             ),
                  //             shape: BoxShape.circle,
                  //           ),
                  //           child: SvgPicture.asset(
                  //             "assets/icons/google-plus.svg",
                  //             height: 21,
                  //             width: 21,
                  //           ),
                  //         ),
                  //       ),
                  //       GestureDetector(
                  //         onTap: () {},
                  //         child: Container(
                  //           margin: EdgeInsets.symmetric(horizontal: 20),
                  //           padding: EdgeInsets.all(16),
                  //           decoration: BoxDecoration(
                  //             color: Colors.white70,
                  //             boxShadow: [
                  //               BoxShadow(
                  //                 color: Colors.blueGrey.withOpacity(0.3),
                  //                 spreadRadius: 2,
                  //                 blurRadius: 2,
                  //                 offset: Offset(0, 3), // changes position of shadow
                  //               ),
                  //             ],
                  //             border: Border.all(
                  //               width: 2,
                  //               color: Colors.blue.withOpacity(0.5),
                  //             ),
                  //             shape: BoxShape.circle,
                  //           ),
                  //           child: SvgPicture.asset(
                  //             "assets/icons/twitter.svg",
                  //             height: 21,
                  //             width: 21,
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
