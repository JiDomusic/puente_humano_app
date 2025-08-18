import 'package:flutter/material.dart';

class TripDetailScreen extends StatelessWidget {
  final String tripId;
  
  const TripDetailScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Viaje $tripId')),
      body: const Center(
        child: Text('Detalle del viaje - En desarrollo'),
      ),
    );
  }
}