import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/websocket_service.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wsService = Provider.of<WebSocketService>(context);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStatCard("CPU Usage", wsService.cpuUsage, Colors.blueAccent),
          const SizedBox(height: 20),
          _buildStatCard("RAM Usage", wsService.ramUsage, Colors.purpleAccent),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D44),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 60,
            width: 60,
            child: CircularProgressIndicator(
              value: value / 100, 
              backgroundColor: Colors.white10,
              color: color,
              strokeWidth: 8,
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white70, fontSize: 16)),
              Text(
                "${value.toInt()}%",
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }
}