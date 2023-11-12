// import 'dart:async';
//
// import 'package:mqtt_client/mqtt_client.dart';
// import 'package:mqtt_client/mqtt_server_client.dart' as mqttServer;
// import 'package:mqtt_client/mqtt_client.dart' as mqtt;
//
// class MQTT {
//   String broker           = 'broker.mqttdashboard.com';
//   int port                = 1883;
//   String clientIdentifier = 'flutter';
//
//
//
//   late mqttServer.MqttServerClient client;
//   late mqtt.MqttConnectionState connectionState;
//
//   StreamSubscription? subscription;
//
//   void _subscribeToTopic(String topic) {
//     if (connectionState == mqtt.MqttConnectionState.connected) {
//       print('[MQTT client] Subscribing to ${topic.trim()}');
//       client.subscribe(topic, mqtt.MqttQos.exactlyOnce);
//
//     }
//     print('[MQTT client] onScribe');
//
//   }
//
//   void publishTopic(String pubTopic,String message){
//     final builder = MqttClientPayloadBuilder();
//     builder.addString(message);
//     client.publishMessage(pubTopic, MqttQos.atLeastOnce, builder.payload);
//   }
//
//   void connect() async {
//     client = mqttServer.MqttServerClient('broker.mqttdashboard.com','');
//     client.logging(on: false);
//     client.keepAlivePeriod = 30;
//     client.onDisconnected = _onDisconnected;
//
//     final mqtt.MqttConnectMessage connMess = mqtt.MqttConnectMessage()
//         .withClientIdentifier(clientIdentifier)
//         .startClean() // Non persistent session for testing
//         .keepAliveFor(30)
//         .withWillQos(mqtt.MqttQos.atMostOnce);
//     print('[MQTT client] MQTT client connecting....');
//     client.connectionMessage = connMess;
//
//     try {
//       await client.connect('','');
//     } catch (e) {
//       print('lỗi rồi, disconnect thôi');
//       _disconnect();
//     }
//
//     /// Check if we are connected
//     if (client.connectionState == mqtt.MqttConnectionState.connected) {
//       print('[MQTT client] connected');
//         connectionState = client.connectionStatus.state;
//     } else {
//       print('[MQTT client] ERROR: MQTT client connection failed - '
//           'disconnecting, state is ${client.connectionState}');
//       _disconnect();
//     }
//
//     /// The client has a change notifier object(see the Observable class) which we then listen to to get
//     /// notifications of published updates to each subscribed topic.
//
//
//
//     subscription = client.updates.listen(_onMessage);
//
//     _subscribeToTopic("test1");
//
//     publishTopic('testPub','aaaaaaa');
//   }
//
//   void _disconnect() {
//     print('[MQTT client] _disconnect()');
//     client.disconnect();
//     _onDisconnected();
//   }
//
//
//   void _onDisconnected() {
//     // setState(() {
//     //   //topics.clear();
//     //   connectionState = client.connectionState;
//     //   client = null;
//     //   subscription!.cancel();
//     //   subscription = null;
//     // });
//     print('[MQTT client] MQTT client disconnected');
//   }
//
//   String _onMessage(List<mqtt.MqttReceivedMessage> event) {
//     print(event.length);
//     final mqtt.MqttPublishMessage recMess =
//     event[0].payload as mqtt.MqttPublishMessage;
//     final String message = mqtt.MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
//
//
//     print('[MQTT client] MQTT message: topic is <${event[0].topic}>, '
//         'payload is <-- ${message} -->');
//     print(client.connectionState);
//     print("[MQTT client] message with topic: ${event[0].topic}");
//     print("[MQTT client] message with message: ${message}");
//     return message;
//     // setState(() {
//     //   _temp = double.parse(message);
//     // });
//   }
//
//
// }
