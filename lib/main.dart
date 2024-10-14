import 'package:flutter/material.dart';

void main() {
  runApp(const TalWare());
}

class TalWare extends StatelessWidget {
  const TalWare({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TalWare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Placeholder(),
    );
  }
}
