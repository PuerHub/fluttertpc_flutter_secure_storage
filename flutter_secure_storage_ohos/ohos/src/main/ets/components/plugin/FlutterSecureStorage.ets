/*
 * Copyright (C) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { preferences } from '@kit.ArkData';
import { util } from '@kit.ArkTS';

import { StorageCipherFactory } from './ciphers/StorageCipherFactory';
import StorageCipher from './ciphers/StorageCipher';
import { convertObjectToMap, StringToUint8Array, Uint8ArrayToString } from './utils';

interface KeyPrefixInterface {
  get getKeyPrefix(): string;
  set setKeyPrefix(value: string);
}

interface OrderedKeysResult {
  // 按照稳定顺序排列的原始键列表。
  keys: string[];
  // 是否有新的键需要补齐顺序索引
  isDirty: boolean;
}

const TAG: string = "SecureStorage::FlutterSecureStorage";

export default class FlutterSecureStorage implements KeyPrefixInterface {
  private context: Context | null = null;
  protected ELEMENT_PREFERENCES_KEY_PREFIX: string = "";
  // 业务数据键前缀，区分内部元数据键，避免误操作
  private KEY_ORDER_PREFERENCES_KEY: string = "__flutter_secure_storage_key_order__";
  public options: Map<String, Object> = new Map();
  private SHARED_PREFERENCES_NAME: string = "FlutterSecureStorage";
  private dataPreferences: preferences.Preferences | null = null;
  private storageCipher: StorageCipher | null = null;
  private storageCipherFactory: StorageCipherFactory | null = null;
  base64: util.Base64Helper = new util.Base64Helper();

  constructor(context: Context, options: Map<String, Object>) {
    this.context = context;
    this.options = options;
    this.setKeyPrefix = 'VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIHNlY3VyZSBzdG9yYWdlCg';
  }

  public async write(key: string, value: string) {
    try {
      this.ensureInitialized();
      if(!this.dataPreferences || !this.storageCipher) return;

      let isNewKey: boolean = !this.dataPreferences.hasSync(key);

      let result = await this.storageCipher.encrypt({data: StringToUint8Array(value)});
      let resultStr = this.base64.encodeToStringSync(result.data);

      this.dataPreferences.putSync(key, resultStr);
      if (isNewKey) {
        // 如果是新键，更新顺序索引以保持读取顺序稳定；老键不修改顺序。
        const keyOrder: string[] = this.getKeyOrder();
        const keyOrderNew: string[] = this.appendKeyToOrder(keyOrder, key);
        this.persistKeyOrder(keyOrderNew);
      }
      await this.dataPreferences.flush();
    } catch (e) {
      console.error(TAG, 'error code ' + e.code + 'error message ' + e.message);
    }
  }

  public async read(key: string): Promise<string> {
    try {
      this.ensureInitialized();
      if (!this.dataPreferences) {
        return '';
      }
      let result: preferences.ValueType = this.dataPreferences.getSync(key, null);
      result = await this.decodeRawValue(result as string);
      return result;
    } catch (e) {
      console.error(TAG, 'error code ' + e.code + 'error message ' + e.message);
      return '';
    }
  }

  get getKeyPrefix(): string {
    return this.ELEMENT_PREFERENCES_KEY_PREFIX;
  }

  set setKeyPrefix(key: string) {
    this.ELEMENT_PREFERENCES_KEY_PREFIX = key;
  }

  /**
   * 按显式维护的键顺序读取全部数据，避免应用重启后枚举顺序漂移。
   *
   * @returns 按插入顺序返回的明文键值对集合。
   */
  public async readAll(): Promise<Map<string, string>>{
    let all: Map<string, string> =  new Map();
    try {
      this.ensureInitialized();
      if(!this.dataPreferences) return new Map();

      let raw: Object = this.dataPreferences.getAllSync();
      let rawMap = convertObjectToMap(raw);
      let orderedKeysResult: OrderedKeysResult = this.resolveOrderedKeys(rawMap);
      let orderedKeys: string[] = orderedKeysResult.keys;

      if(!orderedKeys.length) {
        return all;
      }
      // 如果发现有新数据但不在顺序索引中，说明之前的索引不完整或已损坏，需要补齐后回写以保持后续读取稳定。
      if (orderedKeysResult.isDirty) {
        // 兼容历史数据：首次读取时把缺失的顺序索引补齐并落盘。
        this.persistKeyOrder(orderedKeys);
        await this.dataPreferences.flush();
      }

      // 按照稳定顺序逐条解密，避免一次性解密全部数据可能导致的性能问题。
      await Promise.all(orderedKeys.map((rawKey: string) => this.loadOrderedValue(rawMap, rawKey, all)));
    } catch (e) {
      console.error(TAG, 'readAll failure, error code ' + e.code + 'error message ' + e.message);
    }
    return all;
  }

  public async delete(key: string) {
    try {
      this.ensureInitialized();
      if(!this.dataPreferences) return;

      await this.dataPreferences.delete(key);
      // 删除业务数据时同步更新顺序索引，保持读取顺序稳定。
      const keyOrder: string[] = this.getKeyOrder();
      const keyOrderNew: string[] = this.removeKeyFromOrder(keyOrder, key);
      this.persistKeyOrder(keyOrderNew);
      await this.dataPreferences.flush();
    } catch (e) {
      console.error(TAG, 'delete failure, error code ' + e.code + 'error message ' + e.message);
    }
  }

  public async deleteAll() {
    try {
      this.ensureInitialized();
      if(!this.dataPreferences) return;

      let raw: Object = this.dataPreferences.getAllSync();
      let rawMap = convertObjectToMap(raw);

      rawMap.forEach((rawVal, rawKey) => {
        const keyWithPrefix: string = rawKey;
        if (keyWithPrefix.includes(this.getKeyPrefix)) {
          this.dataPreferences?.deleteSync(rawKey);
        }
      })

      // 清空业务数据时同步删除内部顺序索引，避免后续读取到脏元数据。
      this.dataPreferences.deleteSync(this.KEY_ORDER_PREFERENCES_KEY);

      await this.dataPreferences.flush();
    } catch (e) {
      console.error(TAG, 'deleteAll failure, error code ' + e.code + 'error message ' + e.message);
    }
  }

  public containsKey(key: string): boolean {
    this.ensureInitialized();
    try {
      if (this.dataPreferences) {
        return this.dataPreferences.hasSync(key);
      }
    } catch (e) {
      console.error(TAG, 'containsKey failure, error code ' + e.code + 'error message ' + e.message);
    }
    return false;
  }

  private ensureInitialized() {
    if(this.dataPreferences && this.storageCipher) return;
    this.ensureOptions();
    if (!this.context) {
      console.error(TAG, 'context is null');
      return;
    }

    try {
      // 创建 preferences
      let nonEncryptedPreferences: preferences.Preferences = preferences.getPreferencesSync(this.context, { name: this.SHARED_PREFERENCES_NAME});
      // 初始化 storageCipher
      if (this.storageCipher == null) {
        try {
          this.initStorageCipher(nonEncryptedPreferences);
        } catch (e) {
          console.error(TAG,"StorageCipher initialization failure", e);
        }
      }
      this.dataPreferences = nonEncryptedPreferences;
    } catch (e) {
      console.error(TAG, 'preferences initialization failure, error code ' + e.code + 'error message ' + e.message);
    }
  }

  protected ensureOptions() {
    if (this.options.has("sharedPreferencesName") && this.options.get("sharedPreferencesName")) {
      this.SHARED_PREFERENCES_NAME = this.options.get("sharedPreferencesName") as string;
    }

    if (this.options.has("preferencesKeyPrefix") && this.options.get("preferencesKeyPrefix")) {
      this.setKeyPrefix = this.options.get("preferencesKeyPrefix") as string;
    }
  }

  private initStorageCipher(source: preferences.Preferences) {
    this.storageCipherFactory = new StorageCipherFactory(source, this.options);

    // 如果需要重新加密
    if (this.storageCipherFactory.requiresReEncryption()) {
      this.reEncryptPreferences(this.storageCipherFactory, source);
    } else {
      this.storageCipher = this.storageCipherFactory.getCurrentStorageCipher(this.context as Context);
    }
  }

  private async reEncryptPreferences(storageCipherFactory: StorageCipherFactory, source: preferences.Preferences) {
    try {
      this.storageCipher = storageCipherFactory.getSavedStorageCipher(this.context as Context);
      let raw: Object = await source.getAll();
      let cache: Map<string, string> = new Map();
      let rawMap = convertObjectToMap(raw);
      let promises: Promise<void>[] = [];

      rawMap.forEach(async (rawVal, rawKey) => {
        if (rawKey.includes(this.getKeyPrefix) && typeof rawVal == 'string') {
          const valuePromise = this.decodeRawValue(rawVal);
          promises.push(valuePromise.then((value: string) => {
            cache.set(rawKey, value);
          }))
        }
      })

      await Promise.all(promises);

      // 如果密钥算法更新了,应该删除密钥缓存中的key,value,重新加密后存储
      await storageCipherFactory.removeSaveAlgorithms(this.context as Context);

      this.storageCipher = storageCipherFactory.getCurrentStorageCipher(this.context as Context);
      let dataPreferencesPromises: Promise<void>[] = [];
      dataPreferencesPromises = Array.from(cache.keys()).map(async (key) => {
        if(!this.storageCipher || !this.dataPreferences) return;
        let val = cache.get(key);
        if (!val) return; // 检查缓存中是否包含该键

        try {
          let result: cryptoFramework.DataBlob | undefined = await this.storageCipher.encrypt({data: StringToUint8Array(val)});
          let resultBlob = this.base64.encodeToStringSync(result?.data);
          await this.dataPreferences.put(key, resultBlob);
        } catch (e) {
          console.error(TAG, "re-encryption after modifying the algorithm failure. code =" + e.code + ", message =" + e.message);
        }
      })

      await Promise.all(dataPreferencesPromises);
      storageCipherFactory.storeCurrentAlgorithms(this.dataPreferences as preferences.Preferences);
      await this.dataPreferences?.flush();
    } catch (e) {
      console.error(TAG, "re-encryption failure. code =" + e.code + ", message =" + e.message);
      this.storageCipher = storageCipherFactory.getSavedStorageCipher(this.context as Context);
    }
  }

  public getResetOnError(): boolean {
    return this.options.has("resetOnError") && !!this.options?.get("resetOnError");
  }

  private async decodeRawValue(value: string): Promise<string> {
    try {
      if (!value || !this.storageCipher) {
        return '';
      }
      let data = this.base64.decodeSync(value);
      let result = await this.storageCipher.decrypt({
        data
      });
      return Uint8ArrayToString(result.data);
    } catch (e) {
      console.error(TAG, "decodeRawValue failure. code =" + e.code + ", message =" + e.message);
      return '';
    }
  }

  /**
   * 判断指定键是否为插件真实业务数据键，排除内部元数据键。
   *
   * @param key preferences 中的原始键。
   * @returns 是否属于带前缀的业务数据键。
   */
  private isStorageValueKey(key: string): boolean {
    return key.startsWith(this.getKeyPrefix + '_');
  }

  /**
   * 读取持久化的键顺序索引。
   *
   * @returns 已保存的原始键顺序列表；索引不存在或损坏时返回空数组。
   */
  private getKeyOrder(): string[] {
    if (!this.dataPreferences) {
      return [];
    }

    let storedOrder: preferences.ValueType;
    try {
      storedOrder = this.dataPreferences.getSync(this.KEY_ORDER_PREFERENCES_KEY, '[]');
    } catch (e) {
      console.error(TAG, 'read key order failure, error code ' + e.code + 'error message ' + e.message);
      return [];
    }

    if (typeof storedOrder !== 'string') {
      return [];
    }

    try {
      let parsed = JSON.parse(storedOrder) as Object[];
      let keyOrder: string[] = [];
      parsed.forEach((item: Object) => {
        if (typeof item === 'string') {
          keyOrder.push(item);
        }
      });
      return keyOrder;
    } catch (e) {
      console.error(TAG, 'parse key order failure, error code ' + e.code + 'error message ' + e.message);
      return [];
    }
  }

  /**
   * 将最新的键顺序索引写回 preferences。
   *
   * @param keyOrder 当前应持久化的原始键顺序列表。
   */
  private persistKeyOrder(keyOrder: string[]) {
    if (!this.dataPreferences) {
      return;
    }

    try {
      this.dataPreferences.putSync(this.KEY_ORDER_PREFERENCES_KEY, JSON.stringify(keyOrder));
    } catch (e) {
      console.error(TAG, 'persist key order failure, error code ' + e.code + 'error message ' + e.message);
    }
  }

  /**
   * 新增键时将其追加到顺序索引尾部，保持插入顺序稳定。
   *
   * @param keyOrder 当前键顺序列表。
   * @param key 待追加的原始键。
   * @returns 更新后的键顺序列表。
   */
  private appendKeyToOrder(keyOrder: string[], key: string): string[] {
    if (keyOrder.indexOf(key) >= 0) {
      return keyOrder;
    }

    keyOrder.push(key);
    return keyOrder;
  }

  /**
   * 删除键时同步移除顺序索引中的对应项。
   *
   * @param keyOrder 当前键顺序列表。
   * @param key 待移除的原始键。
   * @returns 移除指定键后的键顺序列表。
   */
  private removeKeyFromOrder(keyOrder: string[], key: string): string[] {
    return keyOrder.filter((savedKey: string) => savedKey !== key);
  }

  /**
   * 根据当前存储内容和已持久化索引生成稳定的读取顺序。
   *
   * @param rawMap 当前 preferences 中的全部原始键值。
   * @returns 计算后的稳定键顺序，以及是否需要回写索引。
   */
  private resolveOrderedKeys(rawMap: Map<string, string>): OrderedKeysResult {
    let visibleKeys: string[] = [];
    rawMap.forEach((rawVal, rawKey) => {
      if (this.isStorageValueKey(rawKey) && typeof rawVal === 'string') {
        visibleKeys.push(rawKey);
      }
    });

    if (!visibleKeys.length) {
      return { keys: [], isDirty: false };
    }

    let orderedKeys: string[] = [];
    let orderedKeySet: Map<string, boolean> = new Map();
    const keyOrder: string[] = this.getKeyOrder();
    keyOrder.forEach((savedKey: string) => {
      if (rawMap.has(savedKey) && this.isStorageValueKey(savedKey)) {
        orderedKeys.push(savedKey);
        orderedKeySet.set(savedKey, true);
      }
    });

    let isDirty: boolean = orderedKeys.length !== visibleKeys.length;
    visibleKeys.forEach((visibleKey: string) => {
      if (!orderedKeySet.has(visibleKey)) {
        // 老数据可能还没有顺序索引，这里按当前可见顺序补齐缺失项。
        orderedKeys.push(visibleKey);
        isDirty = true;
      }
    });

    return { keys: orderedKeys, isDirty };
  }

  /**
   * 解密单个有序键并写入返回结果集合。
   *
   * @param rawMap 当前 preferences 中的全部原始键值。
   * @param rawKey 本次要处理的原始键。
   * @param all 解密后的返回结果集合。
   * @returns 异步解密完成后写入结果集合；无效键直接跳过。
   */
  private async loadOrderedValue(rawMap: Map<string, string>, rawKey: string, all: Map<string, string>): Promise<void> {
    let rawVal: string | undefined = rawMap.get(rawKey);
    if (typeof rawVal !== 'string') {
      return;
    }

    let key = rawKey.substring(this.getKeyPrefix.length + 1);
    let value = await this.decodeRawValue(rawVal);
    all.set(key, value);
  }
}