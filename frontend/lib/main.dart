import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';
import 'package:provider/provider.dart';
import 'services/websocket_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WebSocketService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DeskLink',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.bgColor,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.accent,
        ),
      ),
      // THE TRAFFIC COP 🚦
      home: Consumer<WebSocketService>(
        builder: (context, wsService, child) {
          if (wsService.isConnected) {
            return const HomeScreen();
          } 
          else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}