import 'dart:async';

import 'package:bonsoir/bonsoir.dart';
import 'package:frame_app/domain/bonsoir_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The model provider.
final discoveryModelProvider =
    ChangeNotifierProvider<BonsoirDiscoveryModel>((ref) {
  BonsoirDiscoveryModel model = BonsoirDiscoveryModel();
  model.start('frame-client');
  return model;
});

/// Provider model that allows to handle Bonsoir discoveries.
class BonsoirDiscoveryModel extends BonsoirActionModel<String, BonsoirDiscovery,
    BonsoirDiscoveryEvent> {
  /// A map containing all discovered services.
  final Map<String, List<BonsoirService>> _services = {};

  @override
  BonsoirDiscovery createAction(String argument) {
    return BonsoirDiscovery(type: normalizeServiceType(argument));
  }

  @override
  Future<void> start(String argument, {bool notify = true}) async {
    try {
      String normalizedType = normalizeServiceType(argument);
      _services[normalizedType] ??= [];
      await super.start(argument, notify: notify);
      print(
          'Started discovery for service type: $argument (normalized: $normalizedType)');
    } catch (e) {
      print('Error starting discovery: $e');
    }
  }

  /// Returns the services map.
  Map<String, List<BonsoirService>> get services => Map.from(_services);

  @override
  void onEventOccurred(BonsoirDiscoveryEvent event) {
    print('Discovery event: ${event.type}');
    if (event.service == null) {
      print('Event service is null');
      return;
    }

    BonsoirService service = event.service!;
    print('Service found: ${service.name} of type ${service.type}');

    // The issue is here - service.type might not be in _services map
    // Initialize the list if it doesn't exist
    _services[service.type] ??= [];

    List<BonsoirService> services = _services[service.type]!;
    if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
      services.add(service);
    } else if (event.type ==
        BonsoirDiscoveryEventType.discoveryServiceResolved) {
      services.removeWhere((foundService) => foundService.name == service.name);
      services.add(service);
    } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
      services.removeWhere((foundService) => foundService.name == service.name);
    }
    services.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  @override
  Future<void> stop(String argument, {bool notify = true}) async {
    await super.stop(argument, notify: false);
    _services.remove(argument);
    if (notify) {
      notifyListeners();
    }
  }

  /// Resolves the given service.
  void resolveService(BonsoirService service) {
    BonsoirDiscovery? discovery = getAction(service.type);
    if (discovery != null) {
      service.resolve(discovery.serviceResolver);
    }
  }

  String normalizeServiceType(String type) {
    String serviceType = type;
    if (!serviceType.startsWith('_')) {
      serviceType = '_$serviceType';
    }
    if (!serviceType.contains('._')) {
      serviceType = '$serviceType._tcp';
    }
    return serviceType;
  }
}
