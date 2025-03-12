part of 'recover_wallet_bloc.dart';

sealed class RecoverWalletEvent {
  const RecoverWalletEvent();
}

class RecoverWalletWordsCountChanged extends RecoverWalletEvent {
  final int wordsCount;

  const RecoverWalletWordsCountChanged({required this.wordsCount});
}

class RecoverWalletWordChanged extends RecoverWalletEvent {
  final int index;
  final String word;

  const RecoverWalletWordChanged({
    required this.index,
    required this.word,
  });
}

class RecoverWalletPassphraseChanged extends RecoverWalletEvent {
  final String passphrase;

  const RecoverWalletPassphraseChanged(this.passphrase);
}

class RecoverWalletLabelChanged extends RecoverWalletEvent {
  final String label;

  const RecoverWalletLabelChanged(this.label);
}

class RecoverWalletScriptTypeChanged extends RecoverWalletEvent {
  final ScriptType scriptType;

  const RecoverWalletScriptTypeChanged(this.scriptType);
}

class RecoverWalletConfirmed extends RecoverWalletEvent {
  const RecoverWalletConfirmed();
}

class RecoverFromOnboarding extends RecoverWalletEvent {
  const RecoverFromOnboarding();
}
