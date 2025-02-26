import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';

import 'data/connection_provider.dart';
import 'presentation/barcode_scanner_screen.dart';
import 'presentation/mdns_discovery_screen.dart';
import 'presentation/configuration_screen.dart';

void main() {
  runApp(
    ProviderScope(
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionId = ref.watch(frameConnectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Frame Companion'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          // Connection status bar
          if (connectionId != null)
            Container(
              color: Colors.green.shade100,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Connected to: $connectionId',
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: () {
                      ref
                          .read(frameConnectionProvider.notifier)
                          .clearConnection();
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  // Main action buttons
                  _buildActionButton(
                    context,
                    'Discover Frames in Network',
                    Icons.wifi_find,
                    const FrameDiscoveryScreen(),
                  ),
                  const SizedBox(height: 16),
                  _buildActionButton(
                    context,
                    connectionId == null
                        ? 'Scan QR to Connect to Frame'
                        : 'Rescan QR Code',
                    Icons.qr_code_scanner,
                    BarcodeScannerScreen(
                      onBarcodeScanned: (String? barcode) {
                        if (barcode != null) {
                          ref
                              .read(frameConnectionProvider.notifier)
                              .setConnectionId(barcode);
                        }
                      },
                    ),
                  ),

                  // Configuration button (only when connected)
                  if (connectionId != null) ...[
                    const SizedBox(height: 16),
                    _buildActionButton(
                      context,
                      'Configure Frame',
                      Icons.settings,
                      const FrameConfigurationScreen(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, String label, IconData icon, Widget page) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.of(context).push(
          SlidePageRoute(
            builder: (context) => page,
          ),
        );
      },
      icon: Icon(icon),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget Function(BuildContext) builder;

  SlidePageRoute({required this.builder})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}
