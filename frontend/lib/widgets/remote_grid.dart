import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/screens/app_screen.dart';
import 'package:frontend/utils/colors.dart';
import '../services/websocket_service.dart';
import '../screens/presentation_screen.dart';
import '../widgets/custom_snackbar.dart';

class RemoteGrid extends StatelessWidget {
  final WebSocketService wsService;

  const RemoteGrid({super.key, required this.wsService});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 80), // Extra bottom padding for navbar
      children: [
        
        _buildHeader("Productivity & Tools"),
        _buildGrid([
          _buildBtn(
            context,
            "Send File", 
            Icons.file_upload, 
            Colors.purpleAccent, 
            () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles();
              if (result != null && result.files.single.path != null) {
                File file = File(result.files.single.path!);
                if (context.mounted) CustomSnackBar.showInfo(context, "Sending file... ⏳");
                String response = await wsService.uploadFile(file);
                if (context.mounted) CustomSnackBar.showInfo(context, response);
              }
            }
          ),
          _buildBtn(
            context,
            "Paste Text", 
            Icons.content_paste_go, 
            Colors.pinkAccent, 
            () async {
              ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
              if (data != null && data.text != null) {
                wsService.sendClipboard(data.text!);
                if (context.mounted) CustomSnackBar.showSuccess(context, "Sent to PC Clipboard");
              } else {
                if (context.mounted) CustomSnackBar.showError(context, "Phone clipboard is empty");
              }
            }
          ),
          _buildBtn(
            context,
            "Present Mode", 
            Icons.slideshow, 
            Colors.indigoAccent, 
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PresentationScreen()))
          ),
          _buildBtn(
            context,
            "Task Manager", 
            Icons.window, 
            Colors.cyan, 
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppsScreen()))
          ),
        ]),

        const SizedBox(height: 25),

        _buildHeader("Media Controls"),
        _buildGrid([
          _buildBtn(context, "YouTube", Icons.play_circle_fill, Colors.red, () => wsService.sendCommand("youtube")),
          _buildBtn(context, "Netflix", Icons.movie, Colors.redAccent, () => wsService.sendCommand("netflix")),
          _buildBtn(context, "Vol Up", Icons.volume_up, Colors.green, () => wsService.sendCommand("vol_up")),
          _buildBtn(context, "Vol Down", Icons.volume_down, Colors.teal, () => wsService.sendCommand("vol_down")),
        ]),

        const SizedBox(height: 25),

        _buildHeader("System"),
        _buildGrid([
          _buildBtn(context, "Lock PC", Icons.lock, Colors.orange, () => wsService.sendCommand("lock")),
          _buildBtn(context, "Calculator", Icons.calculate, Colors.blue, () => wsService.sendCommand("calc")),
          _buildBtn(context, "Notepad", Icons.edit_note, Colors.blue, () => wsService.sendCommand("notepad")),
          _buildBtn(context, "Shutdown", Icons.power_settings_new, Colors.red, () => wsService.sendCommand("shutdown")),
        ]),
      ],
    );
  }


  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 5),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textFaded, 
          fontSize: 12, 
          fontWeight: FontWeight.bold, 
          letterSpacing: 1.2
        ),
      ),
    );
  }

  Widget _buildGrid(List<Widget> children) {
    return GridView.count(
      shrinkWrap: true, 
      physics: const NeverScrollableScrollPhysics(), 
      crossAxisCount: 2, 
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 2.2,
      children: children,
    );
  }

  Widget _buildBtn(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: AppColors.cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
            HapticFeedback.lightImpact(); 
            onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(width: 12),
              Flexible( 
                child: Text(
                  label, 
                  style: const TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.w600,
                    fontSize: 14
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}