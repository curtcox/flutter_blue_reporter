import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'CharacteristicTile.dart';
import 'DescriptorTile.dart';
import 'ServiceTile.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  List<int> _getRandomBytes() {
    final math = Random();
    return [
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255)
    ];
  }

  List<Widget> _buildServiceTiles(List<BluetoothService> services) =>
      services.map((s) => _serviceTile(s)).toList();

  ServiceTile _serviceTile(BluetoothService s) => ServiceTile(
        service: s,
        characteristicTiles:
            s.characteristics.map((c) => _characteristicTile(c)).toList(),
      );

  CharacteristicTile _characteristicTile(BluetoothCharacteristic c) =>
      CharacteristicTile(
        characteristic: c,
        onReadPressed: () => c.read(),
        onWritePressed: () async {
          await c.write(_getRandomBytes(), withoutResponse: true);
          await c.read();
        },
        onNotificationPressed: () async {
          await c.setNotifyValue(!c.isNotifying);
          await c.read();
        },
        descriptorTiles: c.descriptors.map((d) => _descriptorTile(d)).toList(),
      );

  DescriptorTile _descriptorTile(BluetoothDescriptor d) => DescriptorTile(
        descriptor: d,
        onReadPressed: () => d.read(),
        onWritePressed: () => d.write(_getRandomBytes()),
      );

  String _text(BluetoothDeviceState? data) {
    switch (data) {
      case BluetoothDeviceState.connected:
        return 'DISCONNECT';
      case BluetoothDeviceState.disconnected:
        return 'CONNECT';
      default:
        return data.toString().substring(21).toUpperCase();
    }
  }

  VoidCallback? _onPressed(BluetoothDeviceState? data) {
    switch (data) {
      case BluetoothDeviceState.connected:
        return () => device.disconnect();
      case BluetoothDeviceState.disconnected:
        return () => device.connect();
      default:
        return null;
    }
  }

  TextButton _snapshotButton(
          BuildContext context, AsyncSnapshot<BluetoothDeviceState> snapshot) =>
      TextButton(
          onPressed: _onPressed(snapshot.data),
          child: Text(
            _text(snapshot.data),
            style: Theme.of(context)
                .primaryTextTheme
                .button
                ?.copyWith(color: Colors.white),
          ));

  StreamBuilder _actions(BuildContext context) =>
      StreamBuilder<BluetoothDeviceState>(
        stream: device.state,
        initialData: BluetoothDeviceState.connecting,
        builder: (c, snapshot) {
          return _snapshotButton(context, snapshot);
        },
      );

  Icon _deviceStateIcon(BluetoothDeviceState? data) =>
      data == BluetoothDeviceState.connected
          ? const Icon(Icons.bluetooth_connected)
          : const Icon(Icons.bluetooth_disabled);

  Text _rssiText(BuildContext context, AsyncSnapshot<int> snapshot) =>
      Text(snapshot.hasData ? '${snapshot.data}dBm' : '',
          style: Theme.of(context).textTheme.caption);

  StreamBuilder _rssiTextStream() => StreamBuilder<int>(
      stream: rssiStream(),
      builder: (context, snapshot) {
        return _rssiText(context, snapshot);
      });

  Column _child(BuildContext context) => Column(
        children: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (c, snapshot) => ListTile(
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _deviceStateIcon(snapshot.data),
                  snapshot.data == BluetoothDeviceState.connected
                      ? _rssiTextStream()
                      : Text('', style: Theme.of(context).textTheme.caption),
                ],
              ),
              title:
                  Text('Device is ${snapshot.data.toString().split('.')[1]}.'),
              subtitle: Text('${device.id}'),
              trailing: StreamBuilder<bool>(
                stream: device.isDiscoveringServices,
                initialData: false,
                builder: (c, snapshot) => IndexedStack(
                  index: snapshot.data! ? 1 : 0,
                  children: <Widget>[_refreshButton(), _progressButton()],
                ),
              ),
            ),
          ),
          StreamBuilder<int>(
              stream: device.mtu,
              initialData: 0,
              builder: (c, snapshot) => _mtuSizeTile(snapshot)),
          StreamBuilder<List<BluetoothService>>(
            stream: device.services,
            initialData: const [],
            builder: (c, snapshot) {
              return Column(
                children: _buildServiceTiles(snapshot.data!),
              );
            },
          ),
        ],
      );

  IconButton _progressButton() => const IconButton(
        icon: SizedBox(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.grey),
          ),
          width: 18.0,
          height: 18.0,
        ),
        onPressed: null,
      );

  IconButton _refreshButton() => IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: () => device.discoverServices(),
      );

  ListTile _mtuSizeTile(AsyncSnapshot<int> snapshot) => ListTile(
        title: const Text('MTU Size'),
        subtitle: Text('${snapshot.data} bytes'),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => device.requestMtu(223),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(device.name),
          actions: <Widget>[_actions(context)],
        ),
        body: SingleChildScrollView(child: _child(context)),
      );

  Stream<int> rssiStream() async* {
    var isConnected = true;
    final subscription = device.state.listen((state) {
      isConnected = state == BluetoothDeviceState.connected;
    });
    while (isConnected) {
      yield await device.readRssi();
      await Future.delayed(Duration(seconds: 1));
    }
    subscription.cancel();
    // Device disconnected, stopping RSSI stream
  }
}
