> 模板版本: v0.0.1

<p align="center">
  <h1 align="center"> <code>flutter_secure_storage</code> </h1>
</p>

本项目基于 [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) 开发。

## 1. 安装与使用

### 1.1 安装方式

进入到工程目录并在 pubspec.yaml 中添加以下依赖：

<!-- tabs:start -->

#### pubspec.yaml

```yaml
...

dependencies:
  flutter_secure_storage_ohos:
    git: 
      url: https://gitcode.com/openharmony-sig/fluttertpc_flutter_secure_storage.git
      path: flutter_secure_storage_ohos
      ref: br_v9.2.2_ohos

...
```

执行命令

```bash
flutter pub get
```

<!-- tabs:end -->

### 1.2 使用案例

使用案例详见 [example](flutter_secure_storage_ohos/example/lib/main.dart)

## 2. 约束与限制

### 2.1 兼容性

在以下版本中已测试通过

1. Flutter: 3.7.12-ohos-1.0.6; SDK: 5.0.0(12); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;
2. Flutter: 3.22.1-ohos-1.0.1; SDK: 5.0.0(12); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;


## 3. API

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

### FlutterSecureStorage API  
| Name                | Description                                      | Type     | Input                                                                                                                                                                                                 | Output                  | ohos Support |  
|---------------------|--------------------------------------------------|----------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------|--------------|  
| write               | 加密并保存指定的键值对                           | function | required String key, required String? value, IOSOptions? iOptions, AndroidOptions? aOptions, OhosOptions? ohOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions | Future<void>            | yes          |  
| read                | 解密并返回指定键的关联值（若不存在则返回null）    | function | required String key, IOSOptions? iOptions, AndroidOptions? aOptions, OhosOptions? ohOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions        | Future<String?>         | yes          |  
| containsKey         | 判断存储中是否包含指定键                         | function | required String key, IOSOptions? iOptions, AndroidOptions? aOptions, OhosOptions? ohOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions        | Future<bool>            | yes          |  
| delete              | 删除指定键的关联值                               | function | required String key, IOSOptions? iOptions, AndroidOptions? aOptions, OhosOptions? ohOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions        | Future<void>            | yes          |  
| readAll             | 解密并返回所有键值对                             | function | IOSOptions? iOptions, AndroidOptions? aOptions, OhosOptions? ohOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions                             | Future<Map<String, String>> | yes          |  
| deleteAll           | 删除所有键值对                                   | function | IOSOptions? iOptions, AndroidOptions? aOptions, OhosOptions? ohOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions                             | Future<void>            | yes          |  
 

---

## 4. 属性

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

### OhosOptions Filters  
| Name                | Description                                      | Type     | Input | Output | ohos Support |  
|---------------------|--------------------------------------------------|----------|-------|--------|--------------|  
| encryptedSharedPreferences | 启用后使用加密共享偏好设置 | bool | / | / | no |  
| resetOnError        | 检测到错误时自动重置所有数据（存在永久数据丢失风险） | bool | / | / | yes |  
| ohosKeyCipherAlgorithm | 用于加密密钥的算法（默认：RSA_ECB_PKCS1Padding） | OhosKeyCipherAlgorithm | / | / | yes |  
| ohosStorageCipherAlgorithm | 用于加密属性的算法（默认：AES_CBC_PKCS7Padding） | OhosStorageCipherAlgorithm | / | / | yes |  
| sharedPreferencesName | 自定义SharedPreferences数据库名称（为空时使用默认值） | String? | / | / | yes |  
| preferencesKeyPrefix | 键前缀确保应用唯一性（为空时使用默认值） | String? | / | / | yes |  

---

### OhosKeyCipherAlgorithm Filters
| Name                | Description                                      | Type     | Input | Output | ohos Support |  
|---------------------|--------------------------------------------------|----------|-------|--------|--------------|  
| RSA_ECB_PKCS1Padding | 默认RSA ECB PKCS1填充算法                        | enum     | /     | /      | yes          |  
| RSA_ECB_OAEPwithSHA_256andMGF1Padding | 较新的RSA ECB OAEP使用SHA-256和MGF1填充算法（从Ohos 12开始可用） | enum | / | / | yes |  

---

### OhosStorageCipherAlgorithm Filters
| Name                | Description                                      | Type     | Input | Output | ohos Support |  
|---------------------|--------------------------------------------------|----------|-------|--------|--------------|  
| AES_CBC_PKCS7Padding | 默认AES CBC PKCS7填充算法                        | enum     | /     | /      | yes          |  
| AES_GCM_NoPadding    | 较新的AES GCM无填充算法（从Ohos 12开始可用）    | enum     | /     | /      | yes          |  

---

## 5. 遗留问题

## 6. 其他

## 7. 开源协议

本项目基于 [The BSD-3-Clause (license)](flutter_secure_storage_ohos/LICENSE) ，请自由地享受和参与开源。
