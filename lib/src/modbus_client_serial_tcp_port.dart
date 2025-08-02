import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:modbus_client/modbus_client.dart';

class ModbusClientSerialTcpPort extends ModbusSerialPort {
  final Socket? _socket;
  final WebSocket? _websocket;

  final BytesBuilder _buffer = BytesBuilder();
  Completer<void>? _readCompleter; // Used to signal when enough bytes are available

  late String portName;

  ModbusClientSerialTcpPort({Socket? socket, WebSocket? websocket}) : _websocket = websocket, _socket = socket{
    if (_socket != null) {
      portName = "${_socket!.address}:${_socket!.port}";
    } else if (_websocket != null) {
      portName = _websocket!.toString();
    } else {
      portName = 'Unknown';
    }
  }

  @override
  bool get isOpen => throw UnimplementedError();

  @override
  String get name => portName;

  @override
  Future<void> close()async {
    throw UnimplementedError();
  }

  @override
  Future<void> flush() async{
    _buffer.clear(); // Clear the buffer
    _readCompleter = null; // Reset the read completer
    await _socket?.flush();
  }

  @override
  Future<bool> open() async {
    _socket?.listen(
      (data) {
        _buffer.add(data);
        if (_readCompleter != null && _readCompleter!.isCompleted == false) {
          _readCompleter!.complete(); // Signal that new data arrived
        }
      },
      onDone: () {
        // Handle socket closure
      },
      onError: (e) {
        // Handle errors
      },
    );
    _websocket?.listen(
      (data) {
        _buffer.add(data);
        if (_readCompleter != null && _readCompleter!.isCompleted == false) {
          _readCompleter!.complete(); // Signal that new data arrived
        }
      },
      onDone: () {
        // Handle socket closure
      },
      onError: (e) {
        // Handle errors
      },
    );
    return true;
  }

  @override
  Future<Uint8List> read(int bytes, {Duration? timeout}) async {
    while (_buffer.length < bytes) {
      _readCompleter = Completer<void>();
      await _readCompleter!.future; // Wait for more data
    }

    final result = _buffer.takeBytes().sublist(0, bytes);
    // Re-add remaining bytes to the buffer if any
    if (_buffer.length > bytes) {
      _buffer.add(_buffer.takeBytes().sublist(bytes));
    }
    return result;
  }

  @override
  Future<int> write(Uint8List bytes, {Duration? timeout}) {
    // TODO: implement write
    throw UnimplementedError();
  }

}