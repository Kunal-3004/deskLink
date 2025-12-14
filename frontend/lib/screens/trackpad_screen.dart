import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/websocket_service.dart';
import '../widgets/trackpad_key_button.dart';

class TrackpadScreen extends StatefulWidget {
  const TrackpadScreen({super.key});

  @override
  State<TrackpadScreen> createState() => _TrackpadScreenState();
}

class _TrackpadScreenState extends State<TrackpadScreen> {
  final TextEditingController _textController = TextEditingController();
  String _previousText = "";

  @override
  Widget build(BuildContext context) {
    final wsService = Provider.of<WebSocketService>(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: const Color(0xFF2D2D44),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TrackpadKeyButton(
                label: "ESC", 
                onTap: () => wsService.sendKey("esc")
              ),
              TrackpadKeyButton(
                label: "TAB", 
                onTap: () => wsService.sendKey("tab")
              ),
              
              TrackpadKeyButton(
                label: "R-CLICK",
                color: Colors.orange,
                onTap: () => wsService.sendRightClick(),
              ),

              TrackpadKeyButton(
                label: "ENTER",
                color: Colors.blueAccent,
                onTap: () => wsService.sendKey("enter"),
              ),
              TrackpadKeyButton(
                label: "⌫",
                color: Colors.redAccent,
                onTap: () => wsService.sendKey("backspace"),
              ),
            ],
          ),
        ),

        Expanded(
          child: GestureDetector(
            onPanUpdate: (details) {
              wsService.sendMouse(
                (details.delta.dx * 2.5).toInt(),
                (details.delta.dy * 2.5).toInt(),
              );
            },
            onTap: () {
              HapticFeedback.lightImpact();
              wsService.sendClick();
            },
            onLongPress: () {
              HapticFeedback.mediumImpact();
              wsService.sendRightClick();
            },
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.touch_app, size: 40, color: Colors.white10),
                    SizedBox(height: 10),
                    Text(
                      "Tap = Left Click\nHold = Right Click",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white24, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(15.0),
          child: TextField(
            controller: _textController,
            style: const TextStyle(color: Colors.white),
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: "Type here...",
              hintStyle: TextStyle(color: Colors.grey[600]),
              filled: true,
              fillColor: const Color(0xFF2D2D44),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear, color: Colors.white54),
                onPressed: () {
                  _textController.clear();
                  _previousText = "";
                },
              ),
            ),
            onChanged: (newText) {
              if (newText.length > _previousText.length) {
                String diff = newText.substring(_previousText.length);
                wsService.sendText(diff);
              } else if (newText.length < _previousText.length) {
                int deletionCount = _previousText.length - newText.length;
                for (int i = 0; i < deletionCount; i++) {
                  wsService.sendKey("backspace");
                }
              }
              _previousText = newText;
            },
          ),
        ),
      ],
    );
  }
}