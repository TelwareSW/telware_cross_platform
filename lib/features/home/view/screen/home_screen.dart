import 'package:flutter/material.dart';
import 'package:telware_cross_platform/features/home/view/widget/drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const route = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TelWare'),
      ),
      drawer: const AppDrawer(),
      body: const Center(child: Text('home')),
    );
  }
}