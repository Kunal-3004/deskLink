import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/websocket_service.dart';
import '../widgets/custom_snackbar.dart';


class FileExplorerScreen extends StatefulWidget {
  const FileExplorerScreen({super.key});

  @override
  State<FileExplorerScreen> createState() => _FileExplorerScreenState();
}

class _FileExplorerScreenState extends State<FileExplorerScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WebSocketService>(context, listen: false).sendCustom("get_files", ""); 
    });
  }

  void _openOnPhone(String path, String ip) async {
    final encodedPath = Uri.encodeComponent(path);
    final url = Uri.parse("http://$ip:8080/download?path=$encodedPath");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not launch file")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ws = Provider.of<WebSocketService>(context);
    final files = ws.currentFiles;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("File Explorer"),
            Text(ws.currentPath.isEmpty ? "My Computer" : ws.currentPath, 
                 style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        backgroundColor: Colors.grey[900],
      ),
      body: files.isEmpty
          ? const Center(child: Text("No Drives Found or Loading...", style: TextStyle(color: Colors.white)))
          : ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                final String name = file['name'];
                final String type = file['type'];
                final String path = file['path'];

                IconData icon = Icons.insert_drive_file;
                Color color = Colors.blueGrey;

                if (type == 'drive') {       
                  icon = Icons.storage;
                  color = Colors.greenAccent;
                } else if (type == 'folder') {
                  icon = Icons.folder;
                  color = Colors.amber;
                } else if (type == 'back') {
                  icon = Icons.arrow_upward;
                  color = Colors.white;
                } else if (name.endsWith('.mp4') || name.endsWith('.mkv')) {
                    icon = Icons.movie; color = Colors.red;
                } else if (name.endsWith('.jpg') || name.endsWith('.png')) {
                    icon = Icons.image; color = Colors.purple;
                }

                return ListTile(
                  leading: Icon(icon, color: color),
                  title: Text(name, style: const TextStyle(color: Colors.white)),

                  trailing: (type == 'file') 
                    ? IconButton(
                        icon: const Icon(Icons.download_for_offline, color: Colors.blueAccent),
                        onPressed: () => _openOnPhone(path, ws.serverIp),
                      )
                    : null,
                  onTap: () {
                    if (type == 'folder' || type == 'back' || type == 'drive') {
                      ws.sendCustom("get_files", path);
                    } else {
                      ws.sendCustom("open_file", path);
                      CustomSnackBar.showSuccess(context, "Opening...");
                    }
                  },
                );
              },
            ),
    );
  }
}