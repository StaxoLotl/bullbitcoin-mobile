import 'package:bb_mobile/_core/domain/repositories/settings_repository.dart';
import 'package:bb_mobile/_core/domain/repositories/wallet_manager_repository.dart';
import 'package:bb_mobile/_core/domain/services/mnemonic_seed_factory.dart';
import 'package:bb_mobile/app_startup/domain/usecases/check_for_existing_default_wallets_usecase.dart';
import 'package:bb_mobile/app_startup/domain/usecases/create_default_wallets_usecase.dart';
import 'package:bb_mobile/app_startup/domain/usecases/init_wallets_usecase.dart';
import 'package:bb_mobile/app_startup/domain/usecases/reset_app_data_usecase.dart';
import 'package:bb_mobile/app_startup/presentation/bloc/app_startup_bloc.dart';
import 'package:bb_mobile/app_unlock/domain/usecases/check_pin_code_exists_usecase.dart';
import 'package:bb_mobile/locator.dart';
import 'package:bb_mobile/pin_code/domain/repositories/pin_code_repository.dart';

class AppStartupLocator {
  static void setup() {
    // Use cases
    locator.registerFactory<ResetAppDataUseCase>(
      () => ResetAppDataUseCase(
        pinCodeRepository: locator<PinCodeRepository>(),
      ),
    );
    locator.registerFactory<CheckForExistingDefaultWalletsUseCase>(
      () => CheckForExistingDefaultWalletsUseCase(
        walletManager: locator<WalletManagerRepository>(),
        settingsRepository: locator<SettingsRepository>(),
      ),
    );
    locator.registerFactory<InitExistingWalletsUseCase>(
      () => InitExistingWalletsUseCase(
        walletManager: locator<WalletManagerRepository>(),
      ),
    );
    // Use cases
    locator.registerFactory<CreateDefaultWalletsUseCase>(
      () => CreateDefaultWalletsUseCase(
        settingsRepository: locator<SettingsRepository>(),
        mnemonicSeedFactory: locator<MnemonicSeedFactory>(),
        walletManager: locator<WalletManagerRepository>(),
      ),
    );

    // Bloc
    locator.registerFactory<AppStartupBloc>(
      () => AppStartupBloc(
        resetAppDataUseCase: locator<ResetAppDataUseCase>(),
        checkPinCodeExistsUseCase: locator<CheckPinCodeExistsUseCase>(),
        checkForExistingDefaultWalletsUseCase:
            locator<CheckForExistingDefaultWalletsUseCase>(),
        initExistingWalletsUseCase: locator<InitExistingWalletsUseCase>(),
        createDefaultWalletsUseCase: locator<CreateDefaultWalletsUseCase>(),
      ),
    );
  }
}
