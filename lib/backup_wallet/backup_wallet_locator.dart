import 'package:bb_mobile/_core/domain/repositories/recoverbull_repository.dart';
import 'package:bb_mobile/_core/domain/usecases/get_default_wallet_use_case.dart';
import 'package:bb_mobile/backup_wallet/domain/usecases/create_encrypted_backup_usecase.dart';
import 'package:bb_mobile/backup_wallet/presentation/bloc/backup_wallet_bloc.dart';
import 'package:bb_mobile/locator.dart';

class BackupWalletLocator {
  static void setup() {
    // Use cases
    locator.registerFactory<CreateEncryptedBackupUsecase>(
      () => CreateEncryptedBackupUsecase(
        recoverBullRepository: locator<RecoverBullRepository>(),
      ),
    );

    // Blocs
    locator.registerFactory<BackupWalletBloc>(
      () => BackupWalletBloc(
        createEncryptedBackupUsecase: locator<CreateEncryptedBackupUsecase>(),
        getDefaultWalletUseCase: locator<GetDefaultWalletUseCase>(),
      ),
    );
  }
}
