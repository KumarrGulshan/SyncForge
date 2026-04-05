import 'package:stomp_dart_client/stomp_dart_client.dart';

class SocketService {

  StompClient? _client;

  void connect({
    required String projectId,
    required String token,
    required Function(String message) onMessage,
  }) {

    if (_client != null && _client!.connected) {
      return;
    }

    _client = StompClient(
      config: StompConfig(

        url: 'ws://192.168.1.147:8080/ws/websocket',

        reconnectDelay: const Duration(seconds: 5),

        stompConnectHeaders: {
          'Authorization': 'Bearer $token',
        },

        webSocketConnectHeaders: {
          'Authorization': 'Bearer $token',
        },

        onConnect: (StompFrame frame) {

          print("WebSocket Connected");

          _client?.subscribe(
            destination: '/topic/project/$projectId',

            callback: (frame) {

              if (frame.body != null) {

                print("Realtime event: ${frame.body}");

                onMessage(frame.body!);
              }

            },
          );
        },

        onWebSocketError: (dynamic error) {
          print("WebSocket error: $error");
        },

        onDisconnect: (frame) {
          print("WebSocket disconnected");
        },

        onStompError: (frame) {
          print("STOMP error: ${frame.body}");
        },

      ),
    );

    _client!.activate();
  }

  void disconnect() {

    if (_client != null) {
      _client!.deactivate();
      _client = null;
    }

  }
}