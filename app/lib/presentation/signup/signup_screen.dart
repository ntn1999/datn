// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:iot_demo/blocs/signup/signup_bloc.dart';
// import 'package:iot_demo/configs/colors.dart';
// import 'package:iot_demo/presentation/login/login_screen.dart';
//
// import '../../datasource/network/apis.dart';
//
// class SignUpScreen extends StatelessWidget {
//   const SignUpScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(create: (context) => SignupBloc(SignupInitState(), Api()))
//       ],
//       child: BodySignup(),
//     );
//   }
// }
//
// class BodySignup extends StatefulWidget {
//   const BodySignup({Key? key}) : super(key: key);
//
//   @override
//   _BodySignupState createState() => _BodySignupState();
// }
//
// class _BodySignupState extends State<BodySignup> {
//   TextEditingController email = TextEditingController();
//   TextEditingController password = TextEditingController();
//   TextEditingController confirmPassword = TextEditingController();
//   TextEditingController name = TextEditingController();
//   TextEditingController phoneNumber = TextEditingController();
//   TextEditingController job = TextEditingController();
//
//   int currentPos = 0;
//   late bool _obscureText, _obscureText2;
//
//   final List<String> imageList = [
//     "assets/images/introduce1.jpg",
//     "assets/images/introduce2.png",
//     "assets/images/introduce3.jpg",
//   ];
//   List<String> items = [
//     'Doctor',
//     'Security',
//     'Pumper',
//     'Trade',
//     'Singer',
//     'Policer',
//     'Chemical Technology',
//     'Information Technology',
//     'MC',
//     'Travel',
//     'Nurse',
//     'Teacher',
//     'Accountant',
//     'Engineer',
//     'Dramatist',
//     'Tour guide',
//     'Artist'
//   ];
//
//   final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
//
//   SignupBloc? signupBloc;
//
//   Api? api;
//
//   void initState() {
//     _obscureText = false;
//     _obscureText2 = false;
//     name.text = "hieu";
//     email.text = "hieu@gmail.com";
//     password.text = "123456";
//     confirmPassword.text = "123456";
//     phoneNumber.text = "0392755136";
//     signupBloc = BlocProvider.of<SignupBloc>(context);
//   }
//
//   void _passwordVisible() {
//     setState(() {
//       _obscureText = !_obscureText;
//     });
//   }
//
//   void _passwordVisible2() {
//     setState(() {
//       _obscureText2 = !_obscureText2;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     final msg = BlocBuilder<SignupBloc, SignupState>(builder: (context, state) {
//       if (state is SignupLoadingState) {
//         return const CircularProgressIndicator();
//       } else if (state is SignupErrorState) {
//         return Text(state.message);
//       } else {
//         return Container();
//       }
//     });
//     return Scaffold(
//       body: BlocListener<SignupBloc, SignupState>(
//         listener: (context, state) {
//           if (state is SignupSuccessState) {
//             print("Signup ok");
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => LoginScreen()),
//             );
//           }
//         },
//         child: Container(
//           padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
//           color: Colors.white,
//           constraints: const BoxConstraints.expand(),
//           child: SingleChildScrollView(
//             child: Form(
//               key: _formkey,
//               child: Column(
//                 children: [
//                   const SizedBox(
//                     height: 80,
//                   ),
//                   CarouselSlider(
//                     options: CarouselOptions(
//                         enlargeCenterPage: true,
//                         enableInfiniteScroll: true,
//                         autoPlay: true,
//                         onPageChanged: (index, reason) {
//                           setState(() {
//                             currentPos = index;
//                           });
//                         }),
//                     items: imageList
//                         .map((e) => ClipRRect(
//                               borderRadius: BorderRadius.circular(8),
//                               child: Stack(
//                                 fit: StackFit.expand,
//                                 children: <Widget>[
//                                   Image.asset(
//                                     e,
//                                     width: size.width * 0.8,
//                                     height: size.height * 0.38,
//                                     fit: BoxFit.cover,
//                                   )
//                                 ],
//                               ),
//                             ))
//                         .toList(),
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: imageList.map((url) {
//                       int index = imageList.indexOf(url);
//                       return Container(
//                         width: 8.0,
//                         height: 8.0,
//                         margin: EdgeInsets.symmetric(
//                             vertical: 10.0, horizontal: 2.0),
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: currentPos == index
//                               ? Color.fromRGBO(0, 0, 0, 0.9)
//                               : Color.fromRGBO(0, 0, 0, 0.4),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   TextFormField(
//                     controller: name,
//                     onChanged: (String? value) {
//                       _formkey.currentState!.validate();
//                     },
//                     validator: (String? value) {
//                       if (value!.isEmpty) {
//                         return 'Please a Enter';
//                       }
//                     },
//                     cursorColor: kPrimaryColor,
//                     decoration: const InputDecoration(
//                       prefixIcon: Icon(
//                         Icons.person,
//                         color: kPrimaryColor,
//                       ),
//                       hintText: "Name",
//                       labelText: "Name",
//                       border: OutlineInputBorder(
//                           borderSide:
//                               BorderSide(color: Color(0xffCED0D2), width: 1),
//                           borderRadius: BorderRadius.all(Radius.circular(6))),
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   TextFormField(
//                     controller: email,
//                     onChanged: (String? value) {
//                       _formkey.currentState!.validate();
//                     },
//                     validator: (String? value) {
//                       if (value!.isEmpty) {
//                         return 'Please a Enter Email';
//                       }
//                     },
//                     onSaved: (String? value) {
//                       email = value as TextEditingController;
//                     },
//                     cursorColor: kPrimaryColor,
//                     decoration: const InputDecoration(
//                       prefixIcon: Icon(
//                         Icons.person,
//                         color: kPrimaryColor,
//                       ),
//                       hintText: "Email",
//                       labelText: "Email",
//                       border: OutlineInputBorder(
//                           borderSide:
//                               BorderSide(color: Color(0xffCED0D2), width: 1),
//                           borderRadius: BorderRadius.all(Radius.circular(6))),
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   TextFormField(
//                     controller: password,
//                     obscureText: !_obscureText,
//                     onChanged: (value) {
//                       _formkey.currentState!.validate();
//                     },
//                     validator: (String? value) {
//                       if (value!.isEmpty) {
//                         return 'Please a Enter Password';
//                       } else if (value!.length < 6) {
//                         return 'password is too short ';
//                       }
//                       return null;
//                     },
//                     cursorColor: kPrimaryColor,
//                     decoration: InputDecoration(
//                       hintText: "Password",
//                       labelText: "Password",
//                       prefixIcon: const Icon(
//                         Icons.lock,
//                         color: kPrimaryColor,
//                       ),
//                       suffixIcon: IconButton(
//                           icon: Icon(
//                             _obscureText
//                                 ? Icons.visibility
//                                 : Icons.visibility_off,
//                             color: kPrimaryColor,
//                           ),
//                           onPressed: _passwordVisible),
//                       border: OutlineInputBorder(
//                           borderSide: BorderSide(
//                               color: Color(0xffCED0D2).withOpacity(0.2)),
//                           borderRadius: BorderRadius.all(Radius.circular(6))),
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   TextFormField(
//                     controller: confirmPassword,
//                     obscureText: !_obscureText2,
//                     onChanged: (value) {
//                       _formkey.currentState!.validate();
//                     },
//                     validator: (String? value) {
//                       if (value!.isEmpty) {
//                         return 'Please re-enter password';
//                       }
//
//                       if (password.text != confirmPassword.text) {
//                         return "Password does not match";
//                       }
//
//                       return null;
//                     },
//                     cursorColor: kPrimaryColor,
//                     decoration: InputDecoration(
//                       hintText: "Confirm Password",
//                       labelText: "Confirm Password",
//                       prefixIcon: const Icon(
//                         Icons.lock,
//                         color: kPrimaryColor,
//                       ),
//                       suffixIcon: IconButton(
//                           icon: Icon(
//                             _obscureText2
//                                 ? Icons.visibility
//                                 : Icons.visibility_off,
//                             color: kPrimaryColor,
//                           ),
//                           onPressed: _passwordVisible2),
//                       border: OutlineInputBorder(
//                           borderSide: BorderSide(
//                               color: Color(0xffCED0D2).withOpacity(0.2)),
//                           borderRadius: BorderRadius.all(Radius.circular(6))),
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   TextFormField(
//                     controller: phoneNumber,
//                     cursorColor: kPrimaryColor,
//                     keyboardType: TextInputType.number,
//                     onChanged: (value) {},
//                     validator: (String? value) {
//                       if (value!.isEmpty) {
//                         return 'Please a Enter Phone Number';
//                       }
//                       return null;
//                     },
//                     onSaved: (String? value) {
//                       phoneNumber = value as TextEditingController;
//                     },
//                     decoration: const InputDecoration(
//                       labelText: "Phone Number",
//                       prefixIcon: Icon(
//                         Icons.phone,
//                         color: kPrimaryColor,
//                       ),
//                       border: OutlineInputBorder(
//                           borderSide:
//                               BorderSide(color: Color(0xffCED0D2), width: 1),
//                           borderRadius: BorderRadius.all(Radius.circular(6))),
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   // msg,
//                   Center(
//                     child: Container(
//                       width: size.width * 0.9,
//                       height: size.height * 0.08,
//                       decoration: BoxDecoration(
//                         color: kPrimaryLightColor,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: DropdownSearch(
//                         searchBoxController: job,
//                         mode: Mode.MENU,
//                         showSelectedItem: true,
//                         items: items,
//                         label: "Job",
//                         selectedItem: items.first,
//                         onChanged: (value) {},
//                       ),
//                     ),
//                   ),
//
//                   Container(
//                     constraints: BoxConstraints.loose(
//                       const Size(double.infinity, 50),
//                     ),
//                     alignment: AlignmentDirectional.centerEnd,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: <Widget>[
//                         const Text(
//                           "Already have an Account ? ",
//                           style: TextStyle(color: Colors.black45),
//                         ),
//                         GestureDetector(
//                           onTap: () {
//                             Navigator.pushReplacement(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => LoginScreen()),
//                             );
//                           },
//                           child: const Text(
//                             "Sign In",
//                             style: TextStyle(
//                               color: Colors.black45,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                   msg,
//                   SizedBox(height: size.height * 0.03),
//                   SizedBox(
//                     width: size.width * 0.8,
//                     child: ClipRRect(
//                       borderRadius: const BorderRadius.all(Radius.circular(6)),
//                       child: ElevatedButton(
//                         child: const Text(
//                           "Signup",
//                           style: TextStyle(color: Colors.white),
//                         ),
//                         onPressed: () {
//                           if (_formkey.currentState!.validate()) {
//                             return signupBloc!.add(SignupButtonPressed(
//                                 email: email.text,
//                                 password: password.text,
//                                 name: name.text,
//                                 phoneNumber: phoneNumber.text,
//                                 job: job.text));
//                           }
//                         },
//                         style: ElevatedButton.styleFrom(
//                             primary: kPrimaryColor,
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 40, vertical: 20),
//                             textStyle: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w500)),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: size.height * 0.03),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
