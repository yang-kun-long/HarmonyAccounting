
import { relationalStore } from '@kit.ArkData';
import AccountData from '../../../viewmodel/AccountData';
import CommonConstants from '../../constants/CommonConstants';
import Rdb from '../Rdb';

/**
 * 定义了一个管理账户数据的表格类，提供数据的增删改查操作
 */
export default class AccountTable {
  // 初始化账户表格，使用常量中定义的表格名、创建SQL和列配置
  private accountTable = new Rdb(CommonConstants.ACCOUNT_TABLE.tableName, CommonConstants.ACCOUNT_TABLE.sqlCreate,
    CommonConstants.ACCOUNT_TABLE.columns);

  /**
   * 构造函数，初始化表格存储并调用回调函数
   * @param callback 回调函数，获取RdbStore后执行
   */
  constructor(callback: Function = () => {
  }) {
    this.accountTable.getRdbStore(callback);
  }

  /**
   * 获取RdbStore实例的封装方法
   * @param callback 回调函数，获取RdbStore后执行
   */
  getRdbStore(callback: Function = () => {
  }) {
    this.accountTable.getRdbStore(callback);
  }

  /**
   * 插入数据到账户表格
   * @param account 要插入的账户数据
   * @param callback 回调函数，在数据插入完成后执行
   */
  insertData(account: AccountData, callback: Function) {
    const valueBucket: relationalStore.ValuesBucket = generateBucket(account);
    this.accountTable.insertData(valueBucket, callback);
  }

  /**
   * 从账户表格中删除数据
   * @param account 要删除的账户数据
   * @param callback 回调函数，在数据删除完成后执行
   */
  deleteData(account: AccountData, callback: Function) {
    let predicates = new relationalStore.RdbPredicates(CommonConstants.ACCOUNT_TABLE.tableName);
    predicates.equalTo('id', account.id);
    this.accountTable.deleteData(predicates, callback);
  }

  /**
   * 更新账户表格中的数据
   * @param account 要更新的账户数据
   * @param callback 回调函数，在数据更新完成后执行
   */
  updateData(account: AccountData, callback: Function) {
    const valueBucket: relationalStore.ValuesBucket = generateBucket(account);
    let predicates = new relationalStore.RdbPredicates(CommonConstants.ACCOUNT_TABLE.tableName);
    predicates.equalTo('id', account.id);
    this.accountTable.updateData(predicates, valueBucket, callback);
  }

  /**
   * 查询账户数据
   * @param amount 查询的金额，如果isAll为false，则精确查询此金额
   * @param callback 回调函数，查询完成后执行
   * @param isAll 是否查询所有数据，默认为true
   */
  query(amount: number, callback: Function, isAll: boolean = true) {
    let predicates = new relationalStore.RdbPredicates(CommonConstants.ACCOUNT_TABLE.tableName);
    if (!isAll) {
      predicates.equalTo('amount', amount);
    }
    this.accountTable.query(predicates, (resultSet: relationalStore.ResultSet) => {
      let count: number = resultSet.rowCount;
      if (count === 0 || typeof count === 'string') {
        console.log(`${CommonConstants.TABLE_TAG}` + 'Query no results!');
        callback([]);
      } else {
        resultSet.goToFirstRow();
        const result: AccountData[] = [];
        for (let i = 0; i < count; i++) {
          let tmp: AccountData = {
            id: 0, accountType: 0, typeText: '', amount: 0, time:''
          };
          tmp.id = resultSet.getDouble(resultSet.getColumnIndex('id'));
          tmp.accountType = resultSet.getDouble(resultSet.getColumnIndex('accountType'));
          tmp.typeText = resultSet.getString(resultSet.getColumnIndex('typeText'));
          tmp.amount = resultSet.getDouble(resultSet.getColumnIndex('amount'));
          tmp.time= resultSet.getString(resultSet.getColumnIndex('time'));
          result[i] = tmp;
          resultSet.goToNextRow();
        }
        callback(result);
      }
    });
  }
}

/**
 * 根据账户数据生成一个关系存储的值桶
 *
 * 此函数用于将账户数据(AccountData类型)转换为关系存储中使用的值桶(relationalStore.ValuesBucket类型)
 * 它主要通过将账户数据中的关键字段复制到值桶对象中，从而实现数据格式的转换
 *
 * @param account AccountData类型的数据，表示账户信息，包括账户类型、类型文本和金额
 * @returns 返回一个relationalStore.ValuesBucket类型的对象，该对象包含了从账户数据中复制过来的关键信息
 */
function generateBucket(account: AccountData): relationalStore.ValuesBucket {
  // 初始化一个空的值桶对象
  let obj: relationalStore.ValuesBucket = {};

  // 将账户的账户类型复制到值桶对象
  obj.accountType = account.accountType;

  // 将账户的类型文本复制到值桶对象
  obj.typeText = account.typeText;

  // 将账户的金额复制到值桶对象
  obj.amount = account.amount;

  obj.time = account.time;

  // 返回填充了账户信息的值桶对象
  return obj;
}
