<h1 align="center">
  IMPLEMENTATION OF MAHONY ORIENTATION FILTER IN ACCELEROMETER AND GYROSCOPE SENSORS
</h1>

## :bulb: About
This project is an application that uses data from its sensors such as accelerometer and gyroscope to be used in some type of manipulation involving games, among others. In this example, I transmit this data from the sensors via WebSocket and manipulate a 3D object.

## :rocket: Technologies

* [Flutter](https://flutter.dev/)
* [Godot](https://godotengine.org/)

## :electric_plug: Prerequisites
  
- [Flutter (>= 2.0.x)](https://flutter.dev/docs/get-started/install)
- [Godot (>= 3.x)](https://godotengine.org/download/)

## :information_source: Getting Started

1. Fork this repository and clone it on your machine.
2. Change the directory to `mobile-sensors-filter-mahony` where you cloned it.

## :joystick: Godot Getting Started 
- Start Godot, with this you will run the WebSocket server and the 3D object that will be moved with the device's sensor data.

## :iphone: Flutter Getting Started 
- With the device connected via a USB cable, execute the commands below.

1. Install dependencies
```shell
$ flutter pub get
``` 

2. Start the application
```shell
$ flutter run
```
* With the application installed on your device, first make a connection to the WebSocket server from Godot, your device must be connected via wi-fi on your network, as it is a local network communication. The IP of the server is the same as that of your machine, below I will leave a command to check your IP, the port is fixed at 8080. With this information, connect to the server and start capturing the data from the sensors and transmitting them over the network .
  
3. Check IP
```shell
/* windows */
$ ipconfig
```
```shell
/* linux */
$ ifconfig
```
---
Made with :hearts: by Nelson Wenner :wave: [Get in touch!](https://www.linkedin.com/in/nelsonwenner/)