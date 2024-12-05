import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:flutter/foundation.dart';

class SocketService {
  late Socket _socket;

  int _retryAttempts = 0;
  final int _maxRetryAttempts = 5;
  final Duration _initialRetryDelay = const Duration(seconds: 2);

  // Private constructor
  SocketService._internal();

  // Singleton instance
  static final SocketService _instance = SocketService._internal();

  // Getter for the singleton instance
  static SocketService get instance => _instance;

  void connect({
    required String serverUrl,
    required String userId,
    required String sessionId,
    required Function() onConnect,
  }) {
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
      _retryAttempts = 0; // Reset retry attempts on successful connection
      onConnect();
    });

    _socket.onConnectError((error) {
      debugPrint('Connection error: $error');
      _disconnect();
      _retryConnection(serverUrl, userId, sessionId, onConnect);
    });

    _socket.onError((error) {
      debugPrint('Socket error: $error');
      _disconnect();
      _retryConnection(serverUrl, userId, sessionId, onConnect);
    });

    _socket.onDisconnect((_) {
      debugPrint('Disconnected from server');
      _disconnect();
      _retryConnection(serverUrl, userId, sessionId, onConnect);
    });
  }

  void _retryConnection(
      String serverUrl, String userId, String sessionId, Function() onConnect) {
    if (_retryAttempts < _maxRetryAttempts) {
      _retryAttempts++;
      final delay = _initialRetryDelay * _retryAttempts;
      debugPrint('Retrying connection in ${delay.inSeconds} seconds...');
      Timer(delay, () {
        connect(
          serverUrl: serverUrl,
          userId: userId,
          sessionId: sessionId,
          onConnect: onConnect,
        );
      });
    } else {
      debugPrint('Max retry attempts reached. Could not connect to server.');
    }
  }

  void _disconnect() {
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
