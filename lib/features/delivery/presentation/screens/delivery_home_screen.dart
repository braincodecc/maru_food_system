import 'package:flutter/material.dart';

class DeliveryHomeScreen extends StatelessWidget {
  const DeliveryHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Home')),

      body: const Center(child: Text('Welcome to the Delivery Home!')),
    );
  }
}
