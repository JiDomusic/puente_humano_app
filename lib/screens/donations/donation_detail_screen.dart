import 'package:flutter/material.dart';

class DonationDetailScreen extends StatelessWidget {
  final String donationId;
  
  const DonationDetailScreen({super.key, required this.donationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Donación $donationId')),
      body: const Center(
        child: Text('Detalle de donación - En desarrollo'),
      ),
    );
  }
}