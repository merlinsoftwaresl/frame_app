import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'barcode_scanner.dart';
import 'providers/frame_connection_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
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

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  Widget _buildItem(BuildContext context, WidgetRef ref, String label, Widget page) {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionId = ref.watch(frameConnectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Frame App'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          // Connection status bar
          if (connectionId != null)
            Container(
              color: Colors.green.withOpacity(0.1),
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Connected to: ${connectionId}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      ref.read(frameConnectionProvider.notifier).clearConnection();
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView(
              children: [
                _buildItem(
                  context,
                  ref,
                  connectionId == null 
                      ? 'Scan QR to connect to frame'
                      : 'Rescan QR code',
                  BarcodeScanner(
                    onBarcodeScanned: (String? barcode) {
                      if (barcode != null) {
                        ref.read(frameConnectionProvider.notifier).setConnectionId(barcode);
                      }
                    },
                  ),
                ),
                if (connectionId != null) ...[
                  // Add more buttons/features that are only available when connected
                  _buildItem(
                    context,
                    ref,
                    'Configure Frame',
                    const Placeholder(), // TODO: Implement configuration screen
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
