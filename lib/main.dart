import 'package:flutter/material.dart';
import 'barcode_scanner.dart';

String? frameConnectionID;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frame App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});
  Widget _buildItem(BuildContext context, String label, Widget page) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => page,
              ),
            );
          },
          child: Text(label),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Frame App: $frameConnectionID')),
      body: Center(
        child: ListView(
          children: [
            _buildItem(
              context,
              'Scan QR to connect to frame',
              BarcodeScanner(onBarcodeScanned: (barcode) {
                frameConnectionID = barcode;
                print('Scanned Barcode: $frameConnectionID');
              }),
            ),
          ],
        ),
      ),
    );
  }
}
