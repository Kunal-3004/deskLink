import 'package:flutter/material.dart';
import 'package:frontend/screens/app_screen.dart';
import 'package:frontend/utils/colors.dart';
import 'package:provider/provider.dart';
import '../services/websocket_service.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/remote_grid.dart';

import 'trackpad_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _breathingController;

  final List<Widget> _pages = [
    const TrackpadScreen(), 
    const ConsumerWidgetWrapper(child: RemoteGridWrapper()), 
    const AppsScreen(),    
    const StatsScreen(),    
  ];

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.4,
      upperBound: 1.0,
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wsService = Provider.of<WebSocketService>(context, listen: false);
      wsService.messageStream.listen((message) {
        if (mounted) CustomSnackBar.showInfo(context, message);
      });
    });
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wsService = Provider.of<WebSocketService>(context);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      
      appBar: AppBar(
        title: const Text("DeskLink", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          FadeTransition(
            opacity: _breathingController,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.success.withOpacity(0.5)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.circle, color: AppColors.success, size: 8),
                  SizedBox(width: 6),
                  Text("ONLINE", style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.power_settings_new, color: AppColors.danger),
            tooltip: "Disconnect",
            onPressed: () {
              wsService.disconnect();
              CustomSnackBar.showInfo(context, "Disconnected");
            },
          )
        ],
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.cardColor,
          boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 10)],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.accent,
              unselectedItemColor: Colors.grey,
              selectedFontSize: 12,
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.mouse), label: "Trackpad"),
                BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "Remote"),
                BottomNavigationBarItem(icon: Icon(Icons.window), label: "Tasks"), 
                BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "Stats"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Helpers ---
class RemoteGridWrapper extends StatelessWidget {
  const RemoteGridWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    final ws = Provider.of<WebSocketService>(context);
    return RemoteGrid(wsService: ws);
  }
}

class ConsumerWidgetWrapper extends StatelessWidget {
  final Widget child;
  const ConsumerWidgetWrapper({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return child;
  }
}