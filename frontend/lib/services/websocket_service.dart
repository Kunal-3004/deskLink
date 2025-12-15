import 'dart:async';
import 'dart:convert';
import 'dart:io'; 
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';

class WebSocketService extends ChangeNotifier {
  WebSocketChannel? _channel;
  bool isConnected = false;
  bool isConnecting = false;
  String statusMessage = "Disconnected";
  Uint8List? latestScreenFrame;

  List<dynamic> activeApps = [];

  String _serverIp = "";

  double cpuUsage = 0;
  double ramUsage = 0;

  final _messageController = StreamController<String>.broadcast();
  Stream<String> get messageStream => _messageController.stream;

  Future<void> connect(String ipAddress) async {
    _serverIp = ipAddress;
    isConnecting = true;
    statusMessage = "Connecting...";
    notifyListeners();

    try {
      final socket = await Socket.connect(ipAddress, 8080, timeout: const Duration(seconds: 2));
      socket.destroy(); 

      final wsUrl = Uri.parse('ws://$ipAddress:8080/ws');
      _channel = WebSocketChannel.connect(wsUrl);

      
      _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          
          if (data['type'] == 'stats') {
            cpuUsage = (data['cpu'] as num).toDouble();
            ramUsage = (data['ram'] as num).toDouble();
            notifyListeners(); 
          }
          if (data['type'] == 'notification') {
            _messageController.add(data['message']);
          }
          if (data['type'] == 'clipboard') {
            String text = data['text'];
            Clipboard.setData(ClipboardData(text: text));
            // _messageController.add("Copied from PC: ${text.substring(0, text.length > 20 ? 20 : text.length)}...");
          }
          if (data['type'] == 'apps_list') {
             String rawJson = data['data'];
             activeApps = jsonDecode(rawJson);
             notifyListeners(); 
          }
          if (data['type'] == 'screen_frame') {
            String base64String = data['data'];
            latestScreenFrame = base64Decode(base64String);
            notifyListeners(); 
          }
        },
        onDone: () {
          _disconnectCleanup("Disconnected from PC");
        },
        onError: (error) {
          _disconnectCleanup("Connection Error");
        },
      );

      isConnected = true;
      statusMessage = "Connected to $ipAddress";

    } catch (e) {
      isConnected = false;
      statusMessage = "Unreachable: Check IP or WiFi";
    } finally {
      isConnecting = false;
      notifyListeners();
    }
  }

  Future<String> uploadFile(File file) async {
    if (!isConnected || _serverIp.isEmpty) return "Not connected to PC";

    final uri = Uri.parse("http://$_serverIp:8080/upload");

    try {
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      var response = await request.send();

      if (response.statusCode == 200) {
        return "File sent successfully! 📂";
      } else {
        return "Server Error: ${response.statusCode}";
      }
    } catch (e) {
      return "Upload failed: $e";
    }
  }

  void sendCommand(String commandID) {
    if (_channel != null && isConnected) {
      final msg = jsonEncode({
        "type": "command",
        "payload": commandID
      });
      _channel!.sink.add(msg);
    }
  }

  void sendCustom(String type, dynamic payload) {
    if (_channel != null && isConnected) {
      final msg = jsonEncode({
        "type": type,
        "payload": payload
      });
      _channel!.sink.add(msg);
    }
  }

  void sendText(String text) {
    if (_channel != null && isConnected) {
      final msg = jsonEncode({
        "type": "type",
        "payload": text
      });
      _channel!.sink.add(msg);
    }
  }

  void sendKey(String keyName) {
    if (_channel != null && isConnected) {
      final msg = jsonEncode({
        "type": "key",
        "payload": keyName
      });
      _channel!.sink.add(msg);
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _disconnectCleanup("Disconnected");
  }

  void _disconnectCleanup(String msg) {
    isConnected = false;
    isConnecting = false;
    statusMessage = msg;
    notifyListeners();
  }

  void sendMouse(int dx, int dy) {
    if (_channel != null && isConnected) {
      final msg = jsonEncode({
        "type": "mouse",
        "dx": dx,
        "dy": dy,
        "payload":""
      });
      _channel!.sink.add(msg);
    }
  }

  void sendClick() {
    if (_channel != null && isConnected) {
      final msg = jsonEncode({"type": "click"});
      _channel!.sink.add(msg);
    }
  }

  void sendRightClick() {
    if (_channel != null && isConnected) {
      final msg = jsonEncode({"type": "right_click"});
      _channel!.sink.add(msg);
    }
  }

  void sendClipboard(String text) {
    if (_channel != null && isConnected) {
      final msg = jsonEncode({
        "type": "clipboard",
        "payload": text 
      });
      _channel!.sink.add(msg);
    }
  }

  @override
  void dispose() {
    _messageController.close();
    super.dispose();
  }
}