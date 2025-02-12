import 'package:bb_mobile/features/wallet/domain/entities/wallet_metadata.dart';

abstract class WalletMetadataRepository {
  Future<void> storeWalletMetadata(WalletMetadata metadata);
  Future<WalletMetadata?> getWalletMetadata(String walletId);
  Future<List<WalletMetadata>> getAllWalletsMetadata();
  Future<void> deleteWalletMetadata(String walletId);
}
