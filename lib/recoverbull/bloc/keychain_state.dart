import 'package:bb_mobile/_pkg/consts/passwords.dart';
import 'package:bb_mobile/recoverbull/bloc/keychain_cubit.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'keychain_state.freezed.dart';

enum KeyChainPageState {
  enter,
  confirm,
  recovery,
  download,
  delete;

  static KeyChainPageState fromString(String value) {
    return KeyChainPageState.values.firstWhere(
      (element) => element.name.toLowerCase() == value.toLowerCase(),
      orElse: () => KeyChainPageState.enter,
    );
  }
}

enum KeyChainInputType { pin, password, backupKey }

enum KeySecretState { none, saved, recovered, deleted }

@freezed
class KeychainState with _$KeychainState {
  const factory KeychainState({
    @Default(false) bool loading,
    @Default(true) bool keyServerUp,
    @Default(KeyChainPageState.enter) KeyChainPageState pageState,
    @Default(KeyChainInputType.pin) KeyChainInputType inputType,
    @Default(KeySecretState.none) KeySecretState keySecretState,
    @Default('') String secret,
    @Default('') String tempSecret,
    @Default(false) bool obscure,
    @Default('') String backupId,
    @Default('') String backupKey,
    @Default([]) List<int> backupSalt,
    @Default(false) bool isSecretConfirmed,
    @Default('') String error,
    @Default(KeyChainPageState.enter) KeyChainPageState originalPageState,
    DateTime? lastRequestTime,
    int? cooldownMinutes,
  }) = _KeychainState;

  const KeychainState._();

  String displayPin() => 'x' * secret.length;

  String? getValidationError() {
    // Skip validation during recovery, delete or download
    if (pageState == KeyChainPageState.recovery ||
        pageState == KeyChainPageState.download ||
        pageState == KeyChainPageState.delete) {
      return null;
    }

    if (secret.isEmpty) return null;

    if (inputType == KeyChainInputType.pin) {
      const pinMin = KeychainCubit.pinMin;
      const pinMax = KeychainCubit.pinMax;

      if (!RegExp('^[0-9]{$pinMin,$pinMax}\$').hasMatch(secret)) {
        return secret.length < pinMin
            ? 'PIN must be at least $pinMin digits long'
            : 'Switch to password if you want more than $pinMax digits';
      }
    }

    return validateSecret(secret)
        ? 'The password is among the top 1000 most common'
        : null;
  }

  bool get isValid => getValidationError() == null;

  bool get hasError => error.isNotEmpty;
  bool get isRecovering => pageState == KeyChainPageState.recovery;
  bool get canStoreKey => isValid && keyServerUp && !loading;
  bool get canRecoverKey => backupId.isNotEmpty && keyServerUp && !loading;
  bool get canRecoverWithBckupKey => backupId.isNotEmpty && !loading;
  bool get canDeleteKey => backupId.isNotEmpty && keyServerUp && !loading;
  bool validateSecret(String secret) => commonPasswordsTop1000.contains(secret);

  bool get isInCooldown {
    if (lastRequestTime == null || cooldownMinutes == null) return false;
    final cooldownEnd =
        lastRequestTime!.add(Duration(minutes: cooldownMinutes!));
    return DateTime.now().isBefore(cooldownEnd);
  }

  int? get remainingCooldownSeconds {
    if (!isInCooldown) return null;
    final cooldownEnd =
        lastRequestTime!.add(Duration(minutes: cooldownMinutes!));
    return cooldownEnd.difference(DateTime.now()).inSeconds;
  }
}
