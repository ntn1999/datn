import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:iot_demo/blocs/home/home_bloc.dart';
import 'package:iot_demo/datasource/models/sensor_sub.dart';
import 'package:iot_demo/presentation/home/device_screen.dart';
import 'package:iot_demo/presentation/home/room_screen.dart';
import 'package:iot_demo/presentation/home/profile_screen.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mqtt_client/mqtt_server_client.dart' as mqttServer;
import 'package:mqtt_client/mqtt_client.dart' as mqtt;

import '../../blocs/get_infor/device_bloc.dart';
import '../../blocs/living_room/living_room_bloc.dart';
import '../../datasource/models/devices_res.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark));
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return MultiBlocProvider(
        providers: [
          BlocProvider<HomeBloc>(
              create: (_) => HomeBloc()..add(HomeEventStated())),
          BlocProvider<DeviceBloc>(
              create: (_) => DeviceBloc()..add(DeviceEventStated())),
        ],
        child: Scaffold(
          //extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            elevation: 0,
            title: Container(
              child: Text(
                'IOT Smart Home',
                style: Theme.of(context).textTheme.caption!.copyWith(
                      color: Colors.blue,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          body: BuildHomeScreen(),
        ));
  }
}

class BuildHomeScreen extends StatefulWidget {
  const BuildHomeScreen({Key? key}) : super(key: key);

  @override
  _BuildHomeScreenState createState() => _BuildHomeScreenState();
}

class _BuildHomeScreenState extends State<BuildHomeScreen>
    with SingleTickerProviderStateMixin {
  String avatar = '';
  TabController? _tabController;

//  var mqtt= MQTT();
  String humidityAir = '...';
  String temperature = '...';

  String broker = 'broker.hivemq.com';
  int port = 1883;
  String clientIdentifier = 'flutter';

  late mqttServer.MqttServerClient client;
  late mqtt.MqttConnectionState connectionState;

  StreamSubscription? subscription;

  void _subscribeToTopic(String topic) {
    if (connectionState == mqtt.MqttConnectionState.connected) {
      print('[MQTT client] Subscribing to ${topic.trim()}');
      client.subscribe(topic, mqtt.MqttQos.exactlyOnce);
    }
    print('[MQTT client] onScribe');
  }

  void _connect() async {
    client = mqttServer.MqttServerClient('broker.hivemq.com', '');
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

    // const pubTopic = 'lam1';
    // final builder = MqttClientPayloadBuilder();
    // builder.addString('Hello MQTT');
    // client.publishMessage(pubTopic, MqttQos.atLeastOnce, builder.payload);
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

  @override
  void initState() {
    // TODO: implement initState
    _tabController = TabController(length: 3, vsync: this);
    _connect();
    //   mqtt.publishTopic('pubTopic', 'message');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      // padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 0.4),
                  top: BorderSide(color: Colors.blueAccent, width: 0.8),
                ),
              ),
              child: BlocBuilder<DeviceBloc, DeviceState>(
                  builder: (context, state) {
                if (state is DeviceLoadingState) {
                  return Container(
                      alignment: Alignment.topCenter,
                      height: size.height * 0.18,
                      child: const CircularProgressIndicator());
                } else if (state is GetDeviceLoadedState) {
                  return TabBarView(
                    children: [
                      _home(context, state.listDevice.devices ?? []),
                      //ProFileScreen(),
                      _device(context),
                      _profile(context),
                      //_rank(context)
                    ],
                    controller: _tabController,
                  );
                } else {
                  return Container();
                }
              }),
            ),
          ),
          ColoredBox(
            color: Colors.grey.shade50,
            child: TabBar(
              unselectedLabelColor: Colors.black54,
              labelColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 4),
              tabs: const [
                Tab(
                  child: Icon(
                    Icons.home,
                    size: 34,
                  ),
                ),
                Tab(
                  child: Icon(
                    Icons.developer_board,
                    size: 34,
                  ),
                ),
                Tab(
                  child: Icon(
                    Icons.person,
                    size: 34,
                  ),
                ),
                // Tab(
                //   child: Icon(
                //     Icons.settings_outlined,
                //     size: 30,
                //   ),
                // ),
              ],
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
            ),
          ),
        ],
      ),
    );
  }

  Widget _home(BuildContext context, List<Devices> devices) {
    Size size = MediaQuery.of(context).size;
    List<Devices> deviceKitchen =
        devices.where((e) => e.room == 'kitchen').toList();
    List<Devices> deviceLiving =
        devices.where((e) => e.room == 'living-room').toList();
    List<Devices> deviceBathroom =
        devices.where((e) => e.room == 'bathroom').toList();
    List<Devices> deviceBedroom =
        devices.where((e) => e.room == 'bedroom').toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (deviceLiving.isNotEmpty)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LivingRoomScreen(
                            room: Room.livingRoom,
                            deviceList: deviceLiving,
                          )),
                );
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(5, 10, 0, 0),
                padding: const EdgeInsets.fromLTRB(10, 0, 20, 5),
                width: size.width * 0.9,
                height: size.width * 0.4,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topLeft,
                          child: Image.asset(
                            "assets/images/living-room.png",
                            width: size.width * 0.24,
                          ),
                        ),
                        const Text(
                          "Phòng khách",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/humidity.png',
                              width: 40,
                            ),
                            Text(
                              humidityAir,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/temperature.png',
                              width: 40,
                            ),
                            Text(
                              temperature,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          if (deviceBedroom.isNotEmpty)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LivingRoomScreen(
                            room: Room.bedRoom,
                            deviceList: deviceBedroom,
                          )),
                );
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(5, 10, 0, 0),
                padding: const EdgeInsets.fromLTRB(10, 0, 20, 5),
                width: size.width * 0.88,
                height: size.width * 0.4,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topLeft,
                          child: Image.asset(
                            'assets/images/bedroom.png',
                            width: size.width * 0.25,
                          ),
                        ),
                        const Text(
                          "Phòng ngủ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/humidity.png',
                              width: 40,
                            ),
                            Text(
                              humidityAir,
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/temperature.png',
                              width: 40,
                            ),
                            Text(
                              temperature,
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          if (deviceKitchen.isNotEmpty)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LivingRoomScreen(
                            room: Room.kitchen,
                            deviceList: deviceKitchen,
                          )),
                );
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(5, 10, 0, 0),
                padding: const EdgeInsets.fromLTRB(10, 0, 20, 5),
                width: size.width * 0.88,
                height: size.width * 0.4,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topLeft,
                          child: Image.asset(
                            "assets/images/kitchen.png",
                            width: size.width * 0.23,
                          ),
                        ),
                        const Text(
                          "Phòng bếp",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/humidity.png',
                              width: 40,
                            ),
                            Text(
                              humidityAir,
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/temperature.png',
                              width: 40,
                            ),
                            Text(
                              temperature,
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          if (deviceBathroom.isNotEmpty)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LivingRoomScreen(
                            room: Room.bathroom,
                            deviceList: deviceBathroom,
                          )),
                );
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(5, 10, 0, 0),
                padding: const EdgeInsets.fromLTRB(10, 0, 20, 5),
                width: size.width * 0.88,
                height: size.width * 0.4,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topLeft,
                          child: Image.asset(
                            "assets/images/bathroom1.png",
                            width: size.width * 0.23,
                          ),
                        ),
                        const Text(
                          "Phòng tắm",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/humidity.png',
                              width: 40,
                            ),
                            Text(
                              humidityAir,
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/temperature.png',
                              width: 40,
                            ),
                            Text(
                              temperature,
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _profile(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return const ProFileScreen();
  }

  Widget _device(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return DeviceScreen();
  }

  Widget _rank(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
        margin: const EdgeInsets.only(top: 10), child: Text('rank'));
  }
}
