import 'package:flutter/material.dart';

class ImplicitPage extends StatefulWidget {
  const ImplicitPage({super.key});

  @override
  State<ImplicitPage> createState() => _ImplicitPageState();
}

Tween<double> myTweenValue = Tween<double>(begin: 1, end: 1);

class _ImplicitPageState extends State<ImplicitPage> {
  bool isSelected = false;
  bool isBigger = false;

  void toggle() {
    setState(() {
      isSelected = !isSelected;
    });
  }

  void toggleImage() {
    setState(() {
      isBigger = !isBigger;
    });
  }

  void scaleContainer() {
    setState(() {
     myTweenValue = Tween<double>(begin: 1, end: 2);

      print(myTweenValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Implicit Animation')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: toggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                color: isSelected ? Colors.green : Colors.grey,
                width: isSelected ? 200 : 100,
                height: 100,
                alignment: Alignment.center,
                child: Text(
                  isSelected ? 'Selected' : 'Tap me!',
                  style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    
                  ),
                  Padding(padding: EdgeInsets.all(16.0),),
                    GestureDetector(
                      onTap: toggleImage,
                      child: AnimatedRotation(
                        turns: isBigger ? 0.5 : 0.0, // 0.5 = 180 degrees
                          duration: Duration(seconds: 1),
                          curve: Curves.easeInOut,
                        child: AnimatedContainer(
                          width: isBigger ? 50 : 200,
                          
                          duration: Duration(seconds: 1),
                          // decoration: BoxDecoration(
                          //   gradient: RadialGradient(
                          //     colors: [const Color.fromARGB(255, 194, 118, 208), Colors.transparent],
                          //     stops: [ isBigger ? 0.2 : 0.9, 5.0])
                          // ),
                          curve: Curves.bounceIn, //bounceInOut
                          child: Image.asset(
                            'assets/flower.png',
                            fit: BoxFit.fill, // or BoxFit.cover
                          ),
                            ),
                      ),
              
                        ),
                        Padding(padding: EdgeInsets.all(16.0),),
                  GestureDetector(
                    onTap: scaleContainer,
                    child: TweenAnimationBuilder(
                        tween: myTweenValue,
                        duration: const Duration(seconds: 1),
                        
                        builder: (context, value, child) {
                    
                          // The value will be fetched from the tween
                          // return Transform.scale(
                          //   scale: value,
                          //   child: child,
                          // );
                          return Transform(
                            
                            transform: Matrix4.rotationX(value),
                            child: child,
                          );
                        },
              child: Container(
                width: 50,
                height: 50,
                color: Colors.deepOrange,
              ),
            )
                  ),

              
          ],
        ),
      ),
    );
  }
}