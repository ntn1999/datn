import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_demo/blocs/get_infor/device_bloc.dart';
import 'package:iot_demo/blocs/profile/profile_bloc.dart';
import 'package:iot_demo/configs/colors.dart';

import 'package:iot_demo/presentation/home/change_password_screen.dart';

import '../../datasource/models/user_res.dart';
import '../../datasource/network/apis.dart';

class ProFileScreen extends StatelessWidget {
  const ProFileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProFileBloc>(
            create: (_) => ProFileBloc()..add(ProFileEventStated())),
        // BlocProvider<GetInforBloc>(
        //     create: (_) => GetInforBloc()..add(GetInforEventStated())),
      ],
      child: Body(),
    );
  }
}

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  ProFileBloc? profileBloc;
  Api? api;

  @override
  void initState() {
    profileBloc = BlocProvider.of<ProFileBloc>(context);
    super.initState();
  }

  void submitEdit( String name, String phone, String location){

  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    UserResponse userResponse;
    final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
    TextEditingController name = TextEditingController();
    TextEditingController phone = TextEditingController();
    TextEditingController address = TextEditingController();

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        constraints: const BoxConstraints.expand(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 16,
              ),
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
                width: 100,
                height: 100,
                child: const Icon(
                  Icons.person,
                  size: 50,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              SizedBox(
                width: double.infinity,
                child: BlocBuilder<ProFileBloc, ProFileState>(
                    builder: (context, state) {
                  if (state is ProFileLoadingState) {
                    return Container(
                        alignment: Alignment.topCenter,
                        height: size.height * 0.18,
                        child: const CircularProgressIndicator());
                  } else if (state is ProFileLoadedState) {
                    userResponse = state.listProfile;
                    User? user = userResponse.user;
                    return Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        user!.name.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                }),
              ),
              Card(
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: BlocBuilder<ProFileBloc, ProFileState>(
                          builder: (context, state) {
                        if (state is ProFileLoadingState) {
                          return Container(
                              alignment: Alignment.topCenter,
                              height: size.height * 0.18,
                              child: const CircularProgressIndicator());
                        } else if (state is ProFileLoadedState) {
                          userResponse = state.listProfile;
                          User? user = userResponse.user;
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Wrap(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(10, 10, 5, 5),
                                  child: Icon(
                                    Icons.phone,
                                    color: Colors.blue,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 15, 0, 5),
                                  child: Text(
                                    "Điện thoại: " + user!.phone.toString(),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Container();
                        }
                      }),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: BlocBuilder<ProFileBloc, ProFileState>(
                          builder: (context, state) {
                        if (state is ProFileLoadingState) {
                          return Container(
                              alignment: Alignment.topCenter,
                              height: size.height * 0.18,
                              child: const CircularProgressIndicator());
                        } else if (state is ProFileLoadedState) {
                          userResponse = state.listProfile;
                          User? listProfileResponse = userResponse.user;
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Wrap(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(10, 10, 5, 5),
                                  child: Icon(
                                    Icons.email,
                                    color: Colors.blue,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 15, 0, 5),
                                  child: Text(
                                    "Email: " +
                                        listProfileResponse!.email.toString(),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Container();
                        }
                      }),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: BlocBuilder<ProFileBloc, ProFileState>(
                          builder: (context, state) {
                        if (state is ProFileLoadingState) {
                          return Container(
                              alignment: Alignment.topCenter,
                              height: size.height * 0.18,
                              child: const CircularProgressIndicator());
                        } else if (state is ProFileLoadedState) {
                          userResponse = state.listProfile;
                          User? user = userResponse.user;
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Wrap(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(10, 10, 5, 5),
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.blue,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 15, 0, 5),
                                  child: Text(
                                    "Họ tên:  " + user!.name.toString(),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Container();
                        }
                      }),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: BlocBuilder<ProFileBloc, ProFileState>(
                          builder: (context, state) {
                        if (state is ProFileLoadingState) {
                          return Container(
                              alignment: Alignment.topCenter,
                              height: size.height * 0.18,
                              child: const CircularProgressIndicator());
                        } else if (state is ProFileLoadedState) {
                          userResponse = state.listProfile;
                          User? user = userResponse.user;
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Wrap(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(10, 10, 5, 5),
                                  child: Icon(
                                    Icons.location_on_sharp,
                                    color: Colors.blue,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 15, 0, 5),
                                  child: Text(
                                    "Địa chỉ:  " + user!.location.toString(),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Container();
                        }
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 64,
              ),
              SizedBox(
                width: size.width * 0.95,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                  child: ElevatedButton(
                    child: const Text(
                      "Edit",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (
                            BuildContext context,
                          ) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(20.0)), //thi
                              // s right here
                              child: StatefulBuilder(builder:
                                  (BuildContext context, StateSetter setState) {
                                return Container(
                                  height: size.height * 0.65,
                                  // width: size.width*0.85,
                                  child: SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Form(
                                        key: _formkey,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const SizedBox(
                                              height: 32,
                                            ),
                                            const Text(
                                              'Chỉnh sửa thông tin ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  color: Colors.red),
                                            ),
                                            const SizedBox(
                                              height: 62,
                                            ),
                                            TextFormField(
                                              controller: name,
                                              onChanged: (value) {
                                                _formkey.currentState!.validate();
                                              },
                                              validator: (String? value) {
                                                if (value!.isEmpty) {
                                                  return 'Please a Enter';
                                                }
                                              },
                                              onSaved: (String? value) {
                                                name = value as TextEditingController;
                                              },
                                              cursorColor: kPrimaryColor,
                                              decoration: const InputDecoration(
                                                prefixIcon: Icon(
                                                  Icons.person,
                                                  color: kPrimaryColor,
                                                ),
                                                hintText: "Họ và tên",
                                                labelText: "Họ và tên",
                                                border: OutlineInputBorder(
                                                    borderSide:
                                                    BorderSide(color: Color(0xffCED0D2), width: 1),
                                                    borderRadius: BorderRadius.all(Radius.circular(6))),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 32,
                                            ),
                                            TextFormField(
                                              controller: phone,
                                              onChanged: (value) {
                                                _formkey.currentState!.validate();
                                              },
                                              validator: (String? value) {
                                                if (value!.isEmpty) {
                                                  return 'Please a Enter';
                                                }
                                              },
                                              onSaved: (String? value) {
                                                phone = value as TextEditingController;
                                              },
                                              cursorColor: kPrimaryColor,
                                              decoration: const InputDecoration(
                                                prefixIcon: Icon(
                                                  Icons.person,
                                                  color: kPrimaryColor,
                                                ),
                                                hintText: "Số điện thoại",
                                                labelText: "Số điện thoại",
                                                border: OutlineInputBorder(
                                                    borderSide:
                                                    BorderSide(color: Color(0xffCED0D2), width: 1),
                                                    borderRadius: BorderRadius.all(Radius.circular(6))),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 32,
                                            ),
                                            TextFormField(
                                              controller: address,
                                              onChanged: (value) {
                                                _formkey.currentState!.validate();
                                              },
                                              validator: (String? value) {
                                                if (value!.isEmpty) {
                                                  return 'Please a Enter';
                                                }
                                              },
                                              onSaved: (String? value) {
                                                address = value as TextEditingController;
                                              },
                                              cursorColor: kPrimaryColor,
                                              decoration: const InputDecoration(
                                                prefixIcon: Icon(
                                                  Icons.person,
                                                  color: kPrimaryColor,
                                                ),
                                                hintText: "Vị trí",
                                                labelText: "Vị trí",
                                                border: OutlineInputBorder(
                                                    borderSide:
                                                    BorderSide(color: Color(0xffCED0D2), width: 1),
                                                    borderRadius: BorderRadius.all(Radius.circular(6))),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 32,
                                            ),
                                            SizedBox(
                                              width: 280.0,
                                              height: 52,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  if (_formkey.currentState!.validate()) {
                                                     profileBloc!.add(ChangeProfilePressed(
                                                        name: name.text,
                                                        phone: phone.text,
                                                        address: address.text));
                                                    Navigator.pop(context);
                                                  }else{

                                                  }

                                                },
                                                style: ElevatedButton.styleFrom(
                                                  primary:
                                                      const Color(0xFF1BC0C5),
                                                  onPrimary:
                                                      Colors.white, // foreground
                                                ),
                                                child: const Text(
                                                  "Save",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            );
                          });
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
              const SizedBox(height: 32),
              SizedBox(
                width: size.width * 0.95,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                  child: ElevatedButton(
                    child: const Text(
                      "Change Password",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const ChangePasswordScreen();
                          },
                        ),
                      );
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
            ],
          ),
        ),
      ),
    );
  }
}
