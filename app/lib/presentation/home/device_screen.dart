import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_demo/blocs/get_infor/device_bloc.dart';
import 'package:iot_demo/blocs/profile/profile_bloc.dart';
import 'package:iot_demo/configs/colors.dart';
import 'package:iot_demo/presentation/home/device_report_screen.dart';
import 'package:iot_demo/utils/app_button.dart';

import '../../datasource/models/devices_res.dart';
import '../../datasource/models/user_res.dart';
import '../../datasource/network/apis.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DeviceBloc>(
            create: (_) => DeviceBloc()..add(DeviceEventStated())),
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
  Api api = Api();
  TextEditingController note = TextEditingController();
  String noteDevice = '';

  @override
  void initState() {
    super.initState();
  }

  void reportDevice(String id, String note) {
    var result = api.updateDevice(id, note);
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    UserResponse userResponse;
    List<Devices> deviceDemo = [
      Devices(
        status: true,
        name: 'tivi',
        deviceOwner: 'giang Nguyen',
        description: 'Tivi phòng ngủ',
        installationDate: '20/1/2013',
        note: 'lắp mới',
      ),
      Devices(
        status: true,
        name: 'tivi',
        deviceOwner: 'giang Nguyen',
        description: 'Tivi phòng ngủ',
        installationDate: '20/1/2013',
        note: 'lắp mới',
      ),
      Devices(
        status: true,
        name: 'đèn chiếu sáng',
        deviceOwner: 'giang Nguyen',
        description: 'Đèn LED bán nguyệt Rạng Đông ',
        installationDate: '20/1/2013',
        note: 'lắp mới',
      ),
      Devices(
        status: true,
        name: 'Đèn chiếu sáng phòng khách',
        deviceOwner: 'giang Nguyen',
        description: 'Đèn rạng đông',
        installationDate: '20/1/2013',
        note: 'lắp mới',
      ),
      Devices(
        status: true,
        name: 'Quạt',
        deviceOwner: 'giang Nguyen',
        description: 'Quạt phòng khách',
        installationDate: '20/1/2013',
        note: 'lắp mới',
      ),
      Devices(
        status: true,
        name: 'đèn nền',
        deviceOwner: 'giang Nguyen',
        description: 'Đèn nền mờ',
        installationDate: '20/1/2013',
        note: 'lắp mới',
      ),
    ];

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        constraints: const BoxConstraints.expand(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Card(
                color: Colors.greenAccent.shade100,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: BlocBuilder<DeviceBloc, DeviceState>(
                          builder: (context, state) {
                        if (state is DeviceLoadingState) {
                          return Container(
                              alignment: Alignment.topCenter,
                              height: size.height * 0.18,
                              child: const CircularProgressIndicator());
                        } else if (state is GetDeviceLoadedState) {
                          List<Devices> devices =
                              state.listDevice.devices ?? [];
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Wrap(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(10, 10, 5, 5),
                                  child: Icon(
                                    Icons.developer_board,
                                    color: Colors.blue,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 15, 0, 5),
                                  child: Text(
                                    "Số thiết bị: " +
                                        state.listDevice.devices!.length
                                            .toString(),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
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
              SizedBox(
                height: 650,
                child: BlocBuilder<DeviceBloc, DeviceState>(
                    builder: (context, state) {
                  if (state is DeviceLoadingState) {
                    return Container(
                        alignment: Alignment.topCenter,
                        height: size.height * 0.18,
                        child: const CircularProgressIndicator());
                  } else if (state is GetDeviceLoadedState) {
                    List<Devices> devices = [];
                    devices.addAll(state.listDevice.devices ?? []);
                    //devices.addAll(deviceDemo);
                    return ListView.builder(
                      itemCount: devices.length,
                      itemBuilder: (context, position) {
                        return Card(
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
                                      "Tên thiết bị:  " +
                                          devices[position].name!,
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      devices[position].description ?? '',
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      devices[position].note ?? '',
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      "Ngày lắp đặt:  " +
                                          devices[position].installationDate!,
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Container(
                                          width: 120,
                                        ),
                                        devices[position].statusRequest == true
                                            ? Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              DeviceReportScreen(
                                                                  device: devices[
                                                                      position])),
                                                    );
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        top: 10),
                                                    padding: const EdgeInsets
                                                        .fromLTRB(5, 0, 5, 5),
                                                    height: size.height * 0.06,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      color: Colors
                                                          .redAccent.shade100
                                                          .withOpacity(0.5),
                                                      border: Border.all(
                                                          color:
                                                              Colors.redAccent,
                                                          width: 1.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Text(
                                                      'Báo hỏng và yêu cầu hỗ trợ',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                margin:
                                                    EdgeInsets.only(top: 10),
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        5, 0, 5, 5),
                                                height: size.height * 0.06,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: Colors
                                                      .greenAccent.shade100,
                                                  border: Border.all(
                                                      color: Colors.greenAccent,
                                                      width: 1.2),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  ' Đang chờ sửa chữa ',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return Container();
                  }
                }),
              ),
              const SizedBox(
                height: 64,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
