import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:lottie/lottie.dart';
import './DiscoveryPage.dart';
import './SelectBondedDevicePage.dart';
import './WeatherDisplayWidget.dart';
import './BackgroundCollectingTask.dart';


//import './LineChart.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPage createState() => new _MainPage();
}

class _MainPage extends State<MainPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  Timer _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;

  BackgroundCollectingTask _collectingTask;

  bool _autoAcceptPairingRequests = false;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if (await FlutterBluetoothSerial.instance.isEnabled) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _collectingTask?.dispose();
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
      ),
      body: Container(
        child: ListView(
          children: <Widget>[

            GestureDetector(
              onTap: () async {
                final BluetoothDevice selectedDevice =
                    await Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                  return DiscoveryPage();
                }));

                if (selectedDevice != null) {
                  print('Discovery -> selected ' + selectedDevice.address);
                } else {
                  print('Discovery -> no device selected');
                }
              },
              child: Container(
                margin: EdgeInsets.all(50.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.white30, spreadRadius: 3),
                  ],
                ),
                child: Column(

                  children: [

                    Lottie.asset(
                      'assets/lottie/bluetooth.json',
                      width: 200,
                      height: 200,
                      fit: BoxFit.fill,
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Text("Scan Devices",
                          style: Theme.of(context).textTheme.headline2),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                final BluetoothDevice selectedDevice =
                await Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return SelectBondedDevicePage(checkAvailability: false);
                }));

                if (selectedDevice != null) {
                  print('Connect -> selected ' + selectedDevice.address);
                  _startChat(context, selectedDevice);
                } else {
                  print('Connect -> no device selected');
                }
              },
              child: Container(
                margin: EdgeInsets.all(50.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.white30, spreadRadius: 3),
                  ],
                ),
                child: Column(

                  children: [

                    Lottie.asset(
                      'assets/lottie/weather.json',
                      width: 200,
                      height: 200,
                      fit: BoxFit.fill,
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Text("Connect To Weather Device",
                          style: Theme.of(context).textTheme.headline2),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  void _startChat(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return WeatherDisplayWidget(server: server);
    }));
  }

  Future<void> _startBackgroundTask(
      BuildContext context, BluetoothDevice server) async {
    try {
      _collectingTask = await BackgroundCollectingTask.connect(server);
      await _collectingTask.start();
    } catch (ex) {
      if (_collectingTask != null) {
        _collectingTask.cancel();
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error occured while connecting'),
            content: Text("${ex.toString()}"),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
