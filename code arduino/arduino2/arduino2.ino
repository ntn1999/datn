
#include <ESP8266WiFi.h>
#include <WiFiUdp.h>
#include <PubSubClient.h>
#include <DHT.h>
#include "MQ135.h"
#include <ArduinoJson.h>
#include <string.h>


#define ssid "TP-LINK_B8EE" 
#define password "123abc@A" 

const long utcOffsetInSeconds = 25200;
// Define NTP Client to get time
WiFiUDP ntpUDP;
//NTPClient timeClient(ntpUDP, "pool.ntp.org", utcOffsetInSeconds);

// Thông tin về MQTT Broker
#define mqtt_server "broker.hivemq.com" 
#define mqtt_topic_pub "demo1" //Thực tế tên topic ứng với ID khách hàng

const uint16_t mqtt_port = 1883; //Port của CloudMQTT
//const int D0 = 16;
//const int D1 = 5;
//const int D2 = 4;
//const int D3 = 0;
//const int D4 = 2;
//const int D5 = 14;
//const int D6 = 12;
//const int D7 = 13;
//const int D8 = 15;

int inputPinMotion = 13;
  
MQ135 gasSensor = MQ135(A0);
int val;
int sensorPin = A0;
int sensorValue = 0;
int lights5 = 0, 
int lights6 = 0, 
int lights7 = 0, 
int lights8 = 0, 
WiFiClient espClient;
PubSubClient client(espClient);

long lastMsg = 0;
char msg[50];
  
void setup(){
   delay(200);
   Serial.begin(115200); // Baudrate to display data on serial monitor
   setup_wifi();
    pinMode(inputPinMotion, INPUT);
    pinMode(sensorPin, INPUT);
    pinMode(12, INPUT);
    pinMode(4, OUTPUT); 
    pinMode(0, OUTPUT);
    pinMode(2, OUTPUT);
    pinMode(14, OUTPUT);
    pinMode(15, OUTPUT);
    pinMode(13, OUTPUT);
    
    client.setServer(mqtt_server, mqtt_port);

  client.setCallback(callback);
}

void setup_wifi() {
  delay(10);
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}

// Hàm call back để nhận dữ liệu.
void callback(char* topic, byte* payload, unsigned int length) {
  if (strcmp(topic, "lights5") == 0) {// Trong thực tế "lights1 sẽ được thay thế bằng ID của thiết bị", tương tự với lighs2,3,4,...
    char messing[200];
    for (int i = 0; i < length; i++) {
      messing[i] = (char)payload[i];
    }
     Serial.println(messing);
    StaticJsonBuffer<200> subscribes;
    JsonObject& root = subscribes.parseObject(messing);
    const char* status = root["Status"];
    lights5 = int(status[0] - 48);
    digitalWrite(4, lights5);//D2=4
    
  } else if (strcmp(topic, "lights6") == 0) {
    char messing[200];
    for (int i = 0; i < length; i++) {
      messing[i] = payload[i];
    }
    StaticJsonBuffer<200> subscribes;
    JsonObject& root = subscribes.parseObject(messing);
    const char* status = root["Status"];
    lights6 = int(status[0] - 48);
    Serial.println(lights6);
    digitalWrite(0, lights6);//D3=0
  } else if (strcmp(topic, "lights7") == 0) {
    char messing[200];
    for (int i = 0; i < length; i++) {
      messing[i] = payload[i];
      //Serial.print(timer[i]);
    }
    StaticJsonBuffer<200> subscribes;
    JsonObject& root = subscribes.parseObject(messing);
    const char* status = root["Status"];
    lights7 = int(status[0] - 48);
    Serial.println(lights7);
    digitalWrite(2, lights7);//D4=2
  } else if (strcmp(topic, "lights8") == 0) {
    char messing[200];
    for (int i = 0; i < length; i++) {
      messing[i] = payload[i];
      //Serial.print(timer[i]);
    }
    StaticJsonBuffer<200> subscribes;
    JsonObject& root = subscribes.parseObject(messing);
    const char* status = root["Status"];
    lights8 = int(status[0] - 48);
    Serial.println(lights8);
     digitalWrite(14, lights8);//D5=14
  }
}

void reconnect() {
  // Chờ tới khi kết nối
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    // Thực hiện kết nối với mqtt
    String clientId = "ESP8266Client-";
    clientId += String(random(0xffff), HEX);
    if (client.connect(clientId.c_str())) {
      Serial.println("connected");
      // Khi kết nối sẽ publish thông báo
      client.publish(mqtt_topic_pub, "ESP_reconnected");
      client.subscribe(mqtt_topic_pub);
      client.subscribe("lights5");// Trong thực tế, các topic này sẽ tương ứng với ID của thiết bị
      client.subscribe("lights6");
      client.subscribe("lights7");
      client.subscribe("lights8");
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      // Đợi 5s
      delay(5000);
    }
  }
}

  
void loop(){
   if (!client.connected()) {
    reconnect();
   }
  client.loop();
  long now = millis();
  if (now - lastMsg > 5000) {
     val = analogRead(A0);
    Serial.print ("raw = ");Serial.println (val);
    float ppm = gasSensor.getPPM();
    lastMsg = now;
    StaticJsonBuffer<300> JSONbuffer;
    JsonObject& JSONencoder = JSONbuffer.createObject();
    JSONencoder["ppmVal"] = ppm;

    char JSONmessageBuffer[100];
    JSONencoder.printTo(JSONmessageBuffer, sizeof(JSONmessageBuffer));
    //Serial.println(JSONmessageBuffer);
    client.publish(mqtt_topic_pub, JSONmessageBuffer);
    
  }
  
  int motion = digitalRead(inputPinMotion);
  if (motion == HIGH && digitalRead(12) == 1) {
      Serial.println("Motion detected!");
       digitalWrite(15, 1);
    }
    else {
      Serial.println("No Motion detected!");
       digitalWrite(15, 0);
    }
   delay(1000);
}
