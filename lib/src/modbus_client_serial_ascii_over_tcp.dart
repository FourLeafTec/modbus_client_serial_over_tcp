import 'package:modbus_client/modbus_client.dart';

import '../modbus_client_serial_over_tcp.dart';

class ModbusClientSerialAsciiOverTcp extends ModbusClientSerialAsciiBase {
  ModbusClientSerialAsciiOverTcp(
      {ModbusTcpProtocal protocal = ModbusTcpProtocal.tcp,
      String host = "localhost",
      int port = 502,
      String path = "",
      super.unitId,
      super.connectionMode = ModbusConnectionMode.autoConnectAndKeepConnected,
      super.responseTimeout = const Duration(seconds: 3),
      super.flushOnRequest = true})
      : super(
            serialPort: ModbusClientSerialTcpPort(
                protocal: protocal, host: host, port: port, path: path));
}
