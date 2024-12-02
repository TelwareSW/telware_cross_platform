import 'package:socket_io_client/socket_io_client.dart';
import 'package:flutter/foundation.dart';
import 'package:telware_cross_platform/core/constants/server_constants.dart';

class SocketService {
  late Socket _socket;

  // Private constructor
  SocketService._internal();

  // Singleton instance
  static final SocketService _instance = SocketService._internal();

  // Getter for the singleton instance
  static SocketService get instance => _instance;

  void connect(
      {required String serverUrl,
      required String userId,
      required String sessionId,
      required Function() onConnect}) {
    debugPrint('*** Entered the connect method');
    debugPrint(serverUrl);
    debugPrint(userId);
    debugPrint(sessionId);

    _socket = io(serverUrl, <String, dynamic>{
      // 'autoConnect': false,
      "transports": ["websocket"],
      'query': {'userId': userId},
      'auth': {'sessionId': sessionId}
    });

    _socket.connect();

    _socket.onConnect((_) {
      debugPrint('### Connected to server');
      onConnect();
    });

    _socket.onConnectError((error) {
      debugPrint('Connection error: $error');
    });

    _socket.onError((error) {
      debugPrint('Socket error: $error');
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

  void emitWithAck(String event, dynamic data,
      {required Function(dynamic data) ackCallback}) {
    _socket.emitWithAck(event, data, ack: ackCallback);
  }
}
