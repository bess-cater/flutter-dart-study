import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class Physics extends StatelessWidget {
  const Physics({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const DraggableCard(child: FlutterLogo(size: 128)),
    );
  }
}

class DraggableCard extends StatefulWidget {
  const DraggableCard({required this.child, super.key});

  final Widget child;

  @override
  State<DraggableCard> createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _animation;
  Alignment _dragAlignment = Alignment.center;


  void _runAnimation(Offset pixelsPerSecond, Size size) {
  _animation = _controller.drive(
    AlignmentTween(begin: _dragAlignment, end: Alignment.center),
  );
  final unitsPerSecondX = pixelsPerSecond.dx / size.width;
  final unitsPerSecondY = pixelsPerSecond.dy / size.height;
  final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
  final unitVelocity = unitsPerSecond.distance;

  const spring = SpringDescription(mass: 30, stiffness: 1, damping: 1);

  final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);

  _controller.animateWith(simulation);
}

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
        _controller.addListener(() {
    setState(() {
      _dragAlignment = _animation.value;
    });
  });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  var size = MediaQuery.of(context).size;
  return GestureDetector(
    onPanDown: (details) {
      _controller.stop();
    },
    onPanUpdate: (details) {
      setState(() {
        print("Call setstate()");
        _dragAlignment += Alignment(
          details.delta.dx / (size.width / 2),
          details.delta.dy / (size.height / 2),
        );
      });
    },
    onPanEnd: (details) {
      _runAnimation(details.velocity.pixelsPerSecond, size);
    },
    child: Align(
      alignment: _dragAlignment,
      child: Card(
        child: widget.child,
      ),
    ),
  );
}

}