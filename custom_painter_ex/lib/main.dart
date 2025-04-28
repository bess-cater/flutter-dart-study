import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:table_calendar/table_calendar.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
   return MaterialApp( // Wrap your widget tree with MaterialApp
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() =>
      _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimationController animationController;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  final List<int> sleepData = List.generate(31, (index) => index == 0 ? 0 : Random().nextInt(11) + 2);
  // final DateTime? selectedStartDate;
  // final DateTime? selectedEndDate;
  // final Function(DateTime?, DateTime?)? onRangeSelected;

  // _MyHomePageState(
  //   this.selectedStartDate,
  //   this.selectedEndDate, {
  //   this.onRangeSelected,
  // });
  List<int> getSleepDataForRange() {
    if (selectedStartDate == null || selectedEndDate == null) {
      return [];
    }

    // Get the start and end days of the selected range
    int startDay = selectedStartDate!.day;
    int endDay = selectedEndDate!.day;

    // Ensure that the range is within valid bounds (1-31 days)
    startDay = startDay.clamp(1, 31);
    endDay = endDay.clamp(1, 31);

    // Return the sleep data for the selected date range (inclusive)
    return sleepData.sublist(startDay - 1, endDay);
  }


  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    animationController.forward();
  }
  void resetAnimation() {
    animationController.reset(); // Reset animation to the start
    animationController.forward(); // Start the animation
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    List<int> myList = [10, 90, 35, 80, 98, 56];

    return Scaffold(
      appBar: AppBar(title: const Text('My Sleep Data')),
      body: Column(
        children: [
          Container(
            height: 200, // Fixed height to prevent the layout shift
            child: AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                if (animationController.value < 0.1) {
                  return const SizedBox();
                }
                return CustomPaint(
                  size: Size(screenWidth, 200),
                  painter: MyPainter(getSleepDataForRange(), animationController.value),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(20), 
            child: TableCalendar(
              focusedDay: DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day), 
              firstDay: DateTime.utc(2025, 4, 1),
              lastDay: DateTime.utc(2025, 4, 30),
              rangeStartDay: selectedStartDate,
              rangeEndDay: selectedEndDate,
              onRangeSelected: (start, end, _) {
                setState(() {
                  selectedStartDate = start;
                  selectedEndDate = end;
                  resetAnimation();
                });
              },
              calendarStyle: CalendarStyle(
                rangeHighlightColor: const Color.fromARGB(135, 28, 83, 165),
                rangeStartDecoration: const BoxDecoration(
                  color:  Color.fromARGB(227, 28, 83, 165),
                  shape: BoxShape.circle,
                ),
                rangeEndDecoration: const BoxDecoration(
                  color: Color.fromARGB(227, 28, 83, 165),
                  shape: BoxShape.circle,
                ),
                
              ),
              rangeSelectionMode: RangeSelectionMode.toggledOn,
            ),
          ),
        ],
      ),
    );
  }
}



class MyPainter extends CustomPainter{
  final List<int> numbers;
  final double value;

  MyPainter(this.numbers, this. value);

  

  @override
  void paint(ui.Canvas canvas, ui.Size _size) {
    var elements_n = numbers.length;
    var corner_offset = 20.0;
    var drawing_length = _size.width-corner_offset*2;

    var graph_width = drawing_length/ (elements_n + (elements_n-1)/2);
   
    final Rect rect = Offset.zero & _size;
    const LinearGradient gradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        Color.fromARGB(255, 36, 26, 175),
        Color.fromARGB(255, 95, 179, 227),
        Color.fromARGB(255, 193, 173, 238),
      ],
    );
    for (int el in numbers){
      double topPosition = _size.height - (value * el * 10);

      canvas.drawRect(
      Rect.fromPoints(Offset(corner_offset, topPosition), Offset(corner_offset+graph_width, _size.height)),
      Paint()..shader = gradient.createShader(rect),
    );
    corner_offset+=(graph_width*1.5);

    }
    
    
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
  
}
 
