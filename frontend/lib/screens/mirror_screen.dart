import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/websocket_service.dart';

class ScreenMirrorScreen extends StatefulWidget {
  const ScreenMirrorScreen({super.key});

  @override
  State<ScreenMirrorScreen> createState() => _ScreenMirrorScreenState();
}

class _ScreenMirrorScreenState extends State<ScreenMirrorScreen> {
  Timer? _refreshTimer;
  final GlobalKey _imageKey = GlobalKey();
  
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textController = TextEditingController();
  
  DateTime _lastMoveTime = DateTime.now();
  final String _anchor = "\u200B"; 
  @override
  void initState() {
    super.initState();
    _textController.text = _anchor;

    _refreshTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        Provider.of<WebSocketService>(context, listen: false).sendCustom("get_screen", "");
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    
    _refreshTimer?.cancel();
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  Map<String, double>? _getPercentPos(Offset globalPos) {
    final RenderBox? box = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;

    final Offset localPos = box.globalToLocal(globalPos);
    final Size size = box.size;

    double px = localPos.dx / size.width;
    double py = localPos.dy / size.height;

    if (px < 0) px = 0; if (px > 1) px = 1;
    if (py < 0) py = 0; if (py > 1) py = 1;

    return {"x": px, "y": py};
  }

  void _handlePan(DragUpdateDetails details) {
    if (DateTime.now().difference(_lastMoveTime).inMilliseconds < 30) return;
    _lastMoveTime = DateTime.now();

    final pos = _getPercentPos(details.globalPosition);
    if (pos != null) {
      Provider.of<WebSocketService>(context, listen: false).sendCustom("mouse_move_absolute", pos);
    }
  }

  // void _handleTap(TapUpDetails details) {
  //   if (_focusNode.hasFocus) _focusNode.unfocus();
  //   final pos = _getPercentPos(details.globalPosition);
  //   if (pos != null) {
  //     Provider.of<WebSocketService>(context, listen: false).sendCustom("mouse_tap_absolute", pos);
  //   }
  // }

  void _handleTextChange(String value) {
    final ws = Provider.of<WebSocketService>(context, listen: false);

    if (value.isEmpty) {
      ws.sendCustom("key", "backspace");
    } else if (value.length > 1) {
      String newChar = value.substring(1); 
      ws.sendCustom("type", newChar);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _textController.text = _anchor;
        _textController.selection = TextSelection.fromPosition(TextPosition(offset: 1));
      }
    });
  }

  void _toggleKeyboard() {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
    } else {
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ws = Provider.of<WebSocketService>(context);
    final imageBytes = ws.latestScreenFrame;

    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      
      appBar: isLandscape 
          ? null 
          : AppBar(
              title: const Text("Live Control"),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: Icon(Icons.keyboard, color: _focusNode.hasFocus ? Colors.blueAccent : Colors.white),
                  onPressed: _toggleKeyboard,
                ),
              ],
            ),
      
      floatingActionButton: isLandscape 
        ? FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white.withOpacity(0.3),
            elevation: 0,
            onPressed: _toggleKeyboard,
            child: const Icon(Icons.keyboard, color: Colors.white),
          )
        : null,

      body: Stack(
        children: [
          Offstage(
            offstage: true, 
            child: TextField(
              focusNode: _focusNode,
              controller: _textController,
              autofocus: false,
              autocorrect: true,       
              enableSuggestions: true, 
              keyboardType: TextInputType.multiline, 
              onChanged: _handleTextChange,
              onSubmitted: (_) {
                ws.sendCustom("key", "enter");
                _focusNode.requestFocus();
              },
            ),
          ),

          imageBytes == null
              ? const Center(child: CircularProgressIndicator())
              : SizedBox.expand(
                  child: Container(
                    color: Colors.black,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: GestureDetector(
                        onPanUpdate: _handlePan,
                        // onTapUp: _handleTap,
                        child: Image.memory(
                          imageBytes,
                          key: _imageKey,
                          gaplessPlayback: true,
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}