
import 'package:flutter/material.dart';

class ExplicitPage extends StatefulWidget {
  const ExplicitPage({super.key});

  @override
  State<ExplicitPage> createState() => _ExplicitPageState();
}

class _ExplicitPageState extends State<ExplicitPage>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat(); // Always rotates in same direction

    _fadeController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true); // 🌗 Fades in and out

    _fadeAnimation = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Explicit Animation')),
      body: Center(
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.bottomLeft,
              child: TimeStopper(controller: _rotationController),
            ),
            Align(
              alignment: Alignment.center,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: RotationTransition(
                  turns: _rotationController,
                  alignment: Alignment.center,
                  child: Image.asset('assets/galaxy.png'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeStopper extends StatelessWidget {
  final AnimationController controller;

  const TimeStopper({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (controller.isAnimating) {
          controller.stop();
        } else {
          controller.repeat();
        }
      },
      child: InvisibleBox(size: 100),
    );
  }
}

class InvisibleBox extends StatelessWidget {
  final double size;

  const InvisibleBox({Key? key, required this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: Colors.transparent,
    );
  }
}