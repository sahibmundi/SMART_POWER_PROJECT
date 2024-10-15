#include <WiFi.h>
#include <PubSubClient.h>

int sensorVal;

const char* ssid = "SSID";
const char* passwd = "Password";

char writeApiKey[] = "FJIGDGIC3F0X15OC";
long channelId = 2596814;

char userName[] = "BAMAGikZNTMsEyg4FQURDwo";
char passKey[] = "n1VunHZcX4eQWqANjK+0opeF";
char clientId[] = "BAMAGikZNTMsEyg4FQURDwo";

WiFiClient client;

const char* server = "mqtt3.thingspeak.com";

PubSubClient mqttClient(client);

unsigned long lastConnectionTime = 0;
const unsigned long postingInterval = 1 * 1000;

#define TRIG_PIN 5
#define ECHO_PIN 18
#define LDR_PIN 34   // LDR sensor connected to GPIO 34
#define RELAY_PIN 25
#define RELAY_PIN2 26

void setup() {
  Serial.begin(115200);
  int status = WL_IDLE_STATUS;

  Serial.println("Esp32 started..!");

  while(status != WL_CONNECTED){
    status = WiFi.begin(ssid, passwd);
    status = WL_CONNECTED;
    delay(5000);
  }

  Serial.println("Connected to Wifi...");
  mqttClient.setServer(server, 1883);
  Serial.print("mqttClient State: "); 
  Serial.println(mqttClient.state());

  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  pinMode(LDR_PIN, INPUT);   // Set GPIO 34 as an input
  pinMode(RELAY_PIN, OUTPUT);
  pinMode(RELAY_PIN2, OUTPUT);
}

void loop() {
  if(!mqttClient.connected()){
    reconnect();
  }

  mqttClient.loop();

  if(millis() - lastConnectionTime > postingInterval){
    Serial.print("mqttClient State: "); 
    Serial.println(mqttClient.state());

    int distance = calculateDistance();
    int mappedDistance = map(distance, 12, 2, 0, 100); // Map the distance to 0-100
    int ldrValue = analogRead(LDR_PIN);
    int mappedLDRValue = map(ldrValue, 1600, 4095, 0, 100);  // Map the LDR value

    // Control the relay based on the mapped LDR value
    if (mappedLDRValue < 35) {
      digitalWrite(RELAY_PIN, HIGH);
      digitalWrite(RELAY_PIN2, HIGH); // Turn on the relay
      Serial.println("Relay turned ON");
    } else {
      digitalWrite(RELAY_PIN, LOW); 
      digitalWrite(RELAY_PIN2, LOW);// Turn off the relay
      Serial.println("Relay turned OFF");
    }

    mqttPublishFeed(mappedDistance, mappedLDRValue);
    Serial.println("Distance (cm): " + String(distance));
    Serial.println("Mapped Distance (%): " + String(mappedDistance));
    Serial.println("LDR Value: " + String(ldrValue));
    Serial.println("Mapped LDR Value (%): " + String(mappedLDRValue));
  }
}

// reconnect function
void reconnect(){
  while(!mqttClient.connected()){
    Serial.println("Trying to get connection...");
    delay(2000);

    if(mqttClient.connect(clientId, userName, passKey)){
      Serial.println("Connected..!");
      bool PubSub_Status = mqttClient.connected();
      Serial.print("mqttClient.connected after mqttClient.connect: "); Serial.println(PubSub_Status);
      Serial.print("mqttClient State: "); Serial.println(mqttClient.state());
    }
    else{
      Serial.print("failed, rc=");
      Serial.print(mqttClient.state());
      Serial.println("try again in 5 sec");
      delay(5000);
    }
  }
}

void mqttPublishFeed(int mappedDistance, int mappedLDRValue) {
  // provide data generation mechanism below
  String data = String("field1=") + String(mappedDistance) + "&field2=" + String(mappedLDRValue) + "&status=MQTTPUBLISH";
  const char *msgBuffer = data.c_str();
  Serial.println(msgBuffer);

  String topicString = "channels/" + String(channelId) + "/publish";
  const char *topicBuffer = topicString.c_str();
  Serial.println(topicBuffer);

  bool mqttpublish = mqttClient.publish(topicBuffer, msgBuffer);
  Serial.print("mqttClient.publish status: "); Serial.println(mqttpublish);
  bool PubSub_Status = mqttClient.connected();
  Serial.print("mqttClient.connected after publish: "); Serial.println(PubSub_Status);

  lastConnectionTime = millis();
}

int calculateDistance() {
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  long duration = pulseIn(ECHO_PIN, HIGH);
  int distance = duration * 0.034 / 2;
  return distance;
}
