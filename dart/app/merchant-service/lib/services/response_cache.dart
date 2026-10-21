import 'dart:async';
import 'dart:convert';

import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:redis/redis.dart';

/// Best-effort Redis cache used by the merchant API gateway.
class ResponseCache {
  static RedisConnection? _connection;
  static Command? _command;
  static Future<Command>? _connecting;

  static Future<ServiceCacheEntry?> get(String key) async {
    try {
      final value = await (await _client()).send_object(['GET', key]);
      if (value is! String) return null;
      final decoded = jsonDecode(value) as Map<String, dynamic>;
      return ServiceCacheEntry(decoded['status'] as int, decoded['body']);
    } catch (_) {
      await _reset();
      return null;
    }
  }

  static Future<void> set(String key, int status, dynamic body) async {
    try {
      final env = dotenv.DotEnv(includePlatformEnvironment: true)..load();
      final ttl = int.tryParse(env['REDIS_CACHE_TTL_SECONDS'] ?? '') ?? 60;
      await (await _client()).send_object([
        'SET',
        key,
        jsonEncode({'status': status, 'body': body}),
        'EX',
        ttl,
      ]);
    } catch (_) {
      await _reset();
    }
  }

  static Future<int> version(String service) async {
    try {
      final value = await (await _client()).send_object([
        'GET',
        'gateway:$service:version',
      ]);
      return int.tryParse(value?.toString() ?? '') ?? 0;
    } catch (_) {
      await _reset();
      return 0;
    }
  }

  static Future<void> invalidate(String service) async {
    try {
      await (await _client()).send_object(['INCR', 'gateway:$service:version']);
    } catch (_) {
      await _reset();
    }
  }

  static Future<Command> _client() async {
    if (_command != null) return _command!;
    return _connecting ??= _connect();
  }

  static Future<Command> _connect() async {
    final env = dotenv.DotEnv(includePlatformEnvironment: true)..load();
    final uri = Uri.parse(env['REDIS_URL'] ?? 'redis://localhost:6379');
    final connection = RedisConnection();
    try {
      final command =
          await (uri.scheme == 'rediss'
                  ? connection.connectSecure(
                      uri.host,
                      uri.hasPort ? uri.port : 6379,
                    )
                  : connection.connect(uri.host, uri.hasPort ? uri.port : 6379))
              .timeout(const Duration(seconds: 2));
      if (uri.userInfo.isNotEmpty) {
        final parts = uri.userInfo.split(':');
        if (parts.length > 1 && parts.first.isNotEmpty) {
          await command.send_object(['AUTH', parts.first, parts.last]);
        } else {
          await command.send_object(['AUTH', parts.last]);
        }
      }
      final database = int.tryParse(uri.pathSegments.firstOrNull ?? '');
      if (database != null && database > 0) {
        await command.send_object(['SELECT', database]);
      }
      _connection = connection;
      return _command = command;
    } finally {
      _connecting = null;
    }
  }

  static Future<void> _reset() async {
    await _connection?.close();
    _connection = null;
    _command = null;
    _connecting = null;
  }
}

class ServiceCacheEntry {
  const ServiceCacheEntry(this.statusCode, this.body);

  final int statusCode;
  final dynamic body;
}
