import 'package:bonsoir/bonsoir.dart';
import 'package:frame_app/domain/discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frame_app/data/connection_provider.dart';

class FrameDiscoveryScreen extends ConsumerWidget {
  const FrameDiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discoveryModel = ref.watch(discoveryModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Frames'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: discoveryModel.services.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Searching for Frame devices...'),
                  ],
                ),
              )
            : discoveryModel.allServices.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.devices_other, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No Frame devices found',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Make sure your devices are on the same network',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: discoveryModel.allServices.length,
                    itemBuilder: (context, index) {
                      final service = discoveryModel.allServices[index];
                      return _FrameDeviceCard(service: service);
                    },
                  ),
      ),
    );
  }
}

/// Card widget to display a discovered Frame device
class _FrameDeviceCard extends ConsumerStatefulWidget {
  final BonsoirService service;

  const _FrameDeviceCard({required this.service});

  @override
  _FrameDeviceCardState createState() => _FrameDeviceCardState();
}

class _FrameDeviceCardState extends ConsumerState<_FrameDeviceCard> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.devices),
        title: Text(widget.service.name),
        subtitle: _showDetails ? _buildDetailedInfo() : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(_showDetails ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _showDetails = !_showDetails;
                });
              },
            ),
            TextButton(
              child: const Text('CONNECT'),
              onPressed: () => _connectToService(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedInfo() {
    final StringBuffer details = StringBuffer();

    if (widget.service.attributes.isNotEmpty) {
      int count = 0;
      for (final entry in widget.service.attributes.entries) {
        if (count > 0) details.write('\n');
        details.write('${entry.key}: ${entry.value}');
        count++;
      }
    }

    return Text(details.toString());
  }

  void _connectToService(BuildContext context) {
    final discoveryModel = ref.read(discoveryModelProvider);

    if (widget.service is! ResolvedBonsoirService) {
      discoveryModel.resolveService(widget.service);
    }

    final address = widget.service.attributes['address'];
    final port = widget.service.attributes['port'];

    if (address != null && port != null) {
      ref
          .read(frameConnectionProvider.notifier)
          .setConnectionId('$address:$port');
      Navigator.of(context).pop();
    }
  }
}

// Extension to simplify access to all services
extension DiscoveryModelExtension on BonsoirDiscoveryModel {
  List<BonsoirService> get allServices {
    final List<BonsoirService> result = [];
    for (final serviceList in services.values) {
      result.addAll(serviceList);
    }
    return result..sort((a, b) => a.name.compareTo(b.name));
  }
}
