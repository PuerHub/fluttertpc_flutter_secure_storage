part of '../flutter_secure_storage_ohos.dart';

enum OhosKeyCipherAlgorithm {
  rsaEcbPKCS1Padding,
  rsaEcbOAEPWithSHA256AndMGF1Padding,
}

enum OhosStorageCipherAlgorithm {
  aesCbcPKCS7Padding,
  aesGcmNoPadding,
}

class OhosOptions extends Options {
  const OhosOptions({
    bool encryptedSharedPreferences = false,
    bool resetOnError = false,
    OhosKeyCipherAlgorithm ohosKeyCipherAlgorithm =
        OhosKeyCipherAlgorithm.rsaEcbPKCS1Padding,
    OhosStorageCipherAlgorithm ohosStorageCipherAlgorithm =
        OhosStorageCipherAlgorithm.aesCbcPKCS7Padding,
    this.sharedPreferencesName,
    this.preferencesKeyPrefix,
  })  : _encryptedSharedPreferences = encryptedSharedPreferences,
        _resetOnError = resetOnError,
        _ohosKeyCipherAlgorithm = ohosKeyCipherAlgorithm,
        _ohosStorageCipherAlgorithm = ohosStorageCipherAlgorithm;

  /// EncryptedSharedPreferences are not support.
  final bool _encryptedSharedPreferences;

  /// When an error is detected, automatically reset all data. This will prevent
  /// fatal errors regarding an unknown key however keep in mind that it will
  /// PERMANENT erase the data when an error occurs.
  ///
  /// Defaults to false.
  final bool _resetOnError;

  final OhosKeyCipherAlgorithm _ohosKeyCipherAlgorithm;

  final OhosStorageCipherAlgorithm _ohosStorageCipherAlgorithm;

  /// The name of the sharedPreference database to use.
  /// You can select your own name if you want. A default name will
  /// be used if nothing is provided here.
  ///
  /// WARNING: If you change this you can't retrieve already saved preferences.
  final String? sharedPreferencesName;

  /// The prefix for a shared preference key. The prefix is used to make sure
  /// the key is unique to your application. If not provided, a default prefix
  /// will be used.
  ///
  /// WARNING: If you change this you can't retrieve already saved preferences.
  final String? preferencesKeyPrefix;

  static const OhosOptions defaultOptions = OhosOptions();

  @override
  Map<String, String> toMap() => <String, String>{
        'encryptedSharedPreferences': '$_encryptedSharedPreferences',
        'resetOnError': '$_resetOnError',
        'ohosKeyCipherAlgorithm': describeEnum(_ohosKeyCipherAlgorithm),
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
        ohosKeyCipherAlgorithm: ohosKeyCipherAlgorithm ?? _ohosKeyCipherAlgorithm,
        ohosStorageCipherAlgorithm:
            ohosStorageCipherAlgorithm ?? _ohosStorageCipherAlgorithm,
        sharedPreferencesName: sharedPreferencesName,
        preferencesKeyPrefix: preferencesKeyPrefix,
      );
}
