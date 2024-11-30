import 'package:socket_io_client/socket_io_client.dart';
import 'package:flutter/foundation.dart';

class SocketService {
  late Socket _socket;

  // Private constructor
  SocketService._internal();

  // Singleton instance
  static final SocketService _instance = SocketService._internal();

  // Getter for the singleton instance
  static SocketService get instance => _instance;

  void connect(String serverUrl, Function() onConnect) {
    _socket = io(serverUrl, OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .build());

    _socket.onConnect((_) {
      debugPrint('Connected to server');
      onConnect();
    });

    _socket.onDisconnect((_) {
      debugPrint('Disconnected from server');
    });
  }

  void disconnect() {
    _socket.disconnect();
  }

  void on(String event, Function(dynamic data) callback) {
    _socket.on(event, callback);
  }

  void emit(String event, dynamic data) {
    _socket.emit(event, data);
  }

  void emitWithAck(String event, dynamic data, {required Function(dynamic data) ackCallback}) {
    _socket.emitWithAck(event, data, ack: ackCallback);
  }
}