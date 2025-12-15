import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/screens/presentation_screen.dart'; 
import '../services/websocket_service.dart';
import '../widgets/macro_button.dart';
import '../widgets/custom_snackbar.dart';

class RemoteGrid extends StatelessWidget {
  final WebSocketService wsService;

  const RemoteGrid({super.key, required this.wsService});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Shortcuts", 
            style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 1)
          ),
          const SizedBox(height: 15),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.1, 
              children: [
                MacroButton(
                  label: "Send File", 
                  icon: Icons.file_upload, 
                  color: Colors.purpleAccent,
                  onTap: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles();

                    if (result != null && result.files.single.path != null) {
                      File file = File(result.files.single.path!);
                      
                      if (context.mounted) {
                        CustomSnackBar.showInfo(context,"Sending file... ⏳");
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   const SnackBar(content: Text("Sending file... ⏳")),
                        // );
                      }

                      String response = await wsService.uploadFile(file);
                      
                      if (context.mounted) CustomSnackBar.showInfo(context, response);
                    }
                  },
                ),

                MacroButton(
                  label: "Present Mode",
                  icon: Icons.slideshow,
                  color: Colors.indigoAccent,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PresentationScreen()),
                    );
                  },
                ),
                            
                MacroButton(
                  label: "Calculator",
                  icon: Icons.calculate,
                  color: Colors.orange,
                  onTap: () => wsService.sendCommand("calc"),
                ),
                
                MacroButton(
                  label: "Paste to PC",
                  icon: Icons.content_paste_go,
                  color: Colors.pinkAccent,
                  onTap: () async {
                    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
                    if (data != null && data.text != null) {
                       wsService.sendClipboard(data.text!);
                       if (context.mounted) CustomSnackBar.showSuccess(context, "Sent to PC Clipboard");
                    } else {
                       if (context.mounted) CustomSnackBar.showError(context, "Phone clipboard is empty");
                    }
                  },
                ),
                
                MacroButton(
                  label: "YouTube",
                  icon: Icons.video_library,
                  color: Colors.redAccent,
                  onTap: () => wsService.sendCommand("youtube"),
                ),
                MacroButton(
                  label: "Netflix",
                  icon: Icons.movie,
                  color: Colors.red,
                  onTap: () => wsService.sendCommand("netflix"),
                ),
                MacroButton(
                  label: "Lock PC",
                  icon: Icons.lock,
                  color: Colors.blueGrey,
                  onTap: () => wsService.sendCommand("lock"),
                ),
                MacroButton(
                  label: "Notepad",
                  icon: Icons.edit_note,
                  color: Colors.blue,
                  onTap: () => wsService.sendCommand("notepad"),
                ),
                MacroButton(
                  label: "Vol Up",
                  icon: Icons.volume_up,
                  color: Colors.green,
                  onTap: () => wsService.sendCommand("vol_up"),
                ),
                MacroButton(
                  label: "Vol Down",
                  icon: Icons.volume_down,
                  color: Colors.teal,
                  onTap: () => wsService.sendCommand("vol_down"),
                ),
                MacroButton(
                  label: "Shutdown",
                  icon: Icons.power_settings_new,
                  color: Colors.red,
                  onTap: () => wsService.sendCommand("shutdown"),
                ),
                MacroButton(
                  label: "Ping Test",
                  icon: Icons.network_check,
                  color: Colors.purple,
                  onTap: () => wsService.sendCommand("ping"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}