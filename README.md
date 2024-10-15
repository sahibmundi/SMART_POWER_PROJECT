# SMART POWER PROJECT
**About The Project**

This project demonstrates a simple and efficient home automation system using the ESP32 Dev Module. The ESP32 is programmed to control devices such as a fan and LED panel, based on inputs from an LDR sensor and an ultrasonic sensor (for water level measurement from water tank). The relay module is used to switch these devices on or off. In addition to the hardware, the system utilizes Wi-Fi connectivity to send sensor data to ThingSpeak for real-time monitoring and data analysis. This project also features a Flutter mobile application that displays status of connected devices such as the fan and LED panel.

![IMG-20240914-WA0086~4](https://github.com/user-attachments/assets/8a5ae99b-190b-4098-b106-17600e7bcd23)

![appdone](https://github.com/user-attachments/assets/3d63cf41-e5a6-42d3-971f-cac5a0637222)

**Features**

Automatic led and fan control based on ambient light levels using an LDR sensor.
Water level measurement using an ultrasonic sensor, with data available for automation triggers.
Real-time sensor data visualization on the ThingSpeak IoT platform.
Control of external devices such as fans and LEDs via relay modules.

**Tech Stack**

* Arduino IDE : For Coding ESP32 Micro-Controller.
* ThingSpeak : For cloud data storage and visualization.
* Flutter : For mobile app UI and real time visualization.

**Circuit Diagram**

![Circuit Diagram](https://github.com/user-attachments/assets/c3382b42-26e0-45c2-9836-cf9a9cdbbd9f)

**Working**

* LDR Sensor → ESP32: Represents the light level input.
* Ultrasonic → ESP32: Measure the water level.
* ESP32 → Relay Module: Controls the relays based on light conditions.
* Relay Module → Fan/LED: Turns on or off based on the relay signal.
* ESP32 → ThingSpeak: Sends data to the cloud.
* ThingSpeak → Flutter App: Displays data.










