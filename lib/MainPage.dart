import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:lottie/lottie.dart';
import './DiscoveryPage.dart';
import './SelectBondedDevicePage.dart';
import './ChatPage.dart';
import './BackgroundCollectingTask.dart';
import './BackgroundCollectedPage.dart';

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
            // Divider(),
            // SwitchListTile(
            //   title: const Text('Enable Bluetooth'),
            //   value: _bluetoothState.isEnabled,
            //   onChanged: (bool value) {
            //     // Do the request and update with the true value then
            //     future() async {
            //       // async lambda seems to not working
            //       if (value)
            //         await FlutterBluetoothSerial.instance.requestEnable();
            //       else
            //         await FlutterBluetoothSerial.instance.requestDisable();
            //     }
            //
            //     future().then((_) {
            //       setState(() {});
            //     });
            //   },
            // ),
            // ListTile(
            //   title: const Text('Bluetooth status'),
            //   subtitle: Text(_bluetoothState.toString()),
            //   trailing: RaisedButton(
            //     child: const Text('Settings'),
            //     onPressed: () {
            //       FlutterBluetoothSerial.instance.openSettings();
            //     },
            //   ),
            // ),
            // ListTile(
            //   title: const Text('Local adapter address'),
            //   subtitle: Text(_address),
            // ),
            // ListTile(
            //   title: const Text('Local adapter name'),
            //   subtitle: Text(_name),
            //   onLongPress: null,
            // ),
            // ListTile(
            //     title: _discoverableTimeoutSecondsLeft == 0
            //         ? const Text("Discoverable")
            //         : Text(
            //             "Discoverable for ${_discoverableTimeoutSecondsLeft}s"),
            //     subtitle: const Text("PsychoX-Luna"),
            //     trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            //       Checkbox(
            //         value: _discoverableTimeoutSecondsLeft != 0,
            //         onChanged: null,
            //       ),
            //       IconButton(
            //         icon: const Icon(Icons.edit),
            //         onPressed: null,
            //       ),
            //       IconButton(
            //         icon: const Icon(Icons.refresh),
            //         onPressed: () async {
            //           print('Discoverable requested');
            //           final int timeout = await FlutterBluetoothSerial.instance
            //               .requestDiscoverable(60);
            //           if (timeout < 0) {
            //             print('Discoverable mode denied');
            //           } else {
            //             print(
            //                 'Discoverable mode acquired for $timeout seconds');
            //           }
            //           setState(() {
            //             _discoverableTimeoutTimer?.cancel();
            //             _discoverableTimeoutSecondsLeft = timeout;
            //             _discoverableTimeoutTimer =
            //                 Timer.periodic(Duration(seconds: 1), (Timer timer) {
            //               setState(() {
            //                 if (_discoverableTimeoutSecondsLeft < 0) {
            //                   FlutterBluetoothSerial.instance.isDiscoverable
            //                       .then((isDiscoverable) {
            //                     if (isDiscoverable) {
            //                       print(
            //                           "Discoverable after timeout... might be infinity timeout :F");
            //                       _discoverableTimeoutSecondsLeft += 1;
            //                     }
            //                   });
            //                   timer.cancel();
            //                   _discoverableTimeoutSecondsLeft = 0;
            //                 } else {
            //                   _discoverableTimeoutSecondsLeft -= 1;
            //                 }
            //               });
            //             });
            //           });
            //         },
            //       )
            //     ])),
            // Divider(),
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
      return ChatPage(server: server);
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
