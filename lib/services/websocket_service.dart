import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebSocketService {
  StompClient? _stompClient;
  final Map<String, StompUnsubscribe?> _subsriptions = {};

  void connect() {
    _stompClient = StompClient(
      config: StompConfig(
        url: 'ws://3.35.175.114/connection', // 서버의 WebSocket URL
        onConnect: onConnect,
        onWebSocketError: (error) => print('WebSocket Error: $error'),
      ),
    );

    _stompClient?.activate();
  }

  void onConnect(StompFrame frame) {
    print("STOMP WebSocket connected.");
  }

  void subscribe(String topic, Function(Map<String, dynamic>) onMessage) {
    print("StompService: subscribing $topic");
    _stompClient?.subscribe(
      destination: topic,
      callback: (StompFrame frame) {
        print('StompService: received ${frame.body}');
        if (frame.body != null) {
          // final message = Map<String, dynamic>.from(frame.body as Map);
          final message = jsonDecode(frame.body!);
          onMessage(message);
        }
      },
    );
  }

  void unsubscribeDelivery(int id) {

  }

  void disconnect() {
    _stompClient?.deactivate();
  }
}
