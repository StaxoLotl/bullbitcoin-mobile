import 'package:bb_mobile/_core/data/datasources/bip32_data_source.dart';
import 'package:bb_mobile/_core/data/datasources/bip39_word_list_data_source.dart';
import 'package:bb_mobile/_core/data/datasources/boltz_data_source.dart';
import 'package:bb_mobile/_core/data/datasources/descriptor_data_source.dart';
import 'package:bb_mobile/_core/data/datasources/exchange_data_source.dart';
import 'package:bb_mobile/_core/data/datasources/key_value_stores/impl/hive_storage_datasource_impl.dart';
import 'package:bb_mobile/_core/data/datasources/key_value_stores/impl/secure_storage_data_source_impl.dart';
import 'package:bb_mobile/_core/data/datasources/key_value_stores/key_value_storage_data_source.dart';
import 'package:bb_mobile/_core/data/datasources/pdk_data_source.dart';
import 'package:bb_mobile/_core/data/datasources/seed_data_source.dart';
import 'package:bb_mobile/_core/data/datasources/wallet_metadata_data_source.dart';
import 'package:bb_mobile/_core/data/repositories/boltz_swap_repository_impl.dart';
import 'package:bb_mobile/_core/data/repositories/settings_repository_impl.dart';
import 'package:bb_mobile/_core/data/repositories/wallet_manager_repository_impl.dart';
import 'package:bb_mobile/_core/data/repositories/word_list_repository_impl.dart';
import 'package:bb_mobile/_core/domain/repositories/settings_repository.dart';
import 'package:bb_mobile/_core/domain/repositories/swap_repository.dart';
import 'package:bb_mobile/_core/domain/repositories/wallet_manager_repository.dart';
import 'package:bb_mobile/_core/domain/repositories/word_list_repository.dart';
import 'package:bb_mobile/_core/domain/services/mnemonic_seed_factory.dart';
import 'package:bb_mobile/_core/domain/usecases/find_mnemonic_words_use_case.dart';
import 'package:bb_mobile/_core/domain/usecases/get_bitcoin_unit_usecase.dart';
import 'package:bb_mobile/_core/domain/usecases/get_currency_usecase.dart';
import 'package:bb_mobile/_core/domain/usecases/get_environment_usecase.dart';
import 'package:bb_mobile/_core/domain/usecases/get_language_usecase.dart';
import 'package:bb_mobile/_core/domain/usecases/get_wallets_usecase.dart';
import 'package:bb_mobile/_utils/constants.dart';
import 'package:bb_mobile/locator.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

class CoreLocator {
  static Future<void> setup() async {
    // Data sources
    //  - Secure storage
    locator.registerLazySingleton<KeyValueStorageDataSource<String>>(
      () => SecureStorageDataSourceImpl(
        const FlutterSecureStorage(),
      ),
      instanceName: LocatorInstanceNameConstants.secureStorageDataSource,
    );
    //  - Wallet metadata
    final walletMetadataBox =
        await Hive.openBox<String>(HiveBoxNameConstants.walletMetadata);
    locator.registerLazySingleton<WalletMetadataDataSource>(
      () => WalletMetadataDataSourceImpl(
        bip32: const Bip32DataSourceImpl(),
        descriptor: const DescriptorDataSourceImpl(),
        walletMetadataStorage:
            HiveStorageDataSourceImpl<String>(walletMetadataBox),
      ),
    );
    //  - Payjoin
    final pdkPayjoinsBox =
        await Hive.openBox<String>(HiveBoxNameConstants.pdkPayjoins);
    locator.registerLazySingleton<PdkDataSource>(
      () => PdkDataSourceImpl(
        dio:
            Dio(), // TODO: We could add a Dio instance with the payjoin directory URL here already
        storage: HiveStorageDataSourceImpl<String>(pdkPayjoinsBox),
      ),
    );
    //  - Exchange
    locator.registerLazySingleton<ExchangeDataSource>(
      () => BullBitcoinExchangeDataSourceImpl(),
      instanceName: LocatorInstanceNameConstants
          .bullBitcoinExchangeDataSourceInstanceName,
    );
    //  - Swaps
    final boltzSwapsBox =
        await Hive.openBox<String>(HiveBoxNameConstants.boltzSwaps);
    locator.registerLazySingleton<KeyValueStorageDataSource<String>>(
      () => HiveStorageDataSourceImpl<String>(boltzSwapsBox),
      instanceName: LocatorInstanceNameConstants
          .boltzSwapsHiveStorageDataSourceInstanceName,
    );

    // Repositories
    final settingsBox =
        await Hive.openBox<String>(HiveBoxNameConstants.settings);
    locator.registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(
        storage: HiveStorageDataSourceImpl<String>(settingsBox),
      ),
    );
    locator.registerLazySingleton<WalletManagerRepository>(
      () => WalletManagerRepositoryImpl(
        walletMetadataDataSource: locator<WalletMetadataDataSource>(),
        seedDataSource: SeedDataSourceImpl(
          secureStorage: locator<KeyValueStorageDataSource<String>>(
            instanceName: LocatorInstanceNameConstants.secureStorageDataSource,
          ),
        ),
        pdk: locator<PdkDataSource>(),
      ),
    );
    locator.registerLazySingleton<WordListRepository>(
      () => WordListRepositoryImpl(
        dataSource: Bip39EnglishWordListDataSourceImpl(),
      ),
    );
    locator.registerLazySingleton<SwapRepository>(
      () => BoltzSwapRepositoryImpl(
        boltz: BoltzDataSourceImpl(),
        secureStorage: locator<KeyValueStorageDataSource<String>>(
          instanceName: LocatorInstanceNameConstants.secureStorageDataSource,
        ),
        localSwapStorage: locator<KeyValueStorageDataSource<String>>(
          instanceName: LocatorInstanceNameConstants
              .boltzSwapsHiveStorageDataSourceInstanceName,
        ),
      ),
      instanceName:
          LocatorInstanceNameConstants.boltzSwapRepositoryInstanceName,
    );
    locator.registerLazySingleton<SwapRepository>(
      () => BoltzSwapRepositoryImpl(
        boltz:
            BoltzDataSourceImpl(url: ApiServiceConstants.boltzTestnetUrlPath),
        secureStorage: locator<KeyValueStorageDataSource<String>>(
          instanceName: LocatorInstanceNameConstants.secureStorageDataSource,
        ),
        localSwapStorage: locator<KeyValueStorageDataSource<String>>(
          instanceName: LocatorInstanceNameConstants
              .boltzSwapsHiveStorageDataSourceInstanceName,
        ),
      ),
      instanceName:
          LocatorInstanceNameConstants.boltzTestnetSwapRepositoryInstanceName,
    );

    // Factories, managers or services responsible for handling specific logic
    locator.registerLazySingleton<MnemonicSeedFactory>(
      () => const MnemonicSeedFactoryImpl(),
    );

    // Use cases
    locator.registerFactory<FindMnemonicWordsUseCase>(
      () => FindMnemonicWordsUseCase(
        wordListRepository: locator<WordListRepository>(),
      ),
    );
    locator.registerFactory<GetEnvironmentUseCase>(
      () => GetEnvironmentUseCase(
        settingsRepository: locator<SettingsRepository>(),
      ),
    );
    locator.registerFactory<GetBitcoinUnitUseCase>(
      () => GetBitcoinUnitUseCase(
        settingsRepository: locator<SettingsRepository>(),
      ),
    );
    locator.registerFactory<GetLanguageUseCase>(
      () => GetLanguageUseCase(
        settingsRepository: locator<SettingsRepository>(),
      ),
    );
    locator.registerFactory<GetCurrencyUseCase>(
      () => GetCurrencyUseCase(
        settingsRepository: locator<SettingsRepository>(),
      ),
    );
    locator.registerFactory<GetWalletsUseCase>(
      () => GetWalletsUseCase(
        settingsRepository: locator<SettingsRepository>(),
        walletManager: locator<WalletManagerRepository>(),
      ),
    );
  }
}
