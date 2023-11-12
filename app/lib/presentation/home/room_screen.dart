import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_demo/blocs/get_infor/device_bloc.dart';
import 'package:iot_demo/blocs/living_room/living_room_bloc.dart';
import 'package:iot_demo/configs/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:iot_demo/datasource/models/sensor_sub.dart';
import 'package:iot_demo/datasource/models/sensors_res.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart' as mqttServer;
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:shared_preferences/shared_preferences.dart';

import '../../datasource/models/devices_res.dart';
import '../../datasource/network/apis.dart';

class LivingRoomScreen extends StatelessWidget {
  const LivingRoomScreen(
      {Key? key, required this.room, required this.deviceList})
      : super(key: key);
  final Room room;
  final List<Devices> deviceList;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LivingRoomBloc>(
            create: (_) =>
                LivingRoomBloc()..add(LivingRoomEventStated(time: '12'))),
        // BlocProvider<DeviceBloc>(
        //     create: (_) => DeviceBloc()..add(DeviceEventStated())),
      ],
      child: Body(
        room: room,
        deviceList: deviceList,
      ),
    );
  }
}

enum Device { lamb1, pan }

class Body extends StatefulWidget {
  const Body({Key? key, required this.room, required this.deviceList})
      : super(key: key);
  final Room room;
  final List<Devices> deviceList;

  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  Duration timer = Duration(hours: 0, minutes: 0);

  Api? api;
  bool led1 = false;
  bool led2 = false;
  bool led3 = false;
  bool tivi = false;
  bool auto = false;
  bool airConditioning = false;
  String humidityAir = '...';
  String temperature = '...';

  String broker = 'broker.hivemq.com';
  int port = 1883;
  String clientIdentifier = 'flutter';

  late mqttServer.MqttServerClient client;
  late mqtt.MqttConnectionState connectionState;
  late List<DeviceStatus> deviceStatusControl;

  StreamSubscription? subscription;

  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(
          child: Text(
            "Trong 12h",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          value: "12"),
      const DropdownMenuItem(
          child: Text(
            "Trong 24h ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          value: "24"),
      const DropdownMenuItem(
          child: Text(
            "Trong tuần ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          value: "168"),
      const DropdownMenuItem(
          child: Text(
            "Trong tháng ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          value: "720"),
    ];
    return menuItems;
  }
  final apiRepository = Api();
  String times = '12';

  void _subscribeToTopic(String topic) {
    if (connectionState == mqtt.MqttConnectionState.connected) {
      print('[MQTT client] Subscribing to ${topic.trim()}');
      client.subscribe(topic, mqtt.MqttQos.exactlyOnce);
    }
    print('[MQTT client] onScribe');
  }

  void _connect() async {
    client = mqttServer.MqttServerClient('broker.mqttdashboard.com', '');
    client.logging(on: false);
    client.keepAlivePeriod = 30;
    client.onDisconnected = _onDisconnected;

    final mqtt.MqttConnectMessage connMess = mqtt.MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .startClean() // Non persistent session for testing
        .keepAliveFor(30)
        .withWillQos(mqtt.MqttQos.atMostOnce);
    print('[MQTT client] MQTT client connecting....');
    client.connectionMessage = connMess;

    try {
      await client.connect('', '');
    } catch (e) {
      print('lỗi rồi, disconnect thôi');
      _disconnect();
    }

    /// Check if we are connected
    if (client.connectionState == mqtt.MqttConnectionState.connected) {
      print('[MQTT client] connected');
      setState(() {
        connectionState = client.connectionStatus.state;
      });
    } else {
      print('[MQTT client] ERROR: MQTT client connection failed - '
          'disconnecting, state is ${client.connectionState}');
      _disconnect();
    }
    subscription = client.updates.listen(_onMessage);
    _subscribeToTopic("demo");
  }

  void publishTopic(String pubTopic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(pubTopic, MqttQos.atLeastOnce, builder.payload);
  }

  void _disconnect() {
    print('[MQTT client] _disconnect()');
    client.disconnect();
    _onDisconnected();
  }

  void _onDisconnected() {
    // setState(() {
    //   //topics.clear();
    //   connectionState = client.connectionState;
    //   client = null;
    //   subscription!.cancel();
    //   subscription = null;
    // });
    print('[MQTT client] MQTT client disconnected');
  }

  void _onMessage(List<mqtt.MqttReceivedMessage> event) {
    print(event.length);
    final mqtt.MqttPublishMessage recMess =
        event[0].payload as mqtt.MqttPublishMessage;
    final String message =
        mqtt.MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    print('[MQTT client] MQTT message: topic is <${event[0].topic}>, '
        'payload is <-- ${message} -->');
    print(client.connectionState);
    print("[MQTT client] message with topic: ${event[0].topic}");
    print("[MQTT client] message with message: ${message}");
    Sensor sensor = Sensor();
    try {
      Map<String, dynamic> results = json.decode(message);
      sensor = Sensor.fromJson(results);
    } catch (e) {
      print(e);
    }
    setState(() {
      humidityAir = sensor.humidityAir.toString();
      temperature = sensor.temperature.toString();
    });
  }

  Future<void> toggleSwitchLed1(bool value, String id, DeviceStatus device) async {
    if (device.statusControl == false) {
      setState(() {
        device.statusControl = true;
      });
      print('${device.name}  ${device.statusControl.toString()}');

      publishTopic(id, '{"Status":"1","Timer":"0"}');
    } else {
      setState(() {
         device.statusControl = false;
      });
      publishTopic(id, '{"Status":"0","Timer":"0"}');
    }
    try{
      var result =await apiRepository.updateStatusDevice(id, value);
      print(result?.toJson());
    }catch(e){
      print(e);
    }
  }

  // void toggleSwitchLed2(bool value) {
  //   if (led2 == false) {
  //     setState(() {
  //       led2 = true;
  //     });
  //     publishTopic('lamb2', '{"Status":"1","Timer":"0"}');
  //   } else {
  //     setState(() {
  //       led2 = false;
  //     });
  //     publishTopic('lamb2', '{"Status":"0","Timer":"0"}');
  //   }
  // }
  //
  // void toggleAuto(bool value) {
  //   if (auto == false) {
  //     setState(() {
  //       auto = true;
  //     });
  //   } else {
  //     setState(() {
  //       auto = false;
  //     });
  //   }
  // }
  //
  // void toggleSwitchTivi(bool value) {
  //   if (tivi == false) {
  //     setState(() {
  //       tivi = true;
  //     });
  //     publishTopic('lock', '{"Status":"1","Timer":"0"}');
  //   } else {
  //     setState(() {
  //       tivi = false;
  //     });
  //     publishTopic('lock', '{"Status":"0","Timer":"0"}');
  //   }
  // }
  //
  // void toggleSwitchAirConditioning(bool value) {
  //   //pan
  //   if (airConditioning == false) {
  //     setState(() {
  //       airConditioning = true;
  //     });
  //     publishTopic('pan', '{"Status":"1","Timer":"0"}');
  //   } else {
  //     setState(() {
  //       airConditioning = false;
  //     });
  //     publishTopic('pan', '{"Status":"0","Timer":"0"}');
  //   }
  // }

  LivingRoomBloc? roomBloc;

  void initState() {
    _connect();
    roomBloc = BlocProvider.of<LivingRoomBloc>(context);
    this.deviceStatusControl = getDevices(widget.deviceList);
    super.initState();
  }

  List<DeviceStatus> getDevices(List<Devices> devices) {
    List<DeviceStatus> newDeviceControl = [];
    devices.forEach((e) {
      newDeviceControl.add(DeviceStatus(
        statusControl: e.status,
      )
        ..status = e.status
        ..sId = e.sId
        ..name = e.name
        ..deviceOwner = e.deviceOwner
         ..description = e.description
         ..installationDate = e.installationDate
         ..note = e.note
          ..room = e.room
          ..statusRequest = e.statusRequest
          ..isControl =e.isControl,
      );
    });

    return newDeviceControl;
  }

  DateTime getDateTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour, now.minute);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    SensorsResponse sensorsResponse = SensorsResponse();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Container(
          child: Text(
            widget.room.name,
            style: Theme.of(context).textTheme.caption!.copyWith(
                  color: Colors.blue,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        constraints: const BoxConstraints.expand(),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(5, 10, 0, 0),
                    padding: const EdgeInsets.fromLTRB(10, 0, 20, 5),
                    width: size.width * 0.62,
                    height: size.height * 0.12,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/temperature.png',
                                  width: 28,
                                ),
                                const Text(
                                  'Nhiệt độ: ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ],
                            ),
                            Text(
                              temperature,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/humidity.png',
                                  width: 28,
                                ),
                                const Text(
                                  'Độ ẩm không khí: ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                            Text(
                              humidityAir,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        if (widget.room == Room.kitchen)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/images/poison.png',
                                    width: 28,
                                  ),
                                  const Text(
                                    'Nồng độ khí gas: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                              Text(
                                '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              )
                            ],
                          ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                        margin: const EdgeInsets.fromLTRB(5, 0, 5, 10),
                        width: size.width * 0.28,
                        height: size.height * 0.06,
                        alignment: Alignment.center,
                        // decoration: BoxDecoration(
                        //   color: Colors.lightBlue.shade50.withOpacity(0.5),
                        //   border:
                        //       Border.all(color: Colors.blueAccent, width: 1.2),
                        //   borderRadius: BorderRadius.circular(10),
                        // ),
                        // child: Image.asset(
                        //   "assets/images/microphone.png",
                        //   width: 36,
                        // ),
                      ),
                    ),
                  )
                ],
              ),
              Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                  margin: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                  width: size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: deviceStatusControl
                        .where((element) => element.isControl == true)
                        .map((e) => buildDeviceControl(context, e))
                        .toList(),
                  )),
              // if (widget.room == Room.livingRoom)
              //   Container(
              //     padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
              //     margin: const EdgeInsets.fromLTRB(0, 6, 0, 0),
              //     width: size.width,
              //     child: Column(
              //       mainAxisAlignment: MainAxisAlignment.start,
              //       children: widget.deviceList
              //           .map((e) => buildDeviceControl(context, e))
              //           .toList(),
              //       // Container(
              //       //   padding: const EdgeInsets.fromLTRB(10, 0, 20, 5),
              //       //   width: size.width,
              //       //   height: size.height * 0.08,
              //       //   alignment: Alignment.center,
              //       //   decoration: BoxDecoration(
              //       //     color: Colors.lightBlue.shade50.withOpacity(0.5),
              //       //     border:
              //       //         Border.all(color: Colors.blueAccent, width: 1.2),
              //       //     borderRadius: BorderRadius.circular(10),
              //       //   ),
              //       //   child: Row(
              //       //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       //     children: [
              //       //       Row(
              //       //         children: [
              //       //           Image.asset(
              //       //             "assets/images/living-room.png",
              //       //             width: 36,
              //       //           ),
              //       //           const Text(
              //       //             ' Đèn chiếu sáng',
              //       //             style: TextStyle(
              //       //                 fontWeight: FontWeight.bold,
              //       //                 fontSize: 18),
              //       //           ),
              //       //         ],
              //       //       ),
              //       //       Transform.scale(
              //       //           scale: 1,
              //       //           child: Switch(
              //       //             onChanged: toggleSwitchLed1,
              //       //             value: led1,
              //       //             activeColor: Colors.blue,
              //       //             activeTrackColor: Colors.yellow,
              //       //             inactiveThumbColor: Colors.redAccent,
              //       //             inactiveTrackColor: Colors.orange,
              //       //           )),
              //       //     ],
              //       //   ),
              //       // ),
              //       // Container(
              //       //   padding: const EdgeInsets.fromLTRB(10, 0, 20, 5),
              //       //   margin: const EdgeInsets.fromLTRB(0, 6, 0, 0),
              //       //   width: size.width,
              //       //   height: size.height * 0.08,
              //       //   alignment: Alignment.center,
              //       //   decoration: BoxDecoration(
              //       //     color: Colors.lightBlue.shade50.withOpacity(0.5),
              //       //     border:
              //       //         Border.all(color: Colors.blueAccent, width: 1.2),
              //       //     borderRadius: BorderRadius.circular(10),
              //       //   ),
              //       //   child: Row(
              //       //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       //     children: [
              //       //       Row(
              //       //         children: [
              //       //           Image.asset(
              //       //             "assets/images/living-room.png",
              //       //             width: 36,
              //       //           ),
              //       //           Text(
              //       //             ' Quạt điện ',
              //       //             style: TextStyle(
              //       //                 fontWeight: FontWeight.bold,
              //       //                 fontSize: 18),
              //       //           ),
              //       //         ],
              //       //       ),
              //       //       Transform.scale(
              //       //           scale: 1,
              //       //           child: Switch(
              //       //             onChanged: toggleSwitchAirConditioning,
              //       //             value: airConditioning,
              //       //             activeColor: Colors.blue,
              //       //             activeTrackColor: Colors.yellow,
              //       //             inactiveThumbColor: Colors.redAccent,
              //       //             inactiveTrackColor: Colors.orange,
              //       //           )),
              //       //     ],
              //       //   ),
              //       // ),
              //       // Container(
              //       //   padding: const EdgeInsets.fromLTRB(10, 0, 20, 5),
              //       //   margin: const EdgeInsets.fromLTRB(0, 6, 0, 0),
              //       //   width: size.width,
              //       //   height: size.height * 0.08,
              //       //   alignment: Alignment.center,
              //       //   decoration: BoxDecoration(
              //       //     color: Colors.lightBlue.shade50.withOpacity(0.5),
              //       //     border:
              //       //         Border.all(color: Colors.blueAccent, width: 1.2),
              //       //     borderRadius: BorderRadius.circular(10),
              //       //   ),
              //       //   child: Row(
              //       //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       //     children: [
              //       //       Row(
              //       //         children: [
              //       //           Image.asset(
              //       //             "assets/images/living-room.png",
              //       //             width: 36,
              //       //           ),
              //       //           Text(
              //       //             ' Đèn cảnh báo',
              //       //             style: TextStyle(
              //       //                 fontWeight: FontWeight.bold,
              //       //                 fontSize: 18),
              //       //           ),
              //       //         ],
              //       //       ),
              //       //       // Row(
              //       //       //   children: [
              //       //       //     const Text(
              //       //       //       'Auto',
              //       //       //       style: TextStyle(
              //       //       //           fontWeight: FontWeight.bold, fontSize: 18),
              //       //       //     ),
              //       //       //     Transform.scale(
              //       //       //         scale: 1,
              //       //       //         child: Switch(
              //       //       //           onChanged: toggleAuto,
              //       //       //           value: auto,
              //       //       //         )),
              //       //       //   ],
              //       //       // ),
              //       //       auto
              //       //           ? Transform.scale(
              //       //               scale: 1,
              //       //               child: Switch(
              //       //                 onChanged: null,
              //       //                 value: led2,
              //       //               ))
              //       //           : Transform.scale(
              //       //               scale: 1,
              //       //               child: Switch(
              //       //                 onChanged: toggleSwitchLed2,
              //       //                 value: led2,
              //       //                 activeColor: Colors.blue,
              //       //                 activeTrackColor: Colors.yellow,
              //       //                 inactiveThumbColor: Colors.redAccent,
              //       //                 inactiveTrackColor: Colors.orange,
              //       //               ))
              //       //     ],
              //       //   ),
              //       // ),
              //     ),
              //   ),
              // if (widget.room == Room.bedRoom)
              //   Container(
              //     padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
              //     margin: const EdgeInsets.fromLTRB(0, 6, 0, 0),
              //     width: size.width,
              //     child: Column(
              //       mainAxisAlignment: MainAxisAlignment.start,
              //       children: [
              //         Container(
              //           padding: const EdgeInsets.fromLTRB(10, 0, 20, 5),
              //           width: size.width,
              //           height: size.height * 0.08,
              //           alignment: Alignment.center,
              //           decoration: BoxDecoration(
              //             color: Colors.lightBlue.shade50.withOpacity(0.5),
              //             border:
              //                 Border.all(color: Colors.blueAccent, width: 1.2),
              //             borderRadius: BorderRadius.circular(10),
              //           ),
              //           child: Row(
              //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //             children: [
              //               Row(
              //                 children: [
              //                   Image.asset(
              //                     "assets/images/living-room.png",
              //                     width: 36,
              //                   ),
              //                   const Text(
              //                     ' Đèn chiếu sáng',
              //                     style: TextStyle(
              //                         fontWeight: FontWeight.bold,
              //                         fontSize: 18),
              //                   ),
              //                 ],
              //               ),
              //               Transform.scale(
              //                   scale: 1,
              //                   child: Switch(
              //                     onChanged: toggleSwitchLed1,
              //                     value: led1,
              //                     activeColor: Colors.blue,
              //                     activeTrackColor: Colors.yellow,
              //                     inactiveThumbColor: Colors.redAccent,
              //                     inactiveTrackColor: Colors.orange,
              //                   )),
              //             ],
              //           ),
              //         ),
              //         Container(
              //           padding: const EdgeInsets.fromLTRB(10, 0, 20, 5),
              //           margin: const EdgeInsets.fromLTRB(0, 6, 0, 0),
              //           width: size.width,
              //           height: size.height * 0.08,
              //           alignment: Alignment.center,
              //           decoration: BoxDecoration(
              //             color: Colors.lightBlue.shade50.withOpacity(0.5),
              //             border:
              //                 Border.all(color: Colors.blueAccent, width: 1.2),
              //             borderRadius: BorderRadius.circular(10),
              //           ),
              //           child: Row(
              //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //             children: [
              //               Row(
              //                 children: [
              //                   Image.asset(
              //                     "assets/images/living-room.png",
              //                     width: 36,
              //                   ),
              //                   Text(
              //                     'Đèn nền ',
              //                     style: TextStyle(
              //                         fontWeight: FontWeight.bold,
              //                         fontSize: 18),
              //                   ),
              //                 ],
              //               ),
              //               Transform.scale(
              //                   scale: 1,
              //                   child: Switch(
              //                     onChanged: toggleSwitchAirConditioning,
              //                     value: airConditioning,
              //                     activeColor: Colors.blue,
              //                     activeTrackColor: Colors.yellow,
              //                     inactiveThumbColor: Colors.redAccent,
              //                     inactiveTrackColor: Colors.orange,
              //                   )),
              //             ],
              //           ),
              //         ),
              //         Container(
              //           padding: const EdgeInsets.fromLTRB(10, 0, 20, 5),
              //           margin: const EdgeInsets.fromLTRB(0, 6, 0, 0),
              //           width: size.width,
              //           height: size.height * 0.08,
              //           alignment: Alignment.center,
              //           decoration: BoxDecoration(
              //             color: Colors.lightBlue.shade50.withOpacity(0.5),
              //             border:
              //                 Border.all(color: Colors.blueAccent, width: 1.2),
              //             borderRadius: BorderRadius.circular(10),
              //           ),
              //           child: Row(
              //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //             children: [
              //               Row(
              //                 children: [
              //                   Image.asset(
              //                     "assets/images/living-room.png",
              //                     width: 36,
              //                   ),
              //                   const Text(
              //                     'Điều hòa',
              //                     style: TextStyle(
              //                         fontWeight: FontWeight.bold,
              //                         fontSize: 18),
              //                   ),
              //                 ],
              //               ),
              //               Transform.scale(
              //                   scale: 1,
              //                   child: Switch(
              //                     onChanged: toggleSwitchLed2,
              //                     value: led2,
              //                     activeColor: Colors.blue,
              //                     activeTrackColor: Colors.yellow,
              //                     inactiveThumbColor: Colors.redAccent,
              //                     inactiveTrackColor: Colors.orange,
              //                   ))
              //             ],
              //           ),
              //         ),
              //         Container(
              //           padding: const EdgeInsets.fromLTRB(10, 0, 20, 5),
              //           margin: const EdgeInsets.fromLTRB(0, 6, 0, 0),
              //           width: size.width,
              //           height: size.height * 0.08,
              //           alignment: Alignment.center,
              //           decoration: BoxDecoration(
              //             color: Colors.lightBlue.shade50.withOpacity(0.5),
              //             border:
              //                 Border.all(color: Colors.blueAccent, width: 1.2),
              //             borderRadius: BorderRadius.circular(10),
              //           ),
              //           child: Row(
              //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //             children: [
              //               Row(
              //                 children: [
              //                   Image.asset(
              //                     "assets/images/living-room.png",
              //                     width: 36,
              //                   ),
              //                   const Text(
              //                     'Rèm cửa sổ',
              //                     style: TextStyle(
              //                         fontWeight: FontWeight.bold,
              //                         fontSize: 18),
              //                   ),
              //                 ],
              //               ),
              //               Transform.scale(
              //                   scale: 1,
              //                   child: Switch(
              //                     onChanged: toggleSwitchLed2,
              //                     value: led2,
              //                     activeColor: Colors.blue,
              //                     activeTrackColor: Colors.yellow,
              //                     inactiveThumbColor: Colors.redAccent,
              //                     inactiveTrackColor: Colors.orange,
              //                   ))
              //             ],
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // if (widget.room == Room.kitchen)
              //   Container(
              //     padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
              //     margin: const EdgeInsets.fromLTRB(0, 6, 0, 0),
              //     width: size.width,
              //     child: Column(
              //       mainAxisAlignment: MainAxisAlignment.start,
              //       children: [
              //         Container(
              //           padding: const EdgeInsets.fromLTRB(10, 0, 20, 5),
              //           width: size.width,
              //           height: size.height * 0.08,
              //           alignment: Alignment.center,
              //           decoration: BoxDecoration(
              //             color: Colors.lightBlue.shade50.withOpacity(0.5),
              //             border:
              //                 Border.all(color: Colors.blueAccent, width: 1.2),
              //             borderRadius: BorderRadius.circular(10),
              //           ),
              //           child: Row(
              //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //             children: [
              //               Row(
              //                 children: [
              //                   Image.asset(
              //                     "assets/images/living-room.png",
              //                     width: 36,
              //                   ),
              //                   const Text(
              //                     ' Đèn chiếu sáng',
              //                     style: TextStyle(
              //                         fontWeight: FontWeight.bold,
              //                         fontSize: 18),
              //                   ),
              //                 ],
              //               ),
              //               Transform.scale(
              //                   scale: 1,
              //                   child: Switch(
              //                     onChanged: toggleSwitchLed1,
              //                     value: led1,
              //                     activeColor: Colors.blue,
              //                     activeTrackColor: Colors.yellow,
              //                     inactiveThumbColor: Colors.redAccent,
              //                     inactiveTrackColor: Colors.orange,
              //                   )),
              //             ],
              //           ),
              //         ),
              //         Container(
              //           padding: const EdgeInsets.fromLTRB(10, 0, 20, 5),
              //           margin: const EdgeInsets.fromLTRB(0, 6, 0, 0),
              //           width: size.width,
              //           height: size.height * 0.08,
              //           alignment: Alignment.center,
              //           decoration: BoxDecoration(
              //             color: Colors.lightBlue.shade50.withOpacity(0.5),
              //             border:
              //                 Border.all(color: Colors.blueAccent, width: 1.2),
              //             borderRadius: BorderRadius.circular(10),
              //           ),
              //           child: Row(
              //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //             children: [
              //               Row(
              //                 children: [
              //                   Image.asset(
              //                     "assets/images/living-room.png",
              //                     width: 36,
              //                   ),
              //                   const Text(
              //                     ' Quạt điện ',
              //                     style: TextStyle(
              //                         fontWeight: FontWeight.bold,
              //                         fontSize: 18),
              //                   ),
              //                 ],
              //               ),
              //               Transform.scale(
              //                   scale: 1,
              //                   child: Switch(
              //                     onChanged: toggleSwitchAirConditioning,
              //                     value: airConditioning,
              //                     activeColor: Colors.blue,
              //                     activeTrackColor: Colors.yellow,
              //                     inactiveThumbColor: Colors.redAccent,
              //                     inactiveTrackColor: Colors.orange,
              //                   )),
              //             ],
              //           ),
              //         ),
              //         Container(
              //           padding: const EdgeInsets.fromLTRB(10, 0, 20, 5),
              //           margin: const EdgeInsets.fromLTRB(0, 6, 0, 0),
              //           width: size.width,
              //           height: size.height * 0.08,
              //           alignment: Alignment.center,
              //           decoration: BoxDecoration(
              //             color: Colors.lightBlue.shade50.withOpacity(0.5),
              //             border:
              //                 Border.all(color: Colors.blueAccent, width: 1.2),
              //             borderRadius: BorderRadius.circular(10),
              //           ),
              //           child: Row(
              //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //             children: [
              //               Row(
              //                 children: [
              //                   Image.asset(
              //                     "assets/images/living-room.png",
              //                     width: 36,
              //                   ),
              //                   Text(
              //                     ' Đèn cảnh báo',
              //                     style: TextStyle(
              //                         fontWeight: FontWeight.bold,
              //                         fontSize: 18),
              //                   ),
              //                 ],
              //               ),
              //               // Row(
              //               //   children: [
              //               //     const Text(
              //               //       'Auto',
              //               //       style: TextStyle(
              //               //           fontWeight: FontWeight.bold, fontSize: 18),
              //               //     ),
              //               //     Transform.scale(
              //               //         scale: 1,
              //               //         child: Switch(
              //               //           onChanged: toggleAuto,
              //               //           value: auto,
              //               //         )),
              //               //   ],
              //               // ),
              //               auto
              //                   ? Transform.scale(
              //                       scale: 1,
              //                       child: Switch(
              //                         onChanged: null,
              //                         value: led2,
              //                       ))
              //                   : Transform.scale(
              //                       scale: 1,
              //                       child: Switch(
              //                         onChanged: toggleSwitchLed2,
              //                         value: led2,
              //                         activeColor: Colors.blue,
              //                         activeTrackColor: Colors.yellow,
              //                         inactiveThumbColor: Colors.redAccent,
              //                         inactiveTrackColor: Colors.orange,
              //                       ))
              //             ],
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              Row(
                children: [
                  Text(
                    ' Biểu đồ ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.red),
                  ),
                  SizedBox(
                    width: 36,
                  ),
                  DropdownButton(
                    dropdownColor: Colors.grey.shade100,
                    value: times,
                    items: dropdownItems,
                    onChanged: (String? value) {
                      roomBloc!.add(LivingRoomEventStated(time: value!));
                      setState(() {
                        times = value!;
                      });
                    },
                  )
                ],
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.show_chart,
                        color: Colors.red,
                        size: 30,
                      ),
                      const Text('Nhiệt độ'),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 0, 20, 0),
                        child: Row(
                          children: const [
                            Icon(Icons.show_chart,
                                color: Colors.blue, size: 30),
                            Text('Độ ẩm'),
                          ],
                        ),
                      )
                    ],
                  ),
                  Card(
                    child: BlocBuilder<LivingRoomBloc, LivingRoomState>(
                        builder: (context, state) {
                      if (state is LivingRoomLoadingState) {
                        return Container(
                            alignment: Alignment.topCenter,
                            height: size.height * 0.18,
                            child: const CircularProgressIndicator());
                      } else if (state is LivingRoomLoadedState) {
                        sensorsResponse = state.sensorsResponse;
                        // print(sensorsResponse.toJson());
                        List<Result>? data = sensorsResponse.result ??
                            [
                              Result(
                                humidityAir: 0,
                                temperature: 0,
                                time: 1,
                              ),
                              Result(
                                humidityAir: 0,
                                temperature: 0,
                                time: 1,
                              ),
                            ];
                        // List<Result>? data = [
                        //   Result(
                        //     humidityAir: 67,
                        //     temperature: 23,
                        //     time: 1,
                        //   ),
                        //   Result(
                        //     humidityAir: 68,
                        //     temperature: 22,
                        //     time: 1,
                        //   ),
                        //   Result(
                        //     humidityAir: 69,
                        //     temperature: 21,
                        //     time: 1,
                        //   ),
                        //   Result(
                        //     humidityAir: 72,
                        //     temperature: 24,
                        //     time: 1,
                        //   ),
                        //   Result(
                        //     humidityAir: 67,
                        //     temperature: 23,
                        //     time: 1,
                        //   ),
                        //   Result(
                        //     humidityAir: 72,
                        //     temperature: 23,
                        //     time: 1,
                        //   ),
                        //   Result(
                        //     humidityAir: 77,
                        //     temperature: 23,
                        //     time: 1,
                        //   ),
                        //   Result(
                        //     humidityAir: 67,
                        //     temperature: 24,
                        //     time: 1,
                        //   ),
                        //   Result(
                        //     humidityAir: 67,
                        //     temperature: 23,
                        //     time: 1,
                        //   ),
                        //   Result(
                        //     humidityAir: 67,
                        //     temperature: 23,
                        //     time: 1,
                        //   )
                        // ];
                        final List<FlSpot> dummyData1 =
                            List.generate(data!.length, (index) {
                          return FlSpot(index.toDouble(),
                              data[index].humidityAir!.toDouble());
                        });

                        final List<FlSpot> dummyData2 =
                            List.generate(data!.length, (index) {
                          return FlSpot(index.toDouble(),
                              data[index].temperature!.toDouble());
                        });
                        return Container(
                          height: size.height * 0.4,
                          padding: const EdgeInsets.fromLTRB(0, 5, 5, 0),
                          child: LineChart(
                            LineChartData(
                              minY: 0,
                              maxY: 100,
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 35,
                                  getTextStyles: (value) => const TextStyle(
                                    color: Color(0xff68737d),
                                    fontSize: 14,
                                  ),
                                  getTitles: (value) {
                                    switch (value.toInt()) {
                                      // case 0:
                                      //   return '24h trước';
                                      // case 10:
                                      //   return '12h trước';
                                      // case 20:
                                      //   return 'Hiện tại';
                                    }
                                    return '';
                                  },
                                  margin: 8,
                                ),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: dummyData1,
                                  isCurved: true,
                                  barWidth: 3,
                                  colors: [
                                    Colors.blue,
                                  ],
                                ),
                                LineChartBarData(
                                  spots: dummyData2,
                                  isCurved: true,
                                  barWidth: 3,
                                  colors: [
                                    Colors.red,
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDeviceControl(BuildContext context, DeviceStatus device) {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 20, 5),
      margin: const EdgeInsets.only(bottom: 8),
      width: size.width,
      height: size.height * 0.08,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade50.withOpacity(0.5),
        border: Border.all(color: Colors.blueAccent, width: 1.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                "assets/images/device.png",
                width: 36,
              ),
              Text(
                device.name ?? '',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          Transform.scale(
              scale: 1,
              child: Switch(
                onChanged: (value) {
                  toggleSwitchLed1(value, device.sId ?? '',device);
                },
                value: device.statusControl ?? false,
                activeColor: Colors.blue,
                activeTrackColor: Colors.yellow,
                inactiveThumbColor: Colors.redAccent,
                inactiveTrackColor: Colors.orange,
              )),
        ],
      ),
    );
  }
}
