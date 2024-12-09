import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:flutter/foundation.dart';
import 'package:telware_cross_platform/core/constants/server_constants.dart';
import 'package:telware_cross_platform/core/mock/constants_mock.dart';
import 'package:telware_cross_platform/features/chat/view_model/event_handler.dart';

class SocketService {
  late Socket _socket;
  late String _serverUrl;
  late String _userId;
  late String _sessionId;
  late Function() _onConnect;
  late EventHandler _eventHandler;
  bool isConnected = false, _isReconnecting = false;

  final Duration _retryDelay =
      Duration(seconds: SOCKET_RECONNECT_DELAY_SECONDS);

  void connect(
      {required String? serverUrl,
      required String? userId,
      required String? sessionId,
      required Function()? onConnect,
      EventHandler? eventHandler}) {
    _serverUrl = serverUrl ?? _serverUrl;
    _userId = userId ?? _userId;
    _sessionId = sessionId ?? _sessionId;
    _onConnect = onConnect ?? _onConnect;
    _eventHandler = eventHandler ?? _eventHandler;

    _connect();
  }

  void _connect() {
    if (isConnected || USE_MOCK_DATA) return;
    debugPrint('*** Entered the connect method');
    debugPrint(_serverUrl);
    debugPrint(_userId);
    debugPrint(_sessionId);

    _socket = io(_serverUrl, <String, dynamic>{
      // 'autoConnect': false,
      "transports": ["websocket"],
      'query': {'userId': _userId},
      'auth': {'sessionId': _sessionId}
    });

    _socket.connect();

    _socket.onConnect((_) {
      debugPrint('### Connected to server');
      isConnected = true;
      _isReconnecting = false;
      _eventHandler.processQueue();
      _onConnect();
    });

    _socket.onConnectError((error) {
      debugPrint('Connection error: $error');
      onError();
    });

    _socket.onError((error) {
      debugPrint('Socket error: $error');
      onError();
    });

    _socket.onDisconnect((_) {
      debugPrint('Disconnected from server');
    });
  }

  void onError() {
    _socket.disconnect();
    isConnected = false;
    _eventHandler.stopProcessing();

    if (_isReconnecting) return;
    _isReconnecting = true;
    Timer(_retryDelay, () {
      _isReconnecting = false;
      _connect();
    });
  }

  void disconnect() {
    _socket.disconnect();
    isConnected = false;
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

  // Private constructor
  SocketService._internal();

  // Singleton instance
  static final SocketService _instance = SocketService._internal();

  // Getter for the singleton instance
  static SocketService get instance => _instance;
}
