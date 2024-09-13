

import { relationalStore } from '@kit.ArkData';
import CommonConstants from '../constants/CommonConstants';
import Logger from '../utils/Logger';

/**
 * Rdb类用于操作关系型数据库
 */
export default class Rdb {
  private rdbStore: relationalStore.RdbStore | null = null; // 存储RdbStore实例
  private tableName: string; // 数据库表名
  private sqlCreateTable: string; // 创建表的SQL语句
  private columns: Array<string>; // 表的列名数组

  /**
   * 构造函数，初始化数据库表名、创建表的SQL语句和列名数组
   * @param tableName 表名
   * @param sqlCreateTable 创建表的SQL语句
   * @param columns 列名数组
   */
  constructor(tableName: string, sqlCreateTable: string, columns: Array<string>) {
    this.tableName = tableName;
    this.sqlCreateTable = sqlCreateTable;
    this.columns = columns;
  }

  /**
   * 获取RdbStore实例
   * @param callback 回调函数，当RdbStore实例创建完成时被调用
   */
  getRdbStore(callback: Function = () => {
  }) {
    // 检查回调函数是否有效
    if (!callback || typeof callback === 'undefined' || callback === undefined) {
      Logger.info(CommonConstants.RDB_TAG, 'getRdbStore() has no callback!');
      return;
    }
    // 如果rdbStore实例已经存在，则直接调用回调函数
    if (this.rdbStore !== null) {
      Logger.info(CommonConstants.RDB_TAG, 'The rdbStore exists.');
      callback();
      return
    }
    // 获取上下文并使用relationalStore.getRdbStore方法获取RdbStore实例
    let context: Context = getContext(this) as Context;
    relationalStore.getRdbStore(context, CommonConstants.STORE_CONFIG, (err, rdb) => {
      if (err) {
        Logger.error(CommonConstants.RDB_TAG, `gerRdbStore() failed, err: ${err}`);
        return;
      }
      // 设置rdbStore实例并执行创建表的SQL语句
      this.rdbStore = rdb;
      this.rdbStore.executeSql(this.sqlCreateTable);
      Logger.info(CommonConstants.RDB_TAG, 'getRdbStore() finished.');
      callback();
    });
  }

  /**
   * 插入数据
   * @param data 要插入的数据
   * @param callback 回调函数，当数据插入完成时被调用，参数为插入结果
   */
  insertData(data: relationalStore.ValuesBucket, callback: Function = () => {
  }) {
    // 检查回调函数是否有效
    if (!callback || typeof callback === 'undefined' || callback === undefined) {
      Logger.info(CommonConstants.RDB_TAG, 'insertData() has no callback!');
      return;
    }
    let resFlag: boolean = false;
    const valueBucket: relationalStore.ValuesBucket = data;
    // 如果rdbStore实例存在，则调用insert方法插入数据
    if (this.rdbStore) {
      this.rdbStore.insert(this.tableName, valueBucket, (err, ret) => {
        if (err) {
          Logger.error(CommonConstants.RDB_TAG, `insertData() failed, err: ${err}`);
          callback(resFlag);
          return;
        }
        Logger.info(CommonConstants.RDB_TAG, `insertData() finished: ${ret}`);
        callback(ret);
      });
    }
  }

  /**
   * 删除数据
   * @param predicates 删除条件
   * @param callback 回调函数，当数据删除成功时被调用，参数为删除结果
   */
  deleteData(predicates: relationalStore.RdbPredicates, callback: Function = () => {
  }) {
    // 检查回调函数是否有效
    if (!callback || typeof callback === 'undefined' || callback === undefined) {
      Logger.info(CommonConstants.RDB_TAG, 'deleteData() has no callback!');
      return;
    }
    let resFlag: boolean = false;
    // 如果rdbStore实例存在，则调用delete方法删除数据
    if (this.rdbStore) {
      this.rdbStore.delete(predicates, (err, ret) => {
        if (err) {
          Logger.error(CommonConstants.RDB_TAG, `deleteData() failed, err: ${err}`);
          callback(resFlag);
          return;
        }
        Logger.info(CommonConstants.RDB_TAG, `deleteData() finished: ${ret}`);
        callback(!resFlag);
      });
    }
  }

  /**
   * 更新数据
   * @param predicates 更新条件
   * @param data 要更新的数据
   * @param callback 回调函数，当数据更新完成时被调用，参数为更新结果
   */
  updateData(predicates: relationalStore.RdbPredicates, data: relationalStore.ValuesBucket, callback: Function = () => {
  }) {
    // 检查回调函数是否有效
    if (!callback || typeof callback === 'undefined' || callback === undefined) {
      Logger.info(CommonConstants.RDB_TAG, 'updateDate() has no callback!');
      return;
    }
    let resFlag: boolean = false;
    const valueBucket: relationalStore.ValuesBucket = data;
    // 如果rdbStore实例存在，则调用update方法更新数据
    if (this.rdbStore) {
      this.rdbStore.update(valueBucket, predicates, (err, ret) => {
        if (err) {
          Logger.error(CommonConstants.RDB_TAG, `updateData() failed, err: ${err}`);
          callback(resFlag);
          return;
        }
        Logger.info(CommonConstants.RDB_TAG, `updateData() finished: ${ret}`);
        callback(!resFlag);
      });
    }
  }

  /**
   * 查询数据
   * @param predicates 查询条件
   * @param callback 回调函数，当数据查询完成时被调用，参数为查询结果集
   */
  query(predicates: relationalStore.RdbPredicates, callback: Function = () => {
  }) {
    // 检查回调函数是否有效
    if (!callback || typeof callback === 'undefined' || callback === undefined) {
      Logger.info(CommonConstants.RDB_TAG, 'query() has no callback!');
      return;
    }
    // 如果rdbStore实例存在，则调用query方法查询数据
    if (this.rdbStore) {
      this.rdbStore.query(predicates, this.columns, (err, resultSet) => {
        if (err) {
          Logger.error(CommonConstants.RDB_TAG, `query() failed, err:  ${err}`);
          return;
        }
        Logger.info(CommonConstants.RDB_TAG, 'query() finished.');
        callback(resultSet);
        resultSet.close();
      });
    }
  }
}
