import 'dart:isolate';

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget{
  const HomePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 229, 250),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/quokka.gif'),
            ElevatedButton(onPressed: (){
              var total = veryHardTask();
              debugPrint(total.toString());
            }, child: Text("Event")),
            ElevatedButton(onPressed: ()async {
              var total = await veryHardTask2();
              debugPrint(total.toString());
            }, child: Text("Future")),
            ElevatedButton(onPressed: () async {
              // spawn = create new instance!
              //Function and message you want to pass
              final receceivePort = ReceivePort();
              await Isolate.spawn(veryHardTask3, receceivePort.sendPort);
              receceivePort.listen((total) {
                debugPrint(total.toString());
              });
            }, child: Text("Isolate"))
          ]
        ),
      )
      

    );
  }

double veryHardTask(){
  var total = 0.0;
  for (var i=0; i < 1000000000; i++){
    total+=i;
  }
  return total;

}

Future<double> veryHardTask2() async {
  var total = 0.0;
  for (var i=0; i < 1000000000; i++){
    total+=i;
  }
  return total;

}
  
}
//End of the code!
veryHardTask3(SendPort sendPort){
  var total = 0.0;
  for (var i=0; i < 1000000000; i++){
    total+=i;
  }
  // return total;
  sendPort.send(total);

}