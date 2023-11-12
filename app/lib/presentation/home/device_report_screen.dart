import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_demo/configs/colors.dart';

import '../../blocs/change_password/change_password_bloc.dart';
import '../../blocs/get_infor/device_bloc.dart';
import '../../datasource/models/devices_res.dart';
import '../../datasource/network/apis.dart';

class DeviceReportScreen extends StatelessWidget {
  const DeviceReportScreen({Key? key, required this.device}) : super(key: key);
  final Devices device;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => DeviceBloc()..add(DeviceEventStated())),
      ],
      child: BodyDeviceReport(
        device: device,
      ),
    );
  }
}

class BodyDeviceReport extends StatefulWidget {
  const BodyDeviceReport({Key? key, required this.device}) : super(key: key);
  final Devices device;

  @override
  _BodyDeviceReportState createState() => _BodyDeviceReportState();
}

class _BodyDeviceReportState extends State<BodyDeviceReport> {
  DeviceBloc? bloc;
  Api? api;
  TextEditingController note = TextEditingController();
  String noteDevice = '';
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  void initState() {
    bloc = BlocProvider.of<DeviceBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // final msg = BlocBuilder<DeviceBloc,DeviceState>(
    //     builder: (context, state) {
    //       if (state is ChangePasswordLoadingState) {
    //         return const CircularProgressIndicator();
    //       } else if (state is ChangePasswordErrorState) {
    //         return Text(
    //           'state.message',
    //           style: TextStyle(color: Colors.red),
    //         );
    //       } else {
    //         return Container();
    //       }
    //     });

    return Scaffold(
      body: BlocListener<DeviceBloc, DeviceState>(
        listener: (context, state) {
          if (state is DeviceReportSuccessState) {
            showAlertDialog(context);
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
                  const Text(
                    'Yêu cầu sửa chữa ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.red),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  Card(
                    borderOnForeground: true,
                    color: ColorConstants.borderInput,
                    child: Container(
                      padding: const EdgeInsets.all(15.0),
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Tên thiết bị:  " + widget.device.name!,
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                widget.device.description!,
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                "Ngày lắp đặt:  " +
                                    widget.device.installationDate!,
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  TextFormField(
                    onChanged: (value) {
                      noteDevice = value;
                    },
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return 'Please a Enter';
                      }
                    },
                    onSaved: (String? value) {
                      note = value as TextEditingController;
                    },
                    cursorColor: kPrimaryColor,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.person,
                        color: kPrimaryColor,
                      ),
                      hintText: "Ghi chú",
                      labelText: "Ghi chú",
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xffCED0D2), width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(6))),
                    ),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Navigator.pop(context);
                      bloc!.add(DeviceReportPressed(
                          id: widget.device.sId ?? '', note: noteDevice));
                    },
                    style: ElevatedButton.styleFrom(
                      primary: const Color(0xFF1BC0C5),
                      onPrimary: Colors.white, // foreground
                    ),
                    child: const Text(
                      "Gửi Yêu Cầu",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  // Padding(
                  //   padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  //   child: msg,
                  // ),
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
      title: Text("success"),
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
