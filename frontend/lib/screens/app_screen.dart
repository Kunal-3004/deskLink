import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshApps();
    });
  }

  Future<void> _refreshApps() async {
    final ws = Provider.of<WebSocketService>(context, listen: false);
    ws.sendCustom("get_apps", "");
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final wsService = Provider.of<WebSocketService>(context);
    final apps = wsService.activeApps;

    return Container(
      color: AppColors.bgColor,
      
      child: RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.cardColor,
        onRefresh: _refreshApps, 
        child: apps.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.only(top: 10, bottom: 80),
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
                      color: AppColors.danger,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.bolt, color: Colors.white, size: 30),
                    ),
                    
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: const Color(0xFF1E1E2C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: AppColors.danger, width: 2),
                          ),
                          title: const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 28),
                              SizedBox(width: 10),
                              Text("Force Stop", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          content: RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.white70, fontSize: 16),
                              children: [
                                const TextSpan(text: "Kill process "),
                                TextSpan(
                                  text: name,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                                ),
                                const TextSpan(text: "?\nUnsaved data will be lost."),
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
                              label: const Text("KILL"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.danger,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: AppIconMapper.getIcon(process),
                        title: Text(
                          name, 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500), 
                          maxLines: 1, 
                          overflow: TextOverflow.ellipsis
                        ),
                        subtitle: Text(
                          "PID: $pid", 
                          style: TextStyle(color: Colors.grey[600], fontSize: 12)
                        ),
                        onTap: () {
                          wsService.sendCustom("activate_app", pid);
                          CustomSnackBar.showSuccess(context, "Switched to $name");
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.accent),
          SizedBox(height: 20),
          Text("Loading Tasks...", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}