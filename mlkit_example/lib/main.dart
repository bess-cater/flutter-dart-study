import 'package:flutter/material.dart';
import 'screens/intro.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
     
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 150, 204, 240)),
      ),
      home:  ObjectDetectorView(),
    );
  }
}
