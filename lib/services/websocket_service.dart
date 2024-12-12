import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebSocketService {
  StompClient? _stompClient;
  final Map<int, StompUnsubscribe?> _subscriptions = {}; // 구독 ID & 상태 추적

  void connect({void Function(StompFrame)? onConnect}) {
    _stompClient = StompClient(
      config: StompConfig(
        url: 'ws://3.35.175.114:8080/connection', // 서버의 WebSocket URL
        onConnect: onConnect ?? defaultOnConnect,
        onWebSocketError: (error) => print('WebSocket Error: $error'),
      ),
    );

    _stompClient!.activate();
  }

  void defaultOnConnect(StompFrame frame) {
    print("STOMP WebSocket connected.");
  }

  void subscribe(int id, String topic, Function(Map<String, dynamic>) onMessage) {
    print("StompService: subscribing $topic");
    if (_subscriptions.containsKey(topic)) {
      print("StompService: subscription already exists; returning");
      return;
    }
    final subscription = _stompClient!.subscribe(
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
    // 구독 ID 저장
    _subscriptions[id] = subscription;
  }

  void unsubscribe(int deliveryId) {
    if (_subscriptions.containsKey(deliveryId)) {
      print("StompService: unsubscribing from $deliveryId");
      if(_subscriptions[deliveryId] == null) {
        print("Warning: subscription $deliveryId is null");
      }
      _subscriptions[deliveryId]?.call(); // 구독 해제
      _subscriptions.remove(deliveryId); // 구독 목록에서 제거
    }
  }

  void disconnect() {
    print("WebsocketService: Disconnecting..");
    if(_stompClient == null) print("Warning: stompClient was null");
    _subscriptions.keys.toList().forEach(unsubscribe);
    _subscriptions.clear();
    _stompClient?.deactivate();
  }
}
