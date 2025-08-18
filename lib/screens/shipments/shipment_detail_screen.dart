import 'package:flutter/material.dart';

class ShipmentDetailScreen extends StatelessWidget {
  final String shipmentId;
  
  const ShipmentDetailScreen({super.key, required this.shipmentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Envío $shipmentId')),
      body: const Center(
        child: Text('Detalle de envío - En desarrollo'),
      ),
    );
  }
}