import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';
import 'package:provider/provider.dart';
import '../services/websocket_service.dart';
import '../widgets/custom_snackbar.dart';
import 'qr_scan_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _ipController = TextEditingController();

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wsService = Provider.of<WebSocketService>(context);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, spreadRadius: 5)
                  ],
                ),
                child: const Icon(Icons.desktop_windows, size: 60, color: AppColors.primary),
              ),
              const SizedBox(height: 30),
              
              const Text(
                "DeskLink",
                style: TextStyle(color: AppColors.textMain, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Control your PC remotely",
                style: TextStyle(color: AppColors.textFaded, fontSize: 16),
              ),
              const SizedBox(height: 50),

              TextField(
                controller: _ipController,
                style: const TextStyle(color: AppColors.textMain),
                decoration: InputDecoration(
                  hintText: "192.168.1.X",
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: AppColors.cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.wifi, color: Colors.white30),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code_scanner, color: AppColors.accent),
                    onPressed: () async {
                      final ip = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const QRScanScreen()),
                      );
                      if (ip != null) _ipController.text = ip;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 25),

              if (wsService.isConnecting)
                const CircularProgressIndicator(color: AppColors.accent)
              else
                ElevatedButton(
                  onPressed: () async {
                    if (_ipController.text.isNotEmpty) {
                      await wsService.connect(_ipController.text.trim());
                    } else {
                      CustomSnackBar.showError(context, "Please enter an IP");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    shadowColor: AppColors.primary.withOpacity(0.5),
                  ),
                  child: const Text("Connect", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}