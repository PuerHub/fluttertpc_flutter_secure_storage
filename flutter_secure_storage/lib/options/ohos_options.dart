part of '../flutter_secure_storage.dart';

enum OhosKeyCipherAlgorithm {
  RSA_ECB_PKCS1Padding,
  RSA_ECB_OAEPwithSHA_256andMGF1Padding,
}

enum OhosStorageCipherAlgorithm {
  AES_CBC_PKCS7Padding,
  AES_GCM_NoPadding,
}

class OhosOptions extends Options {
  const OhosOptions({
    bool encryptedSharedPreferences = false,
    bool resetOnError = false,
    OhosKeyCipherAlgorithm ohosKeyCipherAlgorithm =
        OhosKeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
    OhosStorageCipherAlgorithm ohosStorageCipherAlgorithm =
        OhosStorageCipherAlgorithm.AES_CBC_PKCS7Padding,
    this.sharedPreferencesName,
    this.preferencesKeyPrefix,
  })  : _encryptedSharedPreferences = encryptedSharedPreferences,
        _resetOnError = resetOnError,
        _ohosKeyCipherAlgorithm = ohosKeyCipherAlgorithm,
        _ohosStorageCipherAlgorithm = ohosStorageCipherAlgorithm;

  final bool _encryptedSharedPreferences;
  final bool _resetOnError;
  final OhosKeyCipherAlgorithm _ohosKeyCipherAlgorithm;
  final OhosStorageCipherAlgorithm _ohosStorageCipherAlgorithm;

  /// The name of the preferences store on OHOS. Defaults are decided by the
  /// platform side when empty.
  final String? sharedPreferencesName;

  /// The prefix for a preferences key. Defaults are decided by the platform
  /// side when empty.
  final String? preferencesKeyPrefix;

  static const OhosOptions defaultOptions = OhosOptions();

  @override
  Map<String, String> toMap() => <String, String>{
        'encryptedSharedPreferences': '$_encryptedSharedPreferences',
        'resetOnError': '$_resetOnError',
        // ignore: deprecated_member_use
        'ohosKeyCipherAlgorithm': describeEnum(_ohosKeyCipherAlgorithm),
        // ignore: deprecated_member_use
        'ohosStorageCipherAlgorithm': describeEnum(_ohosStorageCipherAlgorithm),
        'sharedPreferencesName': sharedPreferencesName ?? '',
        'preferencesKeyPrefix': preferencesKeyPrefix ?? '',
      };

  OhosOptions copyWith({
    bool? encryptedSharedPreferences,
    bool? resetOnError,
    OhosKeyCipherAlgorithm? ohosKeyCipherAlgorithm,
    OhosStorageCipherAlgorithm? ohosStorageCipherAlgorithm,
    String? preferencesKeyPrefix,
    String? sharedPreferencesName,
  }) =>
      OhosOptions(
        encryptedSharedPreferences:
            encryptedSharedPreferences ?? _encryptedSharedPreferences,
        resetOnError: resetOnError ?? _resetOnError,
        ohosKeyCipherAlgorithm:
            ohosKeyCipherAlgorithm ?? _ohosKeyCipherAlgorithm,
        ohosStorageCipherAlgorithm:
            ohosStorageCipherAlgorithm ?? _ohosStorageCipherAlgorithm,
        sharedPreferencesName: sharedPreferencesName,
        preferencesKeyPrefix: preferencesKeyPrefix,
      );
}
