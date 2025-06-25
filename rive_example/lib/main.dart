import 'package:flutter/material.dart';
import 'package:rive/rive.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Rive Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SMITrigger? _tapTrigger;

  void _onStateChange(
          String stateMachineName,
          String stateName,
        ) => print('State Changed in $stateMachineName to $stateName');
            

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            _tapTrigger?.fire();
          },
          child: SizedBox(
            width: 250,
            height: 250,
            child: RiveAnimation.asset(
              'assets/star2.riv',
              fit: BoxFit.contain,
              // stateMachines: ['bumpy'],
              onInit: _onRiveInit,
            ),
          ),
        ),
      ),
    );
  }

  /// Called when Rive file is loaded
  

void _onRiveInit(Artboard artboard) {
  final controller = StateMachineController.fromArtboard(artboard, 'State Machine 1', onStateChange: _onStateChange);
  if (controller != null) {
    artboard.addController(controller);

    

    _tapTrigger = controller.findInput<bool>('Tap') as SMITrigger;
  }

  
}
}
