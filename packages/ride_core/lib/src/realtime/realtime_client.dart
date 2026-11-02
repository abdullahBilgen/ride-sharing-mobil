import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class RealtimeClient {
  RealtimeClient(this.uri, {this.reconnectDelay = const Duration(seconds: 2)});
  final Uri uri;
  final Duration reconnectDelay;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  final _messages = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messages => _messages.stream;
  bool _closed = false;

  Future<void> connect() async {
    _closed = false;
    await _open();
  }
  Future<void> _open() async {
    if (_closed) return;
    try {
      final channel = WebSocketChannel.connect(uri);
      _channel = channel;
      await channel.ready;
      _subscription = channel.stream.listen((event) {
        if (event is String) _messages.add(jsonDecode(event) as Map<String, dynamic>);
      }, onDone: _reconnect, onError: (_) => _reconnect());
    } catch (_) { _reconnect(); }
  }
  void _reconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    if (!_closed) Future.delayed(reconnectDelay, _open);
  }
  void send(Map<String, dynamic> payload) => _channel?.sink.add(jsonEncode(payload));
  Future<void> close() async {
    _closed = true;
    await _subscription?.cancel();
    await _channel?.sink.close();
    await _messages.close();
  }
}
