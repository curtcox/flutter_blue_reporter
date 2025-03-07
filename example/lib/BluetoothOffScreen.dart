import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothOffScreen extends StatelessWidget {

  const BluetoothOffScreen({Key? key, this.state}) : super(key: key);

  final BluetoothState? state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            _bluetoothAdapterText(context),
            _turnOnButton(),
          ],
        ),
      ),
    );
  }

  ElevatedButton _turnOnButton() => ElevatedButton(
    child: const Text('TURN ON'),
    onPressed: Platform.isAndroid
        ? () => FlutterBluePlus.instance.turnOn()
        : null,
  );

  Text _bluetoothAdapterText(BuildContext context) => Text(
    'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
    style: Theme.of(context)
        .primaryTextTheme
        .subtitle2
        ?.copyWith(color: Colors.white),
  );

}
