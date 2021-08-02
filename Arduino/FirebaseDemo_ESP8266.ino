#include <ESP8266WiFi.h>
#include  <FirebaseArduino.h>

// Set these to run example.
#define FIREBASE_HOST "test-firebase-4e1b8-default-rtdb.europe-west1.firebasedatabase.app"
#define FIREBASE_AUTH "lMsCSSJBkG1pu9dngbW5partlyWdYLTV21ZYosQz"
#define WIFI_SSID "Prorider"
#define WIFI_PASSWORD "TaishaOneLove2013"

void setup() {
  Serial.begin(9600);

  // connect to wifi.
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("connecting");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
  }
  Serial.println();
  Serial.print("connected: ");
  Serial.println(WiFi.localIP());
  
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
}

int n = 0;

void loop() {
  // set value
//  Firebase.setFloat("number", 42.0);
//  // handle error
//  if (Firebase.failed()) {
//      Serial.print("setting /number failed:");
//      Serial.println(Firebase.error());  
//      return;
//  }
//  delay(1000);
//  
//  // update value
//  Firebase.setFloat("number", 43.0);
//  // handle error
//  if (Firebase.failed()) {
//      Serial.print("setting /number failed:");
//      Serial.println(Firebase.error());  
//      return;
//  }
//  delay(1000);
//
//  // get value 
//  Serial.print("number: ");
//  Serial.println(Firebase.getFloat("number"));
//  delay(1000);
//
//  // remove value
//  Firebase.remove("number");
//  delay(1000);
//
//  // set string value
//  Firebase.setString("message", "hello world");
//  // handle error
//  if (Firebase.failed()) {
//      Serial.print("setting /message failed:");
//      Serial.println(Firebase.error());  
//      return;
//  }
//  delay(1000);
//  
//  // set bool value
//  Firebase.setBool("truth", false);
//  // handle error
//  if (Firebase.failed()) {
//      Serial.print("setting /truth failed:");
//      Serial.println(Firebase.error());  
//      return;
//  }
//  delay(1000);
//
//  // append a new value to /logs
//  String name = Firebase.pushInt("logs", n++);
//  // handle error
//  if (Firebase.failed()) {
//      Serial.print("pushing /logs failed:");
//      Serial.println(Firebase.error());  
//      return;
//  }
//  Serial.print("pushed: /logs/");
//  Serial.println(name);


  float f = Firebase.getFloat("sliderValue");
  Serial.println(f * 100);
  delay(25);
}
