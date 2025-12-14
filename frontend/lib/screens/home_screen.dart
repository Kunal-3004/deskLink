import 'package:flutter/material.dart';
import 'package:frontend/widgets/remote_grid.dart';
import 'package:provider/provider.dart';
import '../services/websocket_service.dart';
import '../widgets/custom_snackbar.dart';
import 'trackpad_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _ipController = TextEditingController();
  int _selectedIndex = 0; 

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wsService = Provider.of<WebSocketService>(context, listen: false);
      
      wsService.messageStream.listen((message) {
        if (mounted) {
           CustomSnackBar.showInfo(context, message);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final wsService = Provider.of<WebSocketService>(context);


    if (!wsService.isConnected) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E1E2C),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.desktop_windows, size: 80, color: Colors.blueAccent),
                const SizedBox(height: 20),
                const Text(
                  "DeskLink",
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Connect to your PC Agent",
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
                const SizedBox(height: 40),

                TextField(
                  controller: _ipController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Enter PC IP (e.g., 192.168.1.5)",
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    filled: true,
                    fillColor: const Color(0xFF2D2D44),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.wifi, color: Colors.white54),
                    errorText: wsService.statusMessage.contains("Unreachable") ? "Could not find PC" : null,
                  ),
                ),
                const SizedBox(height: 20),

                if (wsService.isConnecting)
                  const CircularProgressIndicator(color: Colors.blueAccent)
                else
                  ElevatedButton(
                    onPressed: () async {
                      if (_ipController.text.isNotEmpty) {
                        await wsService.connect(_ipController.text.trim());
                        if (wsService.isConnected && context.mounted) {
                          CustomSnackBar.showSuccess(context, "Connected to PC! 🚀");
                        }
                      } else {
                        CustomSnackBar.showError(context, "Please enter an IP Address");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Connect", style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      
      appBar: AppBar(
        title: const Text("DeskLink", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2D2D44),
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.circle, color: Colors.green, size: 10),
                const SizedBox(width: 8),
                const Text("Online", style: TextStyle(color: Colors.green, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () {
              wsService.disconnect();
              CustomSnackBar.showInfo(context, "Disconnected");
            },
          )
        ],
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: [
          RemoteGrid(wsService: wsService),
          const TrackpadScreen(),     
          const StatsScreen(),  
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF2D2D44),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "Remote"),
          BottomNavigationBarItem(icon: Icon(Icons.mouse), label: "Trackpad"),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: "Stats"),
        ],
      ),
    );
  }
}