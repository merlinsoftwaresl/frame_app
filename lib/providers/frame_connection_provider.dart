import 'package:flutter_riverpod/flutter_riverpod.dart';

final frameConnectionProvider = StateNotifierProvider<FrameConnectionNotifier, String?>((ref) {
  return FrameConnectionNotifier();
});

class FrameConnectionNotifier extends StateNotifier<String?> {
  FrameConnectionNotifier() : super(null);

  void setConnectionId(String? id) {
    state = id;
  }

  void clearConnection() {
    state = null;
  }
} 