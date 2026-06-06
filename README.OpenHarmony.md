> Template version: v0.0.1

<p align="center">
  <h1 align="center"> <code>flutter_secure_storage</code> </h1>
</p>

This project is based on [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage).

## 1. Installation and Usage

### 1.1 Installation

Go to the project directory and add the following dependencies in pubspec.yaml

<!-- tabs:start -->

#### pubspec.yaml

```yaml
...

dependencies:
  flutter_secure_storage_ohos:
    git:
      url: https://gitcode.com/CPF-Flutter/fluttertpc_flutter_secure_storage.git
      path: flutter_secure_storage_ohos
      ref: br_v9.2.2_ohos
      
...
```

Execute Command

```bash
flutter pub get
```

<!-- tabs:end -->

### 1.2 Usage

For use cases [example](flutter_secure_storage_ohos/example/lib/main.dart)

## 2. Constraints

### 2.1 Compatibility

This document is verified based on the following versions:

1. Flutter: 3.7.12-ohos-1.0.6; SDK: 5.0.0(12); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;
2. Flutter: 3.22.1-ohos-1.0.1; SDK: 5.0.0(12); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;


## 3. API

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

### FlutterSecureStorage API  
| Name                | Description                                      | Type     | Input                                                                                                                                                                                                 | Output                  | ohos Support |  
|---------------------|--------------------------------------------------|----------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------|--------------|  
| write               | Encrypts and saves the `key` with the given `value` | function | required String key, required String? value, IOSOptions? iOptions, AndroidOptions? aOptions, OhosOptions? ohOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions | Future<void>            | yes          |  
| read                | Decrypts and returns the value for the given `key` or null if not found | function | required String key, IOSOptions? iOptions, AndroidOptions? aOptions, OhosOptions? ohOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions        | Future<String?>         | yes          |  
| containsKey         | Returns true if the storage contains the given `key` | function | required String key, IOSOptions? iOptions, AndroidOptions? aOptions, OhosOptions? ohOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions        | Future<bool>            | yes          |  
| delete              | Deletes associated value for the given `key`     | function | required String key, IOSOptions? iOptions, AndroidOptions? aOptions, OhosOptions? ohOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions        | Future<void>            | yes          |  
| readAll             | Decrypts and returns all keys with associated values | function | IOSOptions? iOptions, AndroidOptions? aOptions, OhosOptions? ohOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions                             | Future<Map<String, String>> | yes          |  
| deleteAll           | Deletes all keys with associated values          | function | IOSOptions? iOptions, AndroidOptions? aOptions, OhosOptions? ohOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions                             | Future<void>            | yes          |  

---

## 4. Properties

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

### OhosOptions Filters   
| Name                | Description                                      | Type     | Input | Output | ohos Support |  
|---------------------|--------------------------------------------------|----------|-------|--------|--------------|  
| encryptedSharedPreferences | If enabled, uses EncryptedSharedPreferences  | bool | / | / | yes |  
| resetOnError        | Automatically reset all data when error detected (permanent data loss risk) | bool | / | / | yes |  
| ohosKeyCipherAlgorithm | Algorithm for encrypting secret keys (default: RSA_ECB_PKCS1Padding) | OhosKeyCipherAlgorithm | / | / | yes |  
| ohosStorageCipherAlgorithm | Algorithm for encrypting properties (default: AES_CBC_PKCS7Padding) | OhosStorageCipherAlgorithm | / | / | yes |  
| sharedPreferencesName | Custom name for SharedPreferences database (default used if empty) | String? | / | / | yes |  
| preferencesKeyPrefix | Prefix for preference keys to ensure uniqueness (default used if empty) | String? | / | / | yes |  

---

### OhosKeyCipherAlgorithm Filters  
| Name                | Description                                      | Type     | Input | Output | ohos Support |  
|---------------------|--------------------------------------------------|----------|-------|--------|--------------|  
| RSA_ECB_PKCS1Padding | Default RSA ECB PKCS1 padding algorithm          | enum     | /     | /      | yes          |  
| RSA_ECB_OAEPwithSHA_256andMGF1Padding | Newer RSA ECB OAEP with SHA-256 and MGF1 padding algorithm (available from Ohos 12) | enum | / | / | yes |  

---

### OhosStorageCipherAlgorithm Filters  
| Name                | Description                                      | Type     | Input | Output | ohos Support |  
|---------------------|--------------------------------------------------|----------|-------|--------|--------------|  
| AES_CBC_PKCS7Padding | Default AES CBC PKCS7 padding algorithm          | enum     | /     | /      | yes          |  
| AES_GCM_NoPadding    | Newer AES GCM no padding algorithm (available from Ohos 12) | enum | / | / | yes |  

---

## 5. Known Issues

## 6. Others

## 7. License

This project is licensed under [The BSD-3-Clause (license)](flutter_secure_storage_ohos/LICENSE).
