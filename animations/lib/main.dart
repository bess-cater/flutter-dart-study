import 'package:flutter/material.dart';
import 'animation_pages/explicit.dart';
import 'animation_pages/implicit.dart';
import 'animation_pages/physics.dart';
import 'animation_pages/animated.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Animations',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 100, 170, 149)),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animation Types')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Implicit Animation'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ImplicitPage()),
            ),
          ),
          ListTile(
            title: const Text('Explicit Animation'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ExplicitPage()),
            ),
          ),

          ListTile(
            title: const Text('Animated Widget'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AnimatedPage()),
            ),
          ),
          ListTile(
            title: const Text('Physics animation'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Physics()),
            ),
          ),
        ],
      ),
    );
  }
}