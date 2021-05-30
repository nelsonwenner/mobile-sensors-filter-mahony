import 'dart:async';
import 'dart:io';

import 'package:web_socket_channel/io.dart';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import '../../services/MahonyAHRS.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState(); 
}

class _HomeViewState extends State<HomeView> {

  // event returned from accelerometer stream
  AccelerometerEvent _eventAccel;

  // event returned from gyroscope stream
  GyroscopeEvent _eventGyro;

  // hold a refernce to these, so that they can be disposed
  StreamSubscription _accelStream;
  StreamSubscription _gyroStream;
  Timer _timer;

  // execution time for each cycle per milliseconds, 20.000 mHz
  int _lsmTime = 20;

  // Socket
  IOWebSocketChannel _socket;
  bool _socketIsConnected;
  String _status;

  // Filter
  MahonyAHRS _algorithm;

  // Text
  TextEditingController _ipEditingController;
  TextEditingController _portEditingController;

  bool sensorIsActived = false;

  @override
  void initState() {
    _algorithm = MahonyAHRS();
    _ipEditingController = TextEditingController();
    _portEditingController = TextEditingController();
    _socketIsConnected = false;
    _status = '';
    super.initState();
  }

  Future<void> _connectSocketChannel() async {
    if (_ipEditingController.text.isEmpty ||
      _portEditingController.text.isEmpty) {
      return;
    }
    var URL = 'ws://${ _ipEditingController.text }:${ _portEditingController.text }';

    WebSocket.connect(URL).then((ws) => {
      _socket = IOWebSocketChannel(ws),
      connectionListener(true)
    }).catchError((err) => { connectionListener(false) });
  }

  void sendMessage(message) {
    try {
      _socket.sink.add('${ message }');
    } catch (e) {
      setState(() {
        _status = 'Status: Connection problems, try to connect again';
        _socketIsConnected = false;
      });
    }
  }

  void connectionListener(bool connected) {
    setState(() {
      _status = 'Status : ' + (connected ? 'Connected' : 'Failed to connect');
      _socketIsConnected = connected;
    });
  }

  void setPosition(
    AccelerometerEvent currentAccel, 
    GyroscopeEvent currentGyro
  ) {
    if (currentAccel == null && currentGyro == null) { return; }

    _algorithm.update(
      currentAccel.x, 
      currentAccel.y, 
      currentAccel.z,  
      currentGyro.x,  
      currentGyro.y, 
      currentGyro.z, 
    );

    if (_socketIsConnected) {
      sendMessage('${ [
        _algorithm.Quaternion[0],
        _algorithm.Quaternion[1],
        _algorithm.Quaternion[2],
        _algorithm.Quaternion[3]
      ] }');
    }
  }

  void startTimer() {
    // if the accelerometer subscription hasn't been created, go ahead and create it
    if (_accelStream == null && _gyroStream == null) {
      _accelStream = accelerometerEvents.listen((AccelerometerEvent event) {
        setState(() {
          _eventAccel = event;
        });
      });
      _gyroStream = gyroscopeEvents.listen((GyroscopeEvent event) {
        setState(() {
          _eventGyro = event;
        });
      });
    } else {
      // it has already ben created so just resume it
      _accelStream.resume();
      _gyroStream.resume();
    }

    // Accelerometer events come faster than we need them so a timer
    // is used to only proccess them every 20 milliseconds
    if (_timer == null || !_timer.isActive) {
      _timer = Timer.periodic(Duration(milliseconds: _lsmTime), (_) { 
        // (20*500) = 1000 milliseconds, equals 1 seconds.
        // proccess the current event
        setPosition(_eventAccel, _eventGyro);
      });
    }
  }

  void pauseTimer() {
    // stop the timer and pause the accelerometer and gyro stream
    _timer.cancel();
    _accelStream.pause();
    _gyroStream.pause();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _accelStream?.cancel();
    _gyroStream?.cancel();
    _socket.sink?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensor Example'),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Padding(padding: EdgeInsets.only(bottom: 40.0)),
            customTextField(
              _ipEditingController, 
              'IP Server Exemple: 192.168.0.1'
            ),
            Padding(padding: EdgeInsets.only(bottom: 5.0)),
            customTextField(
              _portEditingController, 
              'PORT Server Exemple: 8080'
            ),
            Padding(padding: EdgeInsets.only(bottom: 20.0)),
            OutlineButton(
              child: Text(!_socketIsConnected ? 'Connect Server': 'Disconnect Server'),
              onPressed: () {
                if (!_socketIsConnected) {
                  _connectSocketChannel();
                } else {
                  setState(() {
                    _socketIsConnected = false;
                    _socket.sink?.close();
                    _status = '';
                  });
                }
              }
            ),
            Padding(padding: EdgeInsets.only(bottom: 20.0)),
            Text(_status),
            Padding(padding: EdgeInsets.only(bottom: 20.0)),
            Text('Quaternion X: ${ _algorithm.Quaternion[1].toStringAsFixed(3) }'),
            Text('Quaternion Y: ${ _algorithm.Quaternion[2].toStringAsFixed(3) }'),
            Text('Quaternion Z: ${ _algorithm.Quaternion[3].toStringAsFixed(3) }'),
            Text('Quaternion W: ${ _algorithm.Quaternion[0].toStringAsFixed(3) }'),
            Padding(padding: EdgeInsets.only(bottom: 10.0)),
            OutlineButton(
              child: Text(!sensorIsActived ? 'Start' : 'Stop'),
              onPressed: () {
                if (!sensorIsActived) {
                  startTimer();
                  setState(() {
                    sensorIsActived = true;
                  });
                } else {
                  pauseTimer();
                  _algorithm.resetValues();
                  setState(() {
                    sensorIsActived = false;
                  });
                }
              },
            )
          ],
        ),
      ),
    );
  }

  TextField customTextField(
    TextEditingController controller, 
    String text) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(6.0)
          )
        ),
        filled: true,
        fillColor: Colors.white60,
        contentPadding: EdgeInsets.all(15.0),
        hintText: text
      ),
    );
  }
}
