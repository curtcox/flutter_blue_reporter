import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class AdapterStateTile extends StatelessWidget {
  const AdapterStateTile({Key? key, required this.state}) : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.redAccent,
        child: ListTile(
          title: _bluetoothAdapterText(context),
          trailing: _errorIcon(context),
        ),
      );

  Text _bluetoothAdapterText(BuildContext context) => Text(
        'Bluetooth adapter is ${state.toString().substring(15)}',
        style: Theme.of(context).primaryTextTheme.subtitle2,
      );

  Icon _errorIcon(BuildContext context) => Icon(
        Icons.error,
        color: Theme.of(context).primaryTextTheme.subtitle2?.color,
      );
}
