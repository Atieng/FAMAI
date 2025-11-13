import 'package:flutter/material.dart';

class FamateScreen extends StatelessWidget {
  const FamateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Famate - Climate & Weather'),
      ),
      body: const Center(
        child: Text('Weather information will be displayed here.'),
      ),
    );
  }
}
