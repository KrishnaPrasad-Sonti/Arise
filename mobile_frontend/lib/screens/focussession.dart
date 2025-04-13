import 'dart:async';
import 'package:flutter/material.dart';


class FocusTimerApp extends StatefulWidget {
  const FocusTimerApp({super.key});

  @override
  FocusTimerScreenState createState() => FocusTimerScreenState();
}

class FocusTimerScreenState extends State<FocusTimerApp> {
  final List<int> _timers = [1, 5, 30];
  final List<Timer?> _runningTimers = [];
  final List<int> _remainingTimes = [];

  @override
  void initState() {
    super.initState();
    _remainingTimes.addAll(_timers.map((e) => e * 60));
    _runningTimers.addAll(List.filled(_timers.length, null));
  }

  void _startTimer(int index) {
    if (_runningTimers[index] != null) return;

    _runningTimers[index] = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTimes[index] > 0) {
          _remainingTimes[index]--;
        } else {
          _runningTimers[index]?.cancel();
          _runningTimers[index] = null;
        }
      });
    });
  }

  void _resetTimer(int index) {
    _runningTimers[index]?.cancel();
    setState(() {
      _remainingTimes[index] = _timers[index] * 60;
      _runningTimers[index] = null;
    });
  }

  void _addTimer(int minutes) {
    setState(() {
      _timers.add(minutes);
      _remainingTimes.add(minutes * 60);
      _runningTimers.add(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("  Focus Sessions"),
          foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 80, 0, 115),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
     body: Column(
      
  children: [
    SizedBox(height: 16.0),
    Expanded(
      child: SingleChildScrollView(
        child: GridView.builder(
          shrinkWrap: true, // Prevent overflow
          physics: const NeverScrollableScrollPhysics(), // Avoid double scrolling
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 timers per row
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.9, // Adjust to fit content better
          ),
          itemCount: _timers.length,
          itemBuilder: (context, index) {
            return _buildTimerCard(index);
          },
        ),
      ),
    ),
   Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24.0), // Move button up
        child: ElevatedButton(
          onPressed: () {
            _showAddTimerDialog();
          },
          child: const Text("Add Timer"),
        ),),)
  ],
),


    );
  }

  Widget _buildTimerCard(int index) {
    int minutes = _remainingTimes[index] ~/ 60;
    int seconds = _remainingTimes[index] % 60;
    double progress = _remainingTimes[index] / (_timers[index] * 60);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () => _startTimer(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.stop),
                        onPressed: () => _resetTimer(index),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddTimerDialog() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Timer"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Minutes"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              int? minutes = int.tryParse(controller.text);
              if (minutes != null && minutes > 0) {
                _addTimer(minutes);
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}