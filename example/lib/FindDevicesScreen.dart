import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'DeviceScreen.dart';
import 'ScanResultTile.dart';

class FindDevicesScreen extends StatelessWidget {
  const FindDevicesScreen(this._blue, {Key? key}) : super(key: key);
  final FlutterBluePlus _blue;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: _appBar(),
      body: _body(context),
      floatingActionButton: _searchOrStopButton());

  StreamBuilder<bool> _searchOrStopButton() => StreamBuilder<bool>(
        stream: _isScanning(),
        initialData: false,
        builder: (c, snapshot) =>
            (snapshot.data!) ? _stopButton() : _searchButton(),
      );

  RefreshIndicator _body(BuildContext context) => RefreshIndicator(
        onRefresh: () => _onRefresh(),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _bluetoothDeviceList(context),
              _scanResultList(context)
            ],
          ),
        ),
      );

  AppBar _appBar() => AppBar(
        title: const Text('Find Devices'),
        actions: [_turnOffButton()],
      );

  StreamBuilder<List<ScanResult>> _scanResultList(BuildContext context) =>
      StreamBuilder<List<ScanResult>>(
        stream: _scanResults(),
        initialData: const [],
        builder: (c, snapshot) => Column(
          children:
              snapshot.data!.map((r) => _scanResultTile(context, r)).toList(),
        ),
      );

  ScanResultTile _scanResultTile(BuildContext context, ScanResult r) =>
      ScanResultTile(result: r, onTap: () => _onScanResultTap(context, r));

  ListTile _deviceTile(BuildContext context, BluetoothDevice d) => ListTile(
        title: Text(d.name),
        subtitle: Text(d.id.toString()),
        trailing: StreamBuilder<BluetoothDeviceState>(
          stream: d.state,
          initialData: BluetoothDeviceState.disconnected,
          builder: (c, snapshot) {
            if (snapshot.data == BluetoothDeviceState.connected) {
              return _openButton(context, d);
            }
            return Text(snapshot.data.toString());
          },
        ),
      );

  StreamBuilder<List<BluetoothDevice>> _bluetoothDeviceList(
          BuildContext context) =>
      StreamBuilder<List<BluetoothDevice>>(
        stream: Stream.periodic(const Duration(seconds: 2))
            .asyncMap((_) => _connectedDevices()),
        initialData: const [],
        builder: (c, snapshot) => Column(
          children: snapshot.data!.map((d) => _deviceTile(context, d)).toList(),
        ),
      );

  ElevatedButton _openButton(BuildContext context, BluetoothDevice device) =>
      ElevatedButton(
          child: const Text('OPEN'),
          onPressed: () => _onOpenButtonPressed(context, device));

  FloatingActionButton _stopButton() => FloatingActionButton(
        child: const Icon(Icons.stop),
        onPressed: () => _stopScan(),
        backgroundColor: Colors.red,
      );

  FloatingActionButton _searchButton() => FloatingActionButton(
      child: const Icon(Icons.search), onPressed: () => _startScan());

  ElevatedButton _turnOffButton() => ElevatedButton(
        child: const Text('TURN OFF'),
        style: ElevatedButton.styleFrom(
          primary: Colors.black,
          onPrimary: Colors.white,
        ),
        onPressed: Platform.isAndroid ? () => _turnOff() : null,
      );

  _onOpenButtonPressed(BuildContext context, BluetoothDevice device) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => DeviceScreen(device: device)));
  }

  _onScanResultTap(BuildContext context, ScanResult r) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      r.device.connect();
      return DeviceScreen(device: r.device);
    }));
  }

  _onRefresh() => _startScan();

  Stream<bool> _isScanning() => _blue.isScanning;
  Stream<List<ScanResult>> _scanResults() => _blue.scanResults;
  Future<List<BluetoothDevice>> _connectedDevices() => _blue.connectedDevices;
  _stopScan() => _blue.stopScan();
  _turnOff() => _blue.turnOff();
  _startScan() => _blue.startScan(timeout: const Duration(seconds: 4));
}
