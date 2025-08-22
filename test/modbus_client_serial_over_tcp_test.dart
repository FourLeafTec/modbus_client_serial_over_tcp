import 'package:modbus_client/modbus_client.dart';
import 'package:modbus_client_serial_over_tcp/modbus_client_serial_over_tcp.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    setUp(() async {
      // Additional setup goes here.
    });

    test('Test rtu over TCP', () async {
      // ModbusClientSerialRtuOverTcp rtuClient;
      // rtuClient = ModbusClientSerialRtuOverTcp(
      //     protocal: ModbusTcpProtocal.tcp,
      //     host: '192.168.1.9',
      //     port: 6000,
      //     unitId: 1);

      // final el = ModbusInt16Register(
      //   name: 'test02',
      //   address: 2,
      //   type: ModbusElementType.holdingRegister,
      //   endianness: ModbusEndianness.CDAB,
      // );
      // var req = el.getReadRequest();
      // var res = await rtuClient.send(req);
      // print(res.toString());
      // print(req.element.value);
    });
    test('Test ASCII over TCP', () async {
      // ModbusClientSerialAsciiOverTcp asciiClient;
      // asciiClient = ModbusClientSerialAsciiOverTcp(
      //     protocal: ModbusTcpProtocal.tcp,
      //     host: '192.168.1.9',
      //     port: 6000,
      //     unitId: 1);

      // final el = ModbusInt16Register(
      //   name: 'test02',
      //   address: 2,
      //   type: ModbusElementType.holdingRegister,
      //   endianness: ModbusEndianness.CDAB,
      // );
      // var req = el.getReadRequest();
      // var res = await asciiClient.send(req);
      // print(res.toString());
      // print(req.element.value);
    });
  });
}
