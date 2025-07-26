# ESP32 Motion Audio Alert System

A motion-triggered audio playback system using ESP32, PIR sensor, and DFPlayer Mini. Clean Web UI lets you control system state, panic loop, volume, mute, and secret MP3 triggers.

## 💡 Features
- Motion-activated MP3 playback
- Panic mode (loops panic.mp3)
- Volume control slider
- Mute/Unmute
- Web-based controls
- Preferences saved across reboots

## 🔌 Hardware

- ESP32 Dev Board
- DFPlayer Mini
- PIR Motion Sensor (e.g., HC-SR501)
- Speaker (wired to DFPlayer SPK_1 / SPK_2)
- microSD card (FAT32) with:
  - `normal.mp3`
  - `panic.mp3`
  - `secret.mp3`

## 🔌 Wiring (see CSV)

| Component      | ESP32 Pin |
|----------------|-----------|
| PIR Sensor     | GPIO 13   |
| DFPlayer RX    | GPIO 16   |
| DFPlayer TX    | GPIO 17   |
| DFPlayer VCC   | 5V        |
| DFPlayer GND   | GND       |
| Speaker        | SPK_1/2   |

CSV: [esp32_audio_motion_pinout.csv](esp32_audio_motion_pinout.csv)

## 🌐 Usage

1. Format SD card (FAT32) and add your MP3s
2. Upload `main.ino` with Arduino IDE
3. Upload `data/` files to SPIFFS with ESP32 Data Upload tool
4. Power device via micro-USB or USB power bank
5. Connect to Wi-Fi: `MotionDetector` / `password`
6. Open browser at `192.168.4.1`

## ⚙️ Optional Build Tips

- Use hot glue to secure wires
- Enclose in a small plastic case or 3D print one
- Add an external power button or switch
- Use rechargeable USB power bank for portable deployment

## 🧪 Libraries Required

- DFRobotDFPlayerMini
- ESPAsyncWebServer
- AsyncTCP
- Preferences

## 🪪 License

MIT — Modify, remix, and stay alert.
