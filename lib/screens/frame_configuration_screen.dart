import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/frame_connection_provider.dart';
import '../services/frame_api_service.dart';

class FrameConfigurationScreen extends ConsumerStatefulWidget {
  const FrameConfigurationScreen({super.key});

  @override
  ConsumerState<FrameConfigurationScreen> createState() => _FrameConfigurationScreenState();
}

class _FrameConfigurationScreenState extends ConsumerState<FrameConfigurationScreen> {
  final _serverFormKey = GlobalKey<FormState>();
  final _delayFormKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _portController = TextEditingController();
  final _delayController = TextEditingController();
  bool _isLoadingServer = false;
  bool _isLoadingDelay = false;
  String? _errorMessage;

  @override
  void dispose() {
    _addressController.dispose();
    _portController.dispose();
    _delayController.dispose();
    super.dispose();
  }

  Future<void> _submitServerConfiguration() async {
    if (!_serverFormKey.currentState!.validate()) return;

    setState(() {
      _isLoadingServer = true;
      _errorMessage = null;
    });

    final frameId = ref.read(frameConnectionProvider);
    if (frameId == null) {
      setState(() {
        _errorMessage = 'No frame connected';
        _isLoadingServer = false;
      });
      return;
    }

    final result = await ref.read(frameApiServiceProvider).configureServerAddress(
          frameId: frameId,
          serverAddress: _addressController.text,
          serverPort: _portController.text,
        );

    setState(() {
      _isLoadingServer = false;
    });

    result.fold(
      (error) {
        setState(() => _errorMessage = error);
      },
      (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Server address updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  Future<void> _submitDelayConfiguration() async {
    if (!_delayFormKey.currentState!.validate()) return;

    setState(() {
      _isLoadingDelay = true;
      _errorMessage = null;
    });

    final frameId = ref.read(frameConnectionProvider);
    if (frameId == null) {
      setState(() {
        _errorMessage = 'No frame connected';
        _isLoadingDelay = false;
      });
      return;
    }

    final delay = int.parse(_delayController.text);
    final result = await ref.read(frameApiServiceProvider).configureDelay(
          frameId: frameId,
          delaySeconds: delay,
        );

    setState(() {
      _isLoadingDelay = false;
    });

    result.fold(
      (error) {
        setState(() => _errorMessage = error);
      },
      (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Picture delay updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frame Configuration'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _serverFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Server Configuration',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Server Address',
                          hintText: 'e.g., 192.168.1.100',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter server address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _portController,
                        decoration: const InputDecoration(
                          labelText: 'Server Port',
                          hintText: 'e.g., 8080',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter server port';
                          }
                          final port = int.tryParse(value);
                          if (port == null || port <= 0 || port > 65535) {
                            return 'Please enter a valid port number (1-65535)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoadingServer ? null : _submitServerConfiguration,
                        child: _isLoadingServer
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Update Server Configuration'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _delayFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Picture Delay Configuration',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _delayController,
                        decoration: const InputDecoration(
                          labelText: 'Delay (seconds)',
                          hintText: 'e.g., 30',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter delay in seconds';
                          }
                          final delay = int.tryParse(value);
                          if (delay == null || delay <= 0) {
                            return 'Please enter a valid delay in seconds';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoadingDelay ? null : _submitDelayConfiguration,
                        child: _isLoadingDelay
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Update Picture Delay'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 