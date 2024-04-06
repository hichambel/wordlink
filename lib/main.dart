import 'package:flutter/material.dart';
import 'package:wordlink_project_final/Pages/home_page.dart';
import 'package:wordlink_project_final/pages/game_over.dart';
import 'package:wordlink_project_final/pages/game_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: const HomePage(),
        routes: {
          '/homepage': (context) => const HomePage(),
          '/gamepage': (context) => const GamePage(),
          '/gameover': (context) => const GameOver()
        },
      );
  }
}
