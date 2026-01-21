# Twiny 🕷️📱
### The Mobile Command & Control (C2) Interface for ESP32 Evil Twin

**Twiny** is a robust Flutter application designed to interface wirelessly with an ESP32-based Evil Twin device. Unlike traditional web-based control panels, Twiny utilizes **Bluetooth Low Energy (BLE)** to maintain a stealthy, out-of-band communication channel with the hardware, allowing for remote attack management and real-time credential monitoring without connecting to the Wi-Fi network itself.

> ⚠️ **DISCLAIMER: EDUCATIONAL USE ONLY**
> This project is created for educational purposes and cybersecurity research. It is designed to demonstrate vulnerabilities in Wi-Fi networks (specifically Open/Captive Portal networks) and the importance of HTTPS/HSTS.
> **Do not use this software against networks or devices you do not own or have explicit permission to test.**

---

## 🚀 Key Features

* **🕵️ Stealthy C2 Communication:** Uses BLE (Bluetooth Low Energy) for all communication, keeping the Wi-Fi radio free for the attack and leaving no web-server footprint on the network.
* **📡 Device Discovery:** Automated scanning and filtering to instantly locate and connect to the specific ESP32 unit ("ESP32_Control").
* **⚡ Remote Trigger:** One-tap execution to Start/Stop the "Evil Twin" Access Point and DNS Spoofer.
* **🔓 Real-Time Captures:** Listens for BLE notifications to display captured credentials ("username:password") instantly as they are intercepted by the ESP32.
* **📱 Cross-Platform:** Built with Flutter to run natively on Android (and iOS).

---

## 🛠️ Tech Stack

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **Communication:** Bluetooth Low Energy (BLE)
* **Key Libraries:**
    * `flutter_blue_plus` (BLE Management)
    * `permission_handler` (Android Runtime Permissions)
* **Hardware Target:** ESP32 Development Board (running C++ firmware)

---

## 📸 Screenshots

| Device Scan | Attack Dashboard | Live Logs |
|:---:|:---:|:---:|
| *(Add screenshot of your Scan Screen)* | *(Add screenshot of Control Screen)* | *(Add screenshot of Log Screen)* |

---

## ⚙️ How It Works

Twiny operates as the "Frontend" for a hardware-based Man-in-the-Middle (MITM) setup:

1.  **Connection:** The app scans for the ESP32 advertising the custom Service UUID.
2.  **Command Injection:** When the "START" button is pressed, the app writes a command to the ESP32's **Command Characteristic**.
3.  **Hardware Execution:** The ESP32 receives the command, spins up the Rogue Access Point (Evil Twin), and enables the Captive Portal.
4.  **Data Exfiltration:** When a victim enters credentials into the fake portal, the ESP32 pushes this data to the app via a **Notify Characteristic**.
5.  **Visualization:** Twiny parses the incoming bytes and displays the captured data in a scrolling log.

---

## 📥 Installation & Setup

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
* An Android device (Physical device required for Bluetooth testing).
* ESP32 flashed with the corresponding Evil Twin Firmware.

### Steps
1.  **Clone the Repo**
    ```bash
    git clone [https://github.com/yourusername/Twiny.git](https://github.com/yourusername/Twiny.git)
    cd Twiny
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Run on Device**
    Connect your phone via USB and enable USB Debugging.
    ```bash
    flutter run
    ```

---

## 📱 Permissions (Android)

To access Bluetooth hardware, this app requires the following permissions (handled automatically in-app):
* `BLUETOOTH_SCAN`
* `BLUETOOTH_CONNECT`
* `ACCESS_FINE_LOCATION` (Required for BLE discovery on Android 11 and below)

---

## 🔮 Future Roadmap

* [ ] **MAC Filtering:** Add UI to target specific MAC addresses for Deauth attacks.
* [ ] **Portal Selector:** Ability to upload different HTML templates (Google, Facebook, Starbucks) from the phone to the ESP32.
* [ ] **Data Export:** Save captured logs to a CSV file.

---

**Author:** [Your Name]
**License:** MIT
