import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animal Counter App',
      debugShowCheckedModeBanner: false, // Disable debug banner
      theme: ThemeData.dark(),
      home: AnimalCounter(),
    );
  }
}

class AnimalCounter extends StatefulWidget {
  const AnimalCounter({super.key});

  @override
  _AnimalCounterState createState() => _AnimalCounterState();
}

class _AnimalCounterState extends State<AnimalCounter> {
  int _count = 0;
  StreamSubscription? _accelerometerSubscription;
  DateTime _lastShakeTime = DateTime.now();
  double opacity = 1.0;

   void animateCountChange(Function updateCount) {
    setState(() => opacity = 0.0); // se desvanece
    Future.delayed(Duration(milliseconds: 500), () {
      updateCount();
      setState(() => opacity = 1.0); // vuelve a aparecer
    });
  }

  void increment() => animateCountChange(() => _count++);
  void decrement() => animateCountChange(() => _count--);
  void reset() => animateCountChange(() => _count = 0);
  

  @override
  void initState() {
    super.initState();

    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      final x = event.x;
      final y = event.y;
      final z = event.z;

      // Calculate total acceleration
      final acceleration = sqrt(x * x + y * y + z * z);

      // Shake threshold
      if (acceleration > 12.0) {
        final now = DateTime.now();
        final difference = now.difference(_lastShakeTime);

        if (difference.inMilliseconds > 1000) {
          // At least 1 second passed since last shake
          setState(() {
            _count+=10; // Increment count by 10
          });
          _lastShakeTime = now;
        }
      }
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contador', style: TextStyle(fontSize: 10)
      ),
      centerTitle: true, // Center the title
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
      child: SingleChildScrollView(
       child:Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Animales Contados:', style: TextStyle(fontSize: 8)),
            AnimatedOpacity(
              duration: Duration(milliseconds: 200),
              opacity: opacity,
               child: Text(
                '$_count',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 243, 2, 2)),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: Icon(Icons.remove), onPressed: decrement),
                IconButton(icon: Icon(Icons.refresh), onPressed: reset),
                IconButton(icon: Icon(Icons.add), onPressed: increment),
              ]
              ),
          ]
        ),
      ),
      )
      ),
    );
  }
}
