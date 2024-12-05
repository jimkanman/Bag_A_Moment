import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebSocketService {
  StompClient? stompClient;
  final Map<String, StompUnsubscribe?> _subsriptions = {};

  void connect() {
    stompClient = StompClient(
      config: StompConfig(
        url: 'ws://3.35.175.114/connection', // 서버의 WebSocket URL
        onConnect: onConnect,
        onWebSocketError: (error) => print('WebSocket Error: $error'),
      ),
    );

    stompClient?.activate();
  }

  void onConnect(StompFrame frame) {
    print("STOMP WebSocket connected.");
  }

  void subscribe(String topic, Function(Map<String, dynamic>) onMessage) {
    stompClient?.subscribe(
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

  void subscribeDelivery(int id) {

  }

  void unsubscribeDelivery(int id) {

  }

  void disconnect() {
    stompClient?.deactivate();
  }
}
