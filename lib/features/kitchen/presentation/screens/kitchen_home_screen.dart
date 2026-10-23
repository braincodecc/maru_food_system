import 'package:flutter/material.dart';

class KitchenHomeScreen extends StatelessWidget {
  const KitchenHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kitchen Home')),
      body: const Center(child: Text('Welcome to the Kitchen Home!')),
    );
  }
}
