import { Log } from "@ohos/flutter_ohos";

const isPrint: boolean = false; // 是否打印日志

export default class TLog {
  /**
   * Outputs debug-level logs.
   *
   * @param tag Identifies the log tag.
   * @param format Indicates the log format string.
   * @param args Indicates the log parameters.
   * @since 7
   */
  static d(tag: string, format: string, ...args: Object[]) {
    if (isPrint) {
      Log.d(tag, format, args);
    }
  }

  /**
   * Outputs info-level logs.
   *
   * @param tag Identifies the log tag.
   * @param format Indicates the log format string.
   * @param args Indicates the log parameters.
   * @since 7
   */
  static i(tag: string, format: string, ...args: Object[]) {
    if (isPrint) {
      Log.i(tag, format, args);
    }
  }

  /**
   * Outputs warning-level logs.
   *
   * @param tag Identifies the log tag.
   * @param format Indicates the log format string.
   * @param args Indicates the log parameters.
   * @since 7
   */
  static w(tag: string, format: string, ...args: Object[]) {
    if (isPrint) {
      Log.w(tag, format, args);
    }
  }

  /**
   * Outputs error-level logs.
   *
   * @param tag Identifies the log tag.
   * @param format Indicates the log format string.
   * @param args Indicates the log parameters.
   * @since 7
   */
  static e(tag: string, format: string, ...args: Object[]) {
    if (isPrint) {
      Log.e(tag, format, args);
    }
  }

  /**
   * Outputs fatal-level logs.
   *
   * @param tag Identifies the log tag.
   * @param format Indicates the log format string.
   * @param args Indicates the log parameters.
   * @since 7
   */
  static f(tag: string, format: string, ...args: Object[]) {
    if (isPrint) {
      Log.f(tag, format, args);
    }
  }
}