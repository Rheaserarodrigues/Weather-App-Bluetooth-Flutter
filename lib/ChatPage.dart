import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({this.server});

  @override
  _ChatPage createState() => new _ChatPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ChatPage extends State<ChatPage> {
  static final clientID = 0;
  static final maxMessageLength = 4096 - 3;
  BluetoothConnection connection;

  List<_Message> messages = List<_Message>();
  String _messageBuffer = '';

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;

  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;

  List<String> _weatherData;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    messages.removeRange(0, messages.length - 1);
    final List<Row> list = messages.map((_message) {
      setState(() {
        _weatherData = _message.text.trim().split(",");
      });
    }).toList();
    // final List<Row> newList = list.removeRange(1,10);
    print(_weatherData);
    return Scaffold(
      body: SingleChildScrollView(

        // readData();
        child: Column(
          children: <Widget>[
            SafeArea(
              child: Container(
                height: 230,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    // Where the linear gradient begins and ends
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    // Add one stop for each color. Stops should increase from 0 to 1
                    stops: [0.1, 0.5, 0.7, 0.9],
                    colors: [
                      // Colors are easy thanks to Flutter's Colors class.
                      Colors.blue[900],
                      Colors.blue[800],
                      Colors.blue[700],
                      Colors.blue[500],
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(40),
                    bottomLeft: Radius.circular(40),
                  ),
                ),
                // decoration: BoxDecoration(
                //   image: DecorationImage(
                //     fit: BoxFit.cover,
                //     colorFilter: ColorFilter.mode(
                //         Colors.black.withOpacity(0.3), BlendMode.dstATop),
                //     image: AssetImage('assets/images/weather_img.jpg'),
                //   ),
                //   borderRadius: BorderRadius.only(
                //     bottomRight: Radius.circular(40),
                //     bottomLeft: Radius.circular(40),
                //   ),
                // ),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: 120,
                      top: 80,
                      width: 150,
                      height: 200,
                      child: Text(
                        'Temperature',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      top: 40,
                      width: 70,
                      height: 200,
                      child: Container(
                          child: Image(
                        image: AssetImage('assets/images/cloudy.png'),
                      )),
                    ),
                    Positioned(
                      left: 120,
                      top: 100,
                      width: 300,
                      height: 200,
                      child: Container(
                        child: Text(
                          _weatherData[0] + " \u2103" ?? '0.0 \u2103',
                          style: TextStyle(
                            fontSize: 45.0,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  height: 150,
                  width: 150,
                  child: Center(
                      child: Container(
                          child: Column(
                    children: <Widget>[
                      Image(
                        height: 80,
                        image: AssetImage('assets/images/rainy.png'),
                      ),
                      Text(_weatherData[3] + " V" ?? '0 V',
                          style: TextStyle(
                            fontSize: 25,
                          )),
                      Text('Rain')
                    ],
                  ))),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        spreadRadius: 6,
                        blurRadius: 0,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  height: 150,
                  width: 150,
                  child: Center(
                      child: Container(
                          child: Column(
                    children: <Widget>[
                      Image(
                        height: 80,
                        image: AssetImage('assets/images/humidity.png'),
                      ),
                      Text(_weatherData[1] + " %" ?? '0.0 %',
                          style: TextStyle(
                            fontSize: 25,
                          )),
                      Text('humidity')
                    ],
                  ))),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        spreadRadius: 6,
                        blurRadius: 0,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  height: 150,
                  width: 150,
                  child: Center(
                      child: Container(
                          child: Column(
                    children: <Widget>[
                      Image(
                        height: 80,
                        image: AssetImage('assets/images/gauge.png'),
                      ),
                      Text(_weatherData[6] + " Pa" ?? '0.0 Pa',
                          style: TextStyle(
                            fontSize: 25,
                          )),
                      Text('Pressure')
                    ],
                  ))),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        spreadRadius: 6,
                        blurRadius: 0,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  height: 150,
                  width: 150,
                  child: Center(
                      child: Container(
                          child: Column(
                    children: <Widget>[
                      Image(
                        height: 80,
                        image: AssetImage('assets/images/uv-protection.png'),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(_weatherData[7] + "" ?? '0.0',
                              style: TextStyle(
                                fontSize: 30,
                              )),
                          Text( "mW/cm \u00B2",
                              style: TextStyle(
                                fontSize: 15,
                              )),
                        ],
                      ),
                      Text('UV Intensity')
                    ],
                  ))),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        spreadRadius: 6,
                        blurRadius: 0,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  height: 150,
                  width: 150,
                  child: Center(
                      child: Container(
                          child: Column(
                    children: <Widget>[
                      Image(
                        height: 80,
                        image: AssetImage('assets/images/exposure.png'),
                      ),
                      Text(_weatherData[4] + " V" ?? '0 V',
                          style: TextStyle(
                            fontSize: 25,
                          )),
                      Text('Light')
                    ],
                  ))),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        spreadRadius: 6,
                        blurRadius: 0,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  height: 150,
                  width: 150,
                  child: Center(
                      child: Container(
                          child: Column(
                    children: <Widget>[
                      Image(
                        height: 80,
                        image: AssetImage('assets/images/heat.png'),
                      ),
                      Text(_weatherData[2] + " \u2103" ?? "0.0 \u2103",
                          style: TextStyle(
                            fontSize: 25,
                          )),
                      Text('Heat Index')
                    ],
                  ))),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        spreadRadius: 6,
                        blurRadius: 0,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Text(_altitude ?? 'altitude'),
            // Text(_heatindex ?? 'heatindex'),
            // Text(_humidity ?? 'humidity'),
            // Text(_lightsensor ?? 'lightsensor'),
            // Text(_rainvalue ?? 'rain'),
            // Text(_uv ?? 'UV'),
          ],
        ),
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      // \r\n
      setState(() {
        messages.add(_Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index)));
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }
}
