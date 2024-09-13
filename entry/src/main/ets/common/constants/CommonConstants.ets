

import { relationalStore } from '@kit.ArkData';
import { AccountTable } from '../../viewmodel/ConstantsInterface';

/**
 * 提供常用配置常量的类。
 */
export default class CommonConstants {
  /**
   * RDB 数据库配置。
   */
  static readonly STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'database.db',
    securityLevel: relationalStore.SecurityLevel.S1
  };
  static WEEK_LIST = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];

  /**
   * 账户表配置。
   */
  static readonly ACCOUNT_TABLE: AccountTable = {
    tableName: 'accountTable',
    sqlCreate: 'CREATE TABLE IF NOT EXISTS accountTable(id INTEGER PRIMARY KEY AUTOINCREMENT, accountType INTEGER, ' +
      'typeText TEXT, amount INTEGER,time TEXT)',
    columns: ['id', 'accountType', 'typeText', 'amount', 'time']
  };

  /**
   * 搜索组件的搜索文本。
   */
  static readonly SEARCH_TEXT = $r('app.string.search');

  /**
   * 提示组件的 Toast 文本。
   */
  static readonly TOAST_TEXT_1 = $r('app.string.TOAST_TEXT_1');
  static readonly TOAST_TEXT_2 = $r('app.string.TOAST_TEXT_2');

  /**
   * 组件尺寸配置。
   */
  static readonly FULL_WIDTH = '100%';
  static readonly HALF_WIDTH = '50%';
  static readonly FULL_HEIGHT = '100%';
  static readonly DIALOG_HEIGHT = '55%';
  static readonly TABS_HEIGHT = '45%';
  static readonly MINIMUM_SIZE = 0;
  static readonly FULL_SIZE = 1;
  static readonly PROMPT_BOTTOM = '70vp';
  static readonly TOP_WIDTH = '33%';

  /**
   * 组件位置配置。
   */
  static readonly EDIT_POSITION_X = '80%';
  static readonly EDIT_POSITION_Y = '90%';
  static readonly DELETE_POSITION_X = '50%';
  static readonly DELETE_POSITION_Y = '90%';

  /**
   * 日志标签配置。
   */
  static readonly RDB_TAG = '[Debug.Rdb]';
  static readonly TABLE_TAG = '[Debug.AccountTable]';
  static readonly INDEX_TAG = '[Debug.Index]';
}
