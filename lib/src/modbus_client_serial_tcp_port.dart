import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:modbus_client/modbus_client.dart';

enum ModbusTcpProtocal { tcp, websocket }

class ModbusClientSerialTcpPort extends ModbusSerialPort {
  final ModbusTcpProtocal protocal;
  final String host;
  final int port;
  final String? path;

  Socket? _socket;
  WebSocket? _websocket;

  final BytesBuilder _buffer = BytesBuilder();
  Completer<void>?
      _readCompleter; // Used to signal when enough bytes are available

  late String portName;
  bool _isOpen = false;

  ModbusClientSerialTcpPort(
      {required this.protocal,
      required this.host,
      required this.port,
      this.path}) {
    if (protocal == ModbusTcpProtocal.tcp) {
      portName = "$protocal://$host:$port";
    } else if (protocal == ModbusTcpProtocal.tcp) {
      portName = "$protocal://$host:$port/$path";
    } else {
      throw ArgumentError(
          'Unsupported protocol: $protocal. Use ModbusTcpProtocal.tcp or ModbusTcpProtocal.websocket.');
    }
  }

  @override
  bool get isOpen => _isOpen;

  @override
  String get name => portName;

  @override
  Future<void> close() async {
    _isOpen = false;
    await flush();
    if (protocal == ModbusTcpProtocal.tcp) {
      await _socket?.close();
    } else if (protocal == ModbusTcpProtocal.websocket) {
      await _websocket?.close();
    } else {
      throw ArgumentError(
          'Unsupported protocol: $protocal. Use ModbusTcpProtocal.tcp or ModbusTcpProtocal.websocket.');
    }
  }

  @override
  Future<void> flush() async {
    _buffer.clear(); // Clear the buffer
    _readCompleter = null; // Reset the read completer
    await _socket?.flush();
  }

  void onWebsocketData(dynamic data) {
    onData(data);
  }

  void onData(Uint8List data) {
    _buffer.add(data);
    if (_readCompleter != null && _readCompleter!.isCompleted == false) {
      _readCompleter!.complete(); // Signal that new data arrived
    }
  }

  void onDone() async {
    await close();
    _readCompleter?.complete(); // Complete any pending read completer
    _readCompleter = null; // Reset the read completer
    _buffer.clear(); // Clear the buffer
  }

  void onError(e) async {
    await close();
  }

  @override
  Future<bool> open() async {
    if (protocal == ModbusTcpProtocal.tcp) {
      _socket = await Socket.connect(host, port);
      _socket?.listen(
        onData,
        onDone: onDone,
        onError: onError,
      );
    } else if (protocal == ModbusTcpProtocal.websocket) {
      _websocket = await WebSocket.connect(
        'ws://$host:$port/$path',
      );
      _websocket?.listen(
        onWebsocketData,
        onDone: onDone,
        onError: onError,
      );
    } else {
      throw ArgumentError(
          'Unsupported protocol: $protocal. Use ModbusTcpProtocal.tcp or ModbusTcpProtocal.websocket.');
    }
    _isOpen = true;
    return true;
  }

  @override
  Future<Uint8List> read(int bytes, {Duration? timeout}) async {
    while (_buffer.length < bytes) {
      _readCompleter = Completer<void>();
      await _readCompleter!.future; // Wait for more data
    }
    final datas = _buffer.takeBytes();
    final result = datas.sublist(0, bytes);
    // Re-add remaining bytes to the buffer if any
    if (datas.length > bytes) {
      _buffer.add(datas.sublist(bytes));
    }
    return result;
  }

  @override
  Future<int> write(Uint8List bytes, {Duration? timeout}) async {
    void send() {
      _socket?.add(bytes);
      _websocket?.add(bytes);
    }

    Future<void> sendFuture = Future(send);

    if (timeout != null) {
      try {
        await sendFuture.timeout(timeout, onTimeout: () {
          throw Exception(
              'Write operation timed out after ${timeout.inMilliseconds} ms');
        });
      } catch (e) {
        ModbusAppLogger.warning(e.toString());
        return 0;
      }
      return bytes.length;
    } else {
      await sendFuture;
    }
    return bytes.length;
  }
}
