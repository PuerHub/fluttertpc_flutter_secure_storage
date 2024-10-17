library flutter_secure_storage;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage_ohos/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';

part './options/ohos_options.dart';

class FlutterSecureStorage {
  final OhosOptions ohOptions;

  const FlutterSecureStorage({
    this.ohOptions = OhosOptions.defaultOptions,
  });

  FlutterSecureStoragePlatform get _platform =>
      FlutterSecureStoragePlatform.instance;

  /// Encrypts and saves the [key] with the given [value].
  ///
  /// If the key was already in the storage, its associated value is changed.
  /// If the value is null, deletes associated value for the given [key].
  /// [key] shouldn't be null.
  /// [value] required value
  /// [ohOptions] optional Ohos options
  /// Can throw a [PlatformException].
  Future<void> write({
    required String key,
    required String? value,
    OhosOptions? ohOptions,
  }) =>
      value == null
          ? _platform.delete(key: key, options: _selectOptions(ohOptions))
          : _platform.write(
              key: key, value: value, options: _selectOptions(ohOptions));

  /// Decrypts and returns the value for the given [key] or null if [key] is not in the storage.
  ///
  /// [key] shouldn't be null.
  /// [ohOptions] optional Ohos options
  /// Can throw a [PlatformException].
  Future<String?> read({
    required String key,
    OhosOptions? ohOptions,
  }) =>
      _platform.read(
        key: key,
        options: _selectOptions(ohOptions),
      );

  /// Returns true if the storage contains the given [key].
  ///
  /// [key] shouldn't be null.
  /// [ohOptions] optional Ohos options
  /// Can throw a [PlatformException].
  Future<bool> containsKey({
    required String key,
    OhosOptions? ohOptions,
  }) =>
      _platform.containsKey(
        key: key,
        options: _selectOptions(ohOptions),
      );

  /// Deletes associated value for the given [key].
  ///
  /// If the given [key] does not exist, nothing will happen.
  ///
  /// [key] shouldn't be null.
  /// [ohOptions] optional Ohos options
  /// Can throw a [PlatformException].
  Future<void> delete({
    required String key,
    OhosOptions? ohOptions,
  }) =>
      _platform.delete(
        key: key,
        options: _selectOptions(ohOptions),
      );

  /// Decrypts and returns all keys with associated values.
  ///
  /// [ohOptions] optional Ohos options
  /// Can throw a [PlatformException].
  Future<Map<String, String>> readAll({
    OhosOptions? ohOptions,
  }) =>
      _platform.readAll(
        options: _selectOptions(
          ohOptions,
        ),
      );

  /// Deletes all keys with associated values.
  ///
  /// [ohOptions] optional Ohos options
  /// Can throw a [PlatformException].
  Future<void> deleteAll({
    OhosOptions? ohOptions,
  }) =>
      _platform.deleteAll(
        options: _selectOptions(
          ohOptions,
        ),
      );

  /// Select correct options based on current platform
  Map<String, String> _selectOptions(
    OhosOptions? ohOptions,
  ) {
    if (Platform.operatingSystem == 'ohos') {
      return ohOptions?.params ?? this.ohOptions.params;
    } else {
      throw UnsupportedError('unsupported_platform');
    }
  }

  /// Initializes the shared preferences with mock values for testing.
  @visibleForTesting
  static void setMockInitialValues(Map<String, String> values) {
    FlutterSecureStoragePlatform.instance =
        TestFlutterSecureStoragePlatform(values);
  }
}
