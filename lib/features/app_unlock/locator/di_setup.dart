import 'package:bb_mobile/core/data/datasources/key_value_storage_data_source.dart';
import 'package:bb_mobile/core/locator/di_initializer.dart';
import 'package:bb_mobile/features/app_unlock/data/repositories/failed_unlock_attempts_repository_impl.dart';
import 'package:bb_mobile/features/app_unlock/domain/repositories/failed_unlock_attempts_repository.dart';
import 'package:bb_mobile/features/app_unlock/domain/services/timeout_calculator.dart';
import 'package:bb_mobile/features/app_unlock/domain/usecases/attempt_unlock_with_pin_code_usecase.dart';
import 'package:bb_mobile/features/app_unlock/domain/usecases/get_latest_unlock_attempt_usecase.dart';
import 'package:bb_mobile/features/app_unlock/presentation/bloc/app_unlock_bloc.dart';
import 'package:bb_mobile/features/pin_code/domain/repositories/pin_code_repository.dart';
import 'package:bb_mobile/features/pin_code/domain/usecases/check_pin_code_exists_usecase.dart';

void setupAppUnlockDependencies() {
  // Repositories
  locator.registerLazySingleton<FailedUnlockAttemptsRepository>(
    () => FailedUnlockAttemptsRepositoryImpl(
      locator<KeyValueStorageDataSource<String>>(
        instanceName: secureStorageInstanceName,
      ),
    ),
  );

  // Services
  locator.registerLazySingleton<TimeoutCalculator>(
    () => ExponentialTimeoutCalculator(),
  );

  // Use cases
  locator.registerFactory<GetLatestUnlockAttemptUseCase>(
    () => GetLatestUnlockAttemptUseCase(
      failedUnlockAttemptsRepository: locator<FailedUnlockAttemptsRepository>(),
      timeoutCalculator: locator<TimeoutCalculator>(),
    ),
  );
  locator.registerFactory<AttemptUnlockWithPinCodeUseCase>(
    () => AttemptUnlockWithPinCodeUseCase(
      failedUnlockAttemptsRepository: locator<FailedUnlockAttemptsRepository>(),
      pinCodeRepository: locator<PinCodeRepository>(),
      timeoutCalculator: locator<TimeoutCalculator>(),
    ),
  );

  // Blocs
  locator.registerFactory<AppUnlockBloc>(
    () => AppUnlockBloc(
      checkPinCodeExistsUsecase: locator<CheckPinCodeExistsUsecase>(),
      getLatestUnlockAttemptUseCase: locator<GetLatestUnlockAttemptUseCase>(),
      attemptUnlockWithPinCodeUseCase:
          locator<AttemptUnlockWithPinCodeUseCase>(),
    ),
  );
}
