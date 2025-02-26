import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final frameApiServiceProvider = Provider((ref) => FrameApiService());

class FrameApiService {
  final Dio _dio = Dio();
  
  Future<Either<String, bool>> configureServerAddress({
    required String frameId,
    required String serverAddress,
    required String serverPort,
  }) async {
    try {
      final response = await _dio.post(
        'http://$frameId/configure_address',
        data: '$serverAddress:$serverPort',
      );
      
      if (response.statusCode == 200) {
        return right(true);
      }
      return left('Failed to configure server address: ${response.statusCode}');
    } catch (e) {
      return left('Error configuring server address: $e');
    }
  }

  Future<Either<String, bool>> configureDelay({
    required String frameId,
    required int delaySeconds,
  }) async {
    try {
      final response = await _dio.post(
        'http://$frameId/configure_delay',
        data: delaySeconds.toString(),
      );
      
      if (response.statusCode == 200) {
        return right(true);
      }
      return left('Failed to configure delay: ${response.statusCode}');
    } catch (e) {
      return left('Error configuring delay: $e');
    }
  }
} 