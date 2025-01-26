import 'package:bb_mobile/core/data/datasources/key_value_storage_data_source.dart';
import 'package:bb_mobile/features/pin_code/domain/repositories/pin_code_repository.dart';

class PinCodeRepositoryImpl implements PinCodeRepository {
  final KeyValueStorageDataSource<String> _storage;

  static const _key = 'securityKey'; // Use same key as in AuthCubit
  static const _failedUnlockAttemptsKey = 'failedUnlockAttemptsKey';

  PinCodeRepositoryImpl(this._storage);

  @override
  Future<bool> isPinCodeSet() async {
    final pin = await _storage.getValue(_key);

    return pin != null;
  }

  @override
  Future<void> setPinCode(String pinCode) async {
    await _storage.saveValue(key: _key, value: pinCode);
  }

  @override
  Future<bool> verifyPinCode(String pinCode) async {
    final pin = await _storage.getValue(_key);

    if (pin == null) {
      throw PinCodeNotSetException(
        message: 'Pin code is not set. Use create method to set it.',
      );
    }

    return pin == pinCode;
  }

  @override
  Future<void> setFailedUnlockAttempts(int attempts) async {
    await _storage.saveValue(
      key: _failedUnlockAttemptsKey,
      value: attempts.toString(),
    );
  }

  @override
  Future<int> getFailedUnlockAttempts() async {
    final timeout = await _storage.getValue(_failedUnlockAttemptsKey);

    return int.tryParse(timeout ?? '0') ?? 0;
  }
}

class PinCodeNotSetException implements Exception {
  final String message;

  PinCodeNotSetException({required this.message});
}

class InvalidPinCodeException implements Exception {
  final String message;

  InvalidPinCodeException({required this.message});
}
