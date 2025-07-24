import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AnimalCounter(),
    );
  }
}

class AnimalCounter extends StatefulWidget {
  @override
  _AnimalCounterState createState() => _AnimalCounterState();
}

class _AnimalCounterState extends State<AnimalCounter> {
  int _count = 0;
  StreamSubscription? _accelerometerSubscription;
  DateTime _lastShakeTime = DateTime.now();

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
            _count++;
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
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          '$_count',
          style: TextStyle(fontSize: 64, color: Colors.green),
        ),
      ),
    );
  }
}
