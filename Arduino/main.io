#include <Arduino.h>
#include <DFRobotDFPlayerMini.h>
#include <HardwareSerial.h>
#include <Preferences.h>
#include <WiFi.h>
#include <ESPAsyncWebServer.h>
#include <AsyncTCP.h>

#define PIR_PIN 13
#define DF_RX 16
#define DF_TX 17

HardwareSerial mySerial(1);
DFRobotDFPlayerMini dfplayer;
Preferences prefs;
AsyncWebServer server(80);

bool systemOn = true;
bool panicMode = false;
bool muted = false;
int volume = 20;
bool motionDetected = false;

void playMP3(const char* file) {
  if (!muted && dfplayer.available()) {
    dfplayer.volume(volume);
    dfplayer.playMp3Folder(file);
  }
}

void IRAM_ATTR onMotionDetected() {
  motionDetected = true;
}

void setupDFPlayer() {
  mySerial.begin(9600, SERIAL_8N1, DF_RX, DF_TX);
  if (!dfplayer.begin(mySerial)) {
    Serial.println("DFPlayer Mini not found.");
    while (true);
  }
  dfplayer.volume(volume);
}

void restorePreferences() {
  prefs.begin("motionAudio", true);
  systemOn = prefs.getBool("systemOn", true);
  panicMode = prefs.getBool("panicMode", false);
  muted = prefs.getBool("muted", false);
  volume = prefs.getInt("volume", 20);
  prefs.end();
}

void savePreferences() {
  prefs.begin("motionAudio", false);
  prefs.putBool("systemOn", systemOn);
  prefs.putBool("panicMode", panicMode);
  prefs.putBool("muted", muted);
  prefs.putInt("volume", volume);
  prefs.end();
}

void setupWebServer() {
  server.on("/", HTTP_GET, [](AsyncWebServerRequest *request) {
    request->send(SPIFFS, "/index.html", "text/html");
  });

  server.serveStatic("/", SPIFFS, "/");

  server.on("/toggle", HTTP_POST, [](AsyncWebServerRequest *request){
    systemOn = !systemOn;
    savePreferences();
    request->send(200);
  });

  server.on("/panic", HTTP_POST, [](AsyncWebServerRequest *request){
    panicMode = !panicMode;
    savePreferences();
    request->send(200);
  });

  server.on("/secret", HTTP_POST, [](AsyncWebServerRequest *request){
    if (!muted) playMP3("secret.mp3");
    request->send(200);
  });

  server.on("/mute", HTTP_POST, [](AsyncWebServerRequest *request){
    muted = !muted;
    savePreferences();
    request->send(200);
  });

  server.on("/restart", HTTP_POST, [](AsyncWebServerRequest *request){
    request->send(200);
    ESP.restart();
  });

  server.on("/volume", HTTP_POST, [](AsyncWebServerRequest *request){
    if (request->hasParam("value", true)) {
      volume = request->getParam("value", true)->value().toInt();
      savePreferences();
      dfplayer.volume(volume);
    }
    request->send(200);
  });

  server.begin();
}

void setup() {
  Serial.begin(115200);
  WiFi.softAP("MotionDetector", "password");

  pinMode(PIR_PIN, INPUT);
  attachInterrupt(digitalPinToInterrupt(PIR_PIN), onMotionDetected, RISING);

  SPIFFS.begin();
  setupDFPlayer();
  restorePreferences();
  setupWebServer();
}

void loop() {
  if (motionDetected) {
    motionDetected = false;
    if (systemOn) {
      if (panicMode && !muted) {
        for (int i = 0; i < 5; i++) playMP3("panic.mp3");
      } else {
        playMP3("normal.mp3");
      }
    }
  }
}
