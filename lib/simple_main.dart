import 'package:flutter/material.dart';

void main() {
  runApp(SimpleApp());
}

class SimpleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Simple',
      home: Scaffold(
        appBar: AppBar(title: Text('Test')),
        body: Center(child: Text('App funciona!')),
      ),
    );
  }
}