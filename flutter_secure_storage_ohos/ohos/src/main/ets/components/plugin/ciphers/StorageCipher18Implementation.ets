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

import { preferences } from '@kit.ArkData';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { util } from '@kit.ArkTS';

import StorageCipher from './StorageCipher';
import KeyCipher from './KeyCipher';
import { mergeUint8Arrays, splitUint8Array } from '../utils';
import TLog from '../utils/TLog';

const TAG = 'SecureStorage::StorageCipher18Implementation'

export default class StorageCipher18Implementation implements StorageCipher {
  private SECRET_KEY_PREFERENCES_NAME: string = 'FlutterSecureKeyStorage';
  protected random: cryptoFramework.Random;
  protected ivSize: number = 16;
  private KEY_ALGORITHM: string = "AES128";
  protected cipher: cryptoFramework.Cipher | null = null;
  protected secretKey: cryptoFramework.Key | null = null;
  base64: util.Base64Helper = new util.Base64Helper();
  preferences: preferences.Preferences | null = null;
  rsaCipher: KeyCipher | null = null;
  context: Context | null = null;

  constructor(context: Context, rsaCipher: KeyCipher) {
    this.context = context;
    this.rsaCipher = rsaCipher;
    try {
      this.random = cryptoFramework.createRandom();
    } catch (e) {
      let message = `createRandom failure: error code ${e.code} error message ${e.message}`;
      console.error(TAG, message);
      throw new Error(`${TAG} -> ${message}`);
    }
  }

  async getAESSecretKey() {
    if (this.secretKey && this.preferences) {
      return;
    }

    try {
      this.preferences = preferences.getPreferencesSync(this.context, {
        name: this.SECRET_KEY_PREFERENCES_NAME
      });
      let aesPreferencesKey: string = this.getAESPreferencesKey();
      let aesKey: preferences.ValueType = this.preferences.getSync(aesPreferencesKey, null);
      if (aesKey != null && this.rsaCipher) {
        let encrypted: Uint8Array = this.base64.decodeSync(aesKey as string);
        this.secretKey = await this.rsaCipher.RSADecrypt(encrypted, this.KEY_ALGORITHM);
        console.log(TAG, "Succeeded in getting preferences.");
        return;
      }

      this.secretKey = this.genSymKeyByData();
      TLog.d(TAG, `secretKey:  ${this.base64.encodeToStringSync(this.secretKey.getEncoded().data)}`);
      const encryptedKey: Uint8Array | undefined = await this.rsaCipher?.RSAEncrypt(this.secretKey);
      let value: string = this.base64.encodeToStringSync(encryptedKey);
      if (!this.preferences) {
        console.error(TAG, 'Failed to get preferences, preferences is undefined.');
        return;
      }
      this.preferences.putSync(aesPreferencesKey, value);
      await this.preferences.flush();
    } catch (e) {
      let message = `createRandom failure: error code ${e.code} error message ${e.message}`;
      console.error(TAG, message);
      throw new Error(`${TAG} -> ${message}`);
    }
  }

  protected getAESPreferencesKey(): string {
    return "VGhpcyBpcyB0aGUga2V5IGZvciBhIHNlY3VyZSBzdG9yYWdlIEFFUyBLZXkK";
  }

  async removePreferencesKey() {
    try {
      this.preferences = preferences.getPreferencesSync(this.context, {
        name: this.SECRET_KEY_PREFERENCES_NAME
      });
      let aesPreferencesKey: string = this.getAESPreferencesKey();
      let aesKey: preferences.ValueType = this.preferences.getSync(aesPreferencesKey, null);
      if (aesKey) {
        this.preferences.deleteSync(aesPreferencesKey);
        await this.preferences.flush();
      }
    } catch (e) {
      let message = `removePreferencesKey failure: error code ${e.code} error message ${e.message}`;
      console.error(TAG, message);
      throw new Error(`${TAG} -> ${message}`);
    }
  }

  protected getCipher(): cryptoFramework.Cipher {
    try {
      return cryptoFramework.createCipher("AES128|CBC|PKCS7");
    } catch (e) {
      let message = `getCipher failure: error code ${e.code} error message ${e.message}`;
      console.error(TAG, message);
      throw new Error(`${TAG} -> ${message}`);
    }
  }

  async encrypt(input: cryptoFramework.DataBlob): Promise<cryptoFramework.DataBlob> {
    try {
      // 再次进入应用时, 需要重新获取 secretKey
      await this.getAESSecretKey();
      if (!this.cipher) {
        this.cipher = this.getCipher();
      }
      TLog.d(TAG, '加密方式: AES_CBC_PKCS7Padding');
      let ivParameterSpec: cryptoFramework.IvParamsSpec = this.getParameterSpec();
      this.cipher.initSync(cryptoFramework.CryptoMode.ENCRYPT_MODE, this.secretKey, ivParameterSpec);
      let cipherData: cryptoFramework.DataBlob = this.cipher.doFinalSync(input);
      let combined = mergeUint8Arrays(ivParameterSpec.iv.data, cipherData.data);
      return {
        data: combined
      };
    } catch (e) {
      let message = `encrypt failure: error code ${e.code} error message ${e.message}`;
      console.error(TAG, message);
      throw new Error(`${TAG} -> ${message}`);
    }
  }

  async decrypt(cipherText: cryptoFramework.DataBlob): Promise<cryptoFramework.DataBlob> {
    try {
      await this.getAESSecretKey();
      if (!this.cipher) {
        this.cipher = this.getCipher();
      }
      TLog.d(TAG, '解密方式: AES_CBC_PKCS7Padding');
      let ivParameterSpec: cryptoFramework.IvParamsSpec = this.getParameterSpec();
      let data = splitUint8Array(cipherText.data, 0, this.ivSize);
      ivParameterSpec.iv = {
        data
      };
      let cipherData = splitUint8Array(cipherText.data, this.ivSize, cipherText.data.length);
      this.cipher.initSync(cryptoFramework.CryptoMode.DECRYPT_MODE, this.secretKey, ivParameterSpec);
      let decryptData = this.cipher.doFinalSync({
        data: cipherData
      });
      return decryptData;
    } catch (e) {
      let message = `decrypt failure: error code ${e.code} error message ${e.message}`;
      console.error(TAG, message);
      throw new Error(`${TAG} -> ${message}`);
    }
  }

  protected genSymKeyByData(): cryptoFramework.SymKey {
    try {
      let aesGenerator = cryptoFramework.createSymKeyGenerator(this.KEY_ALGORITHM);
      let symKey: cryptoFramework.SymKey = aesGenerator.generateSymKeySync();
      return symKey;
    } catch (e) {
      let message = `genSymKeyByData failure: error code ${e.code} error message ${e.message}`;
      console.error(TAG, message);
      throw new Error(`${TAG} -> ${message}`);
    }
  }

  protected getParameterSpec(): cryptoFramework.IvParamsSpec {
    let ivBlob: cryptoFramework.DataBlob = this.getIvBlob();
    let ivParamsSpec: cryptoFramework.IvParamsSpec = {
      algName: "IvParamsSpec",
      iv: ivBlob
    };
    return ivParamsSpec;
  }

  getIvBlob(): cryptoFramework.DataBlob {
    try {
      return this.random.generateRandomSync(this.ivSize);
    } catch (e) {
      let message = `getIvBlob failure: error code ${e.code} error message ${e.message}`;
      console.error(TAG, message);
      throw new Error(`${TAG} -> ${message}`);
    }
  }
}