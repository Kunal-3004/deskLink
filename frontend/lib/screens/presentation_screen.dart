import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../services/websocket_service.dart';

class PresentationScreen extends StatefulWidget {
  const PresentationScreen({super.key});

  @override
  State<PresentationScreen> createState() => _PresentationScreenState();
}

class _PresentationScreenState extends State<PresentationScreen> {

  Timer? _timer;
  int _seconds = 0;
  bool _isTimerRunning = false;

  bool _isAirMouseActive = false;
  StreamSubscription? _gyroSubscription;
  DateTime _lastSendTime = DateTime.now();

  @override
  void dispose() {
    _timer?.cancel();
    _gyroSubscription?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    setState(() {
      _isTimerRunning = !_isTimerRunning;
    });
    if (_isTimerRunning) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() => _seconds++);
      });
    } else {
      _timer?.cancel();
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _seconds = 0;
      _isTimerRunning = false;
    });
  }

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  void _toggleAirMouse(WebSocketService wsService) {
    setState(() {
      _isAirMouseActive = !_isAirMouseActive;
    });

    if (_isAirMouseActive) {
      _gyroSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
        if (event.x.abs() < 0.1 && event.z.abs() < 0.1) return;
        if (DateTime.now().difference(_lastSendTime).inMilliseconds < 50) return;
        _lastSendTime = DateTime.now();
        int dx = (event.z * -15).toInt();
        int dy = (event.x * -15).toInt();
        wsService.sendMouse(dx, dy);
      });
      HapticFeedback.mediumImpact();
    } else {
      _gyroSubscription?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final wsService = Provider.of<WebSocketService>(context);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: const Text("Presentation Mode",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.white,),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF2D2D44),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_formatTime(_seconds), 
                  style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, fontFamily: 'monospace')
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: Icon(_isTimerRunning ? Icons.pause_circle : Icons.play_circle, size: 40, color: Colors.blueAccent),
                  onPressed: _toggleTimer,
                ),
                IconButton(
                  icon: const Icon(Icons.replay, size: 30, color: Colors.white54),
                  onPressed: _resetTimer,
                ),
              ],
            ),
          ),

          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      wsService.sendCommand("prev_slide");
                    },
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_back_ios, size: 50, color: Colors.white),
                          Text("PREV", style: TextStyle(color: Colors.white54))
                        ],
                      ),
                    ),
                  ),
                ),
                
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      wsService.sendCommand("next_slide");
                    },
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green[700],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_forward_ios, size: 80, color: Colors.white),
                          Text("NEXT SLIDE", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.desktop_access_disabled),
                    label: const Text("Black Screen"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black54, padding: const EdgeInsets.symmetric(vertical: 15)),
                    onPressed: () => wsService.sendCommand("black_screen"),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(_isAirMouseActive ? Icons.wifi_tethering : Icons.wifi_tethering_off),
                    label: Text(_isAirMouseActive ? "Laser ON" : "Laser OFF"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isAirMouseActive ? Colors.redAccent : Colors.grey, 
                      padding: const EdgeInsets.symmetric(vertical: 15)
                    ),
                    onPressed: () => _toggleAirMouse(wsService),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}