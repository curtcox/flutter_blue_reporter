import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'DescriptorTile.dart';

class CharacteristicTile extends StatelessWidget {

  final BluetoothCharacteristic characteristic;
  final List<DescriptorTile> descriptorTiles;
  final VoidCallback? onReadPressed;
  final VoidCallback? onWritePressed;
  final VoidCallback? onNotificationPressed;

  const CharacteristicTile(
      {Key? key,
        required this.characteristic,
        required this.descriptorTiles,
        this.onReadPressed,
        this.onWritePressed,
        this.onNotificationPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<int>>(
      stream: characteristic.value,
      initialData: characteristic.lastValue,
      builder: (c, snapshot) {
        final value = snapshot.data;
        return ExpansionTile(
          title: ListTile(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Characteristic'),_uuid(context)
              ],
            ),
            subtitle: Text(value.toString()),
            contentPadding: const EdgeInsets.all(0.0),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _downloadButton(context),
              _uploadButton(context),
              _syncButton(context)
            ],
          ),
          children: descriptorTiles,
        );
      },
    );
  }

  Text _uuid(BuildContext context) => Text(
      '0x${characteristic.uuid.toString().toUpperCase().substring(4, 8)}',
      style: Theme.of(context).textTheme.bodyText1?.copyWith(
          color: Theme.of(context).textTheme.caption?.color));

  Color? _color(BuildContext context) => Theme.of(context).iconTheme.color?.withOpacity(0.5);

  IconButton _syncButton(BuildContext context) => IconButton(
    icon: Icon(
        characteristic.isNotifying
            ? Icons.sync_disabled
            : Icons.sync,
        color: _color(context)),
    onPressed: onNotificationPressed,
  );

  IconButton _uploadButton(BuildContext context) => IconButton(
    icon: Icon(Icons.file_upload, color: _color(context)),
    onPressed: onWritePressed,
  );

  IconButton _downloadButton(BuildContext context) => IconButton(
    icon: Icon(Icons.file_download, color: _color(context)),
    onPressed: onReadPressed,
  );
}
