import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'BluetoothOffScreen.dart';
import 'FindDevicesScreen.dart';

class FlutterBlueApp extends StatelessWidget {

  const FlutterBlueApp(this._blue, {Key? key}) : super(key: key);
  final FlutterBluePlus _blue;

  @override
  Widget build(BuildContext context) => MaterialApp(
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
          stream: _blue.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return FindDevicesScreen(_blue);
            }
            return BluetoothOffScreen(state: state);
          }),
    );

}
