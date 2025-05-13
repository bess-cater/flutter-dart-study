import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gesture Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: DraggableExample(),
    );
  }
}
class DraggableExample extends StatefulWidget {
  @override
  _DraggableExampleState createState() => _DraggableExampleState();
}

class _DraggableExampleState extends State<DraggableExample> {
  bool _isDragged = false;
  bool _isDropped = false;
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Gestures ex"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onDoubleTap: () {
                print('Blue tapped');
              },
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Blue Widget',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            GestureDetector(
              onLongPress: () {
                print('Violet tapped');
              },
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Violet Widget',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            LongPressDraggable(
              data: 'PinkWidget',
              feedback: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 231, 155, 180).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'Dragging...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              dragAnchorStrategy: childDragAnchorStrategy, //pointerDragAnchorStrategy,
              // axis: Axis.vertical,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 159, 233, 30),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'Drag me!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              onDragStarted: () {
                setState(() {
                  _isDragged = true;
                });
              },
              onDragEnd: (details) {
                setState(() {
                  _isDragged = false;
                });
              },
            ),
            const SizedBox(height: 20),
            Text(
              _isDragged
                  ? 'Widget is being dragged!'
                  : 'Widget is not being dragged.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            DragTarget(
              builder: (context, candidateData, rejectedData) {
                return Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: candidateData.isEmpty
                        ? (_isDropped ? Colors.green : const Color.fromARGB(255, 175, 52, 93))
                        : Colors.greenAccent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      candidateData.isEmpty
                          ? (_isDropped ? 'Dropped!' : 'Drop here!')
                          : 'Release!',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 18),
                    ),
                  ),
                );
              },
              onAcceptWithDetails: (data) {
                setState(() {
                  _isDropped = true;
                });
                print('Item dropped: $data');
              },
            ),
          ],
        ),
      ),
    );
  }
}