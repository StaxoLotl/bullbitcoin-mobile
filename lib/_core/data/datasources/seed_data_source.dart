import 'dart:convert';

import 'package:bb_mobile/_core/data/datasources/key_value_stores/key_value_storage_data_source.dart';
import 'package:bb_mobile/_core/data/models/seed_model.dart';
import 'package:bb_mobile/_utils/constants.dart';

abstract class SeedDataSource {
  Future<void> store({
    required String fingerprint,
    required SeedModel seed,
  });
  Future<SeedModel> get(String fingerprint);
  Future<bool> exists(String fingerprint);
  Future<void> delete(String fingerprint);
}

class SeedDataSourceImpl implements SeedDataSource {
  final KeyValueStorageDataSource<String> _secureStorage;

  const SeedDataSourceImpl({
    required KeyValueStorageDataSource<String> secureStorage,
  }) : _secureStorage = secureStorage;

  @override
  Future<void> store({required String fingerprint, required SeedModel seed}) {
    final key = _seedKey(fingerprint);
    final value = jsonEncode(seed.toJson());
    return _secureStorage.saveValue(key: key, value: value);
  }

  @override
  Future<SeedModel> get(String fingerprint) async {
    final key = _seedKey(fingerprint);
    final value = await _secureStorage.getValue(key);
    if (value == null) {
      throw SeedNotFoundException(
        'Seed not found for fingerprint: $fingerprint',
      );
    }

    final json = jsonDecode(value) as Map<String, dynamic>;
    final seed = SeedModel.fromJson(json);

    return seed;
  }

  @override
  Future<bool> exists(String fingerprint) {
    final key = _seedKey(fingerprint);
    return _secureStorage.hasValue(key);
  }

  @override
  Future<void> delete(String fingerprint) {
    final key = _seedKey(fingerprint);
    return _secureStorage.deleteValue(key);
  }

  String _seedKey(String fingerprint) =>
      '${SecureStorageKeyPrefixConstants.seed}$fingerprint';
}

class SeedNotFoundException implements Exception {
  final String message;

  const SeedNotFoundException(this.message);
}
