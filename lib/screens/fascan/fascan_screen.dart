import 'package:flutter/material.dart';

class FascanScreen extends StatelessWidget {
  const FascanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Plant')),
      body: const Center(
        child: Text('Fascan Screen'),
      ),
    );
  }
}
