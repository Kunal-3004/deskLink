import 'package:flutter/material.dart';
import 'package:frontend/utils/icons.dart';
import 'package:provider/provider.dart';
import '../services/websocket_service.dart';
import '../widgets/custom_snackbar.dart';

class AppsScreen extends StatefulWidget {
  const AppsScreen({super.key});

  @override
  State<AppsScreen> createState() => _AppsScreenState();
}

class _AppsScreenState extends State<AppsScreen> {
  List<dynamic> _apps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ws = Provider.of<WebSocketService>(context, listen: false);
      ws.sendCustom("get_apps", "");
      
      ws.messageStream.listen((message) {
 
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final wsService = Provider.of<WebSocketService>(context);

    final apps = wsService.activeApps; 

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text("Task Manager",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh,color: Colors.white,),
            onPressed: () => wsService.sendCustom("get_apps", ""),
          )
        ],
      ),
      body: apps.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: apps.length,
              itemBuilder: (context, index) {
                final app = apps[index];
                final String name = app['MainWindowTitle'] ?? "Unknown";
                final int pid = app['Id'];
                final String process = app['ProcessName'] ?? "";

                return Dismissible(
                  key: Key(pid.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete_forever, color: Colors.white, size: 30),
                  ),
                  
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: const Color(0xFF1E1E2C), 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), 
                          side: const BorderSide(color: Colors.redAccent, width: 2), 
                        ),
                        title: const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
                            SizedBox(width: 10),
                            Text("Force Stop", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        content: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.white70, fontSize: 16),
                            children: [
                              const TextSpan(text: "Are you sure you want to kill "),
                              TextSpan(
                                text: name, 
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                              ),
                              const TextSpan(text: "?\n\nAny unsaved data will be lost immediately."),
                            ],
                          ),
                        ),
                        actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false), 
                            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                          ),
                          
                          ElevatedButton.icon(
                            icon: const Icon(Icons.bolt, size: 18),
                            label: const Text("KILL PROCESS"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white, 
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            onPressed: () {
                              Navigator.pop(ctx, true);
                              wsService.sendCustom("kill_app", pid);
                            }, 
                          ),
                        ],
                      ),
                    );
                  },

                  onDismissed: (direction) {
                    setState(() {
                      wsService.activeApps.removeAt(index);
                    });
                    
                    CustomSnackBar.showInfo(context, "Killed $name");
                  },

                  child: ListTile(
                    leading: AppIconMapper.getIcon(process),
                    title: Text(name, style: const TextStyle(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text("PID: $pid", style: const TextStyle(color: Colors.grey)),
                    onTap: () {
                      wsService.sendCustom("activate_app", pid);
                      CustomSnackBar.showSuccess(context, "Switched to $name");
                    },
                  ),
                );
              },
            ),
    );
  }
}