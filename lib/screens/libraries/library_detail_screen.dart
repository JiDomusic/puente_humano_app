import 'package:flutter/material.dart';

class LibraryDetailScreen extends StatelessWidget {
  final String libraryId;
  
  const LibraryDetailScreen({super.key, required this.libraryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Biblioteca $libraryId')),
      body: const Center(
        child: Text('Detalle de biblioteca - En desarrollo'),
      ),
    );
  }
}