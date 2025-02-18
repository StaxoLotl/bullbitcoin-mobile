import 'package:bb_mobile/app_locator.dart';
import 'package:bb_mobile/core/data/datasources/exchange_data_source.dart';
import 'package:bb_mobile/core/data/datasources/impl/bull_bitcoin_exchange_datasource_impl.dart';
import 'package:bb_mobile/core/data/datasources/impl/hive_storage_datasource_impl.dart';
import 'package:bb_mobile/core/data/datasources/impl/secure_storage_data_source_impl.dart';
import 'package:bb_mobile/core/data/datasources/key_value_storage_data_source.dart';
import 'package:bb_mobile/core/data/repositories/seed_repository_impl.dart';
import 'package:bb_mobile/core/data/repositories/wallet_metadata_repository_impl.dart';
import 'package:bb_mobile/core/domain/repositories/seed_repository.dart';
import 'package:bb_mobile/core/domain/repositories/wallet_metadata_repository.dart';
import 'package:bb_mobile/core/domain/services/wallet_derivation_service.dart';
import 'package:bb_mobile/core/domain/services/wallet_repository_manager.dart';
import 'package:bb_mobile/core/domain/usecases/get_default_wallets_metadata_usecase.dart';
import 'package:bb_mobile/core/domain/usecases/get_wallet_balance_sat_usecase.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

class CoreLocator {
  static const String secureStorageInstanceName = 'secureStorage';
  static const String hiveSettingsBoxName = 'settings';
  static const String settingsStorageInstanceName = 'settingsStorage';
  static const String bullBitcoinExchangeInstanceName = 'bullBitcoinExchange';
  static const String hiveWalletsBoxName = 'wallets';
  static const String walletsStorageInstanceName = 'walletsStorage';

  static Future<void> setup() async {
    // Data sources
    locator.registerLazySingleton<KeyValueStorageDataSource<String>>(
      () => SecureStorageDataSourceImpl(
        const FlutterSecureStorage(),
      ),
      instanceName: secureStorageInstanceName,
    );
    final settingsBox = await Hive.openBox<String>(hiveSettingsBoxName);
    locator.registerLazySingleton<KeyValueStorageDataSource<String>>(
      () => HiveStorageDataSourceImpl<String>(settingsBox),
      instanceName: settingsStorageInstanceName,
    );
    locator.registerLazySingleton<ExchangeDataSource>(
      () => BullBitcoinExchangeDataSourceImpl(),
      instanceName: bullBitcoinExchangeInstanceName,
    );

    final walletsBox = await Hive.openBox<String>(hiveWalletsBoxName);
    locator.registerLazySingleton<KeyValueStorageDataSource<String>>(
      () => HiveStorageDataSourceImpl<String>(walletsBox),
      instanceName: walletsStorageInstanceName,
    );

    // Repositories
    locator.registerLazySingleton<WalletMetadataRepository>(
      () => HiveWalletMetadataRepositoryImpl(
        locator<KeyValueStorageDataSource<String>>(
          instanceName: walletsStorageInstanceName,
        ),
      ),
    );
    locator.registerLazySingleton<SeedRepository>(
      () => SeedRepositoryImpl(
        locator<KeyValueStorageDataSource<String>>(
          instanceName: secureStorageInstanceName,
        ),
      ),
    );

    // Managers or services responsible for handling specific logic
    locator.registerLazySingleton<WalletDerivationService>(
      () => const WalletDerivationServiceImpl(),
    );
    locator.registerLazySingleton<WalletRepositoryManager>(
      () => WalletRepositoryManagerImpl(),
    );

    // Use cases
    locator.registerFactory<GetDefaultWalletsMetadataUseCase>(
      () => GetDefaultWalletsMetadataUseCase(
        walletMetadataRepository: locator<WalletMetadataRepository>(),
      ),
    );
    locator.registerFactory<GetWalletBalanceSatUseCase>(
      () => GetWalletBalanceSatUseCase(
        walletRepositoryManager: locator<WalletRepositoryManager>(),
      ),
    );
  }
}
