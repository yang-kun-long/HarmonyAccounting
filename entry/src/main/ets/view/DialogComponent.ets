

import { promptAction } from '@kit.ArkUI';
import AccountData from '../viewmodel/AccountData';
import AccountItem from '../viewmodel/AccountItem';
import CommonConstants from '../common/constants/CommonConstants';
import { PayList, EarnList, TextList } from '../viewmodel/AccountList';


@CustomDialog
export struct DialogComponent {
  controller?: CustomDialogController;
  @Link isInsert: boolean;
  @Link newAccount: AccountData;
  confirm?: (isInsert: boolean, newAccount: AccountData) => void;
  private scroller: Scroller = new Scroller();
  private inputAmount = '';
  @State payList: Array<AccountItem> = PayList;
  @State earnList: Array<AccountItem> = EarnList;
  @State bgColor: string = '';
  @State curIndex: number = 0;
  @State curType: string = '';
  @State selectedDate: Date = new Date();
  @State inputData : string = '';

  @Builder
  /**
   * 构建选项卡界面的函数
   *
   * 该函数用于根据传入的索引值构建一个选项卡界面，索引值决定了当前显示的内容
   *
   * @param index 选项卡的索引值，用于决定显示的内容
   * @returns 返回构建的选项卡界面元素
   */
  TabBuilder(index: number) {
    // 定义一个列布局，用于容纳选项卡的文本内容
    Column() {
      // 根据索引值显示不同的文本内容，索引为0时显示支付文本，否则显示收入文本
      Text(index === 0 ? $r('app.string.pay_text') : $r('app.string.income_text'))
        // 设置文本字体大小
        .fontSize($r('app.float.font_size_M'))
        // 根据当前选项卡是否为选中状态，设置文本颜色，选中时显示主色调，否则显示灰色
        .fontColor(this.curIndex === index ? $r('app.color.main_color') : Color.Gray)
    }
    // 设置列布局的宽度
    .width($r('app.float.component_size_LM'))
    // 设置列布局的内边距，顶部和底部分别设置不同的边距值
    .padding({ top: $r('app.float.edge_size_LM'), bottom: $r('app.float.edge_size_S') })
    // 设置列布局的外边距，底部设置边距值
    .margin({ bottom: $r('app.float.edge_size_S') })
    // 设置列布局的边框，只有在当前选项卡为选中状态时，底部边框才显示，否则不显示
    .border({
      width: { bottom: this.curIndex === index ? $r('app.float.border_size_M') : '' },
      color: this.curIndex === index ? $r('app.color.main_color') : Color.White
    })
  }
  getStringTime(date:Date): string{

    let year  = date.getFullYear();
    let month = date.getMonth() + 1;
    let day   = date.getDate();
    // 周几
    let week = date.getDay();
  // 格式化为 YYYY-MM-DD 周几
    return `${year}-${month}-${day} ${CommonConstants.WEEK_LIST[week]}`;
    }
  /**
   * 显示日期选择对话框
   * 通过调用DatePickerDialog.show方法，为用户界面弹出一个日期选择器
   * 用户可以选择或者取消选择一个日期，并且这些操作会有对应的回调函数来处理
   */
  showDatePickerDialog() {
    // 初始化日期选择器，并配置其属性
    DatePickerDialog.show({
      // 设置可选日期范围的开始日期
      start: new Date('2022-1-1'),
      // 设置可选日期范围的结束日期
      end: new Date('2050-12-31'),
      // 设置默认选中的日期
      selected: this.selectedDate,
      // 设置是否显示农历日期，此处设置为不显示
      lunar: false,
      // 当用户确认选择日期时的回调函数
      onDateAccept: (value: Date) => {
        // 当用户确认选择日期后，更新选中的日期
        this.selectedDate = value;
        // 更新输入数据为用户选择的日期字符串
        this.inputData = this.getStringTime(value);
        // 打印确认选择的日期信息
        console.info('DatePickerDialog:onDateAccept()', JSON.stringify(value));
      },
      // 当用户取消选择日期时的回调函数
      onCancel: () => {
        // 打印取消选择日期的信息
        console.info('DatePickerDialog:onCancel()');
      },
      // 当用户更改选中日期时的回调函数
      onDateChange: (value: Date) => {
        // 打印更改后的选中日期信息
        console.info('DatePickerDialog:onDateChange()', JSON.stringify(value));
      }
    });
  }

  /**
   * 准备出现时更新输入金额和当前账户类型
   *
   * 该方法在组件即将出现时调用，用于更新组件的内部状态
   * 主要功能是将新账户对象中的金额和账户类型文本更新到组件的当前状态中
   */
  aboutToAppear() {
    // 将新账户的金额转换为字符串并赋值给输入金额
    this.inputAmount = this.newAccount.amount.toString();
    // 将新账户的账户类型赋值给当前索引
    this.curIndex = this.newAccount.accountType;
    // 将新账户的类型文本赋值给当前类型
    this.curType = this.newAccount.typeText;
  }


  /**
   * 选择账户类型
   *
   * 该方法用于在给定的账户项中选择一个账户类型，并将该类型的相关信息赋值给新账户对象
   * 主要用于在用户选择了一个特定的账户类型后，更新新账户对象的类型信息
   *
   * @param item 被选中的账户项，包含账户类型和类型文本
   */
  selectAccount(item: AccountItem) {
    // 将选中项的账户类型赋值给新账户的账户类型
    this.newAccount.accountType = item.accountType;
    // 将选中项的类型文本赋值给新账户的类型文本
    this.newAccount.typeText = item.typeText;
    // 更新当前选择的类型文本
    this.curType = item.typeText;
  }

  // 构建方法，用于创建和配置用户界面组件
  build() {
    // 定义一个列组件，包含一个图像，并且点击该图像可以关闭当前控制器
    Column() {
      // 加载并显示一个名为'half.png'的图像
      Image($rawfile('half.png'))// 设置图像的宽度
        .width($r('app.float.component_size_L'))// 设置图像的高度
        .height($r('app.float.component_size_S'))// 当图像被点击时，关闭当前控制器（如果存在）
        .onClick(() => {
          this.controller?.close();
        })


      /**
       * 创建一个标签页组件，用于展示不同类型的账户信息
       * @param {Object} props - 组件属性对象
       * @param {number} props.index - 当前激活的标签页索引
       * @param {string[]} props.payList - 支付账户列表
       * @param {string[]} props.earnList - 收入账户列表
       * @param {function} props.selectAccount - 选择账户时的回调函数
       * @param {function} props.TabBuilder - 用于构建标签栏的函数
       */
      Tabs({ barPosition: BarPosition.Start, index: this.curIndex }) {
        // 构建第一个标签页的内容，展示支付账户信息
        TabContent() {
          Scroll(this.scroller) {
            Row() {
              ForEach(this.payList, (item: AccountItem) => {
                Column() {
                  // 根据当前选中的类型决定显示哪个图标
                  Image(this.curType === item.typeText ? item.iconSelected : item.icon)
                    .width($r('app.float.image_size'))
                    .aspectRatio(CommonConstants.FULL_SIZE)

                  // 显示账户类型的文本，高亮当前选中的类型
                  Text(TextList[item.typeText])
                    .fontSize($r('app.float.font_size_S'))
                    .fontColor(this.curType === item.typeText ? Color.White : $r('app.color.main_color'))
                    .margin({ top: $r('app.float.edge_size_S') })
                }
                .width($r('app.float.component_size_LP'))
                .aspectRatio(CommonConstants.FULL_SIZE)
                .padding({ top: $r('app.float.edge_size_M') })
                .margin({ top: $r('app.float.edge_size_MP'), left: $r('app.float.edge_size_M') })
                .align(Alignment.TopStart)
                .backgroundColor(this.curType === item.typeText ? $r('app.color.main_color') :
                $r('app.color.background_color'))
                .borderRadius($r('app.float.radius_size_S'))
                .onClick(() => {
                  this.selectAccount(item);
                })
              })
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
        }
        .tabBar(this.TabBuilder(0))
        .margin({ bottom: $r('app.float.edge_size_LP') })

        // 构建第二个标签页的内容，展示收入账户信息
        TabContent() {
          Scroll(this.scroller) {
            Row() {
              ForEach(this.earnList, (item: AccountItem) => {
                Column() {
                  // 根据当前选中的类型决定显示哪个图标
                  Image(this.curType === item.typeText ? item.iconSelected : item.icon)
                    .width($r('app.float.image_size'))
                    .aspectRatio(CommonConstants.FULL_SIZE)

                  // 显示账户类型的文本，高亮当前选中的类型
                  Text(TextList[item.typeText])
                    .fontSize($r('app.float.font_size_S'))
                    .fontColor(this.curType === item.typeText ? Color.White : $r('app.color.main_color'))
                    .margin({ top: $r('app.float.edge_size_S') })
                }
                .width($r('app.float.component_size_LP'))
                .aspectRatio(CommonConstants.FULL_SIZE)
                .padding({ top: $r('app.float.edge_size_M') })
                .margin({ top: $r('app.float.edge_size_MP'), left: $r('app.float.edge_size_M') })
                .align(Alignment.TopStart)
                .backgroundColor(this.curType === item.typeText ? $r('app.color.main_color') :
                $r('app.color.background_color'))
                .borderRadius($r('app.float.radius_size_S'))
                .onClick(() => {
                  this.selectAccount(item);
                })
              })
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
        }
        // 设置底部标签栏，参数为1表示这是标签栏的第1个子项
        .tabBar(this.TabBuilder(1))
        // 设置底部边距为全局浮动物体边缘大小的LP值，以确保不会与底部其他元素重叠
        .margin({ bottom: $r('app.float.edge_size_LP') })
      }
      // 设置宽度为全屏宽度
      .width(CommonConstants.FULL_WIDTH)
      // 设置高度为标签栏的标准高度
      .height(CommonConstants.TABS_HEIGHT)
      // 设置为水平方向，因为默认就是水平方向，所以这里主要是为了强调或未来可能的改变预留
      .vertical(false)
      // 设置标签栏模式为固定模式，以确保在滚动时标签栏保持不动
      .barMode(BarMode.Fixed)
      // 当标签切换时触发onChange回调，更新当前标签索引
      .onChange((index) => {
        // 将当前索引设置为切换到的标签索引
        this.curIndex = index;
      })

      // 创建一个Column组件，用于布局文本和输入框
      Column() {
        // 显示一个文本，说明输入框的用途
        Text($r('app.string.count_text'))
          .width(CommonConstants.FULL_WIDTH)
          .fontSize($r('app.float.font_size_MP'))
          .fontColor(Color.Black)

        // 创建一个嵌套的Column组件，用于布局TextInput
        Column() {
          // 提供一个文本输入框，允许用户输入数字
          TextInput({
            placeholder: $r('app.string.input_text'), // 输入框的提示文本
            text: this.newAccount.amount === 0 ? this.inputAmount : this.newAccount.amount.toString() // 输入框的默认文本
          })
            .padding({
              left: CommonConstants.MINIMUM_SIZE,
              top: CommonConstants.MINIMUM_SIZE,
              bottom: CommonConstants.MINIMUM_SIZE
            })
            .borderRadius(CommonConstants.MINIMUM_SIZE)
            .backgroundColor(Color.White)
            .type(InputType.Number)// 设置输入类型为数字
            .onChange((value: string) => { // 输入值变化时的处理函数
              this.inputAmount = value;
            })


        }

        Text($r('app.string.Time'))
          .width(CommonConstants.FULL_WIDTH)
          .fontSize($r('app.float.font_size_MP'))
          .fontColor(Color.Black)
        // 创建一个列布局
        Column() {
          // 根据条件显示不同的文本内容
          Text(
            // 如果inputData为空，则显示格式化后的selectedDate时间，否则显示inputData的内容
            this.inputData===''?this.getStringTime(this.selectedDate):this.inputData
          )
          // 为文本内容添加内边距
          .padding({
            // 定义内边距的左、上、下边距为CommonConstants.MINIMUM_SIZE
            left: CommonConstants.MINIMUM_SIZE,
            top: CommonConstants.MINIMUM_SIZE,
            bottom: CommonConstants.MINIMUM_SIZE
          })
          // 设置文本内容的圆角
          .borderRadius(CommonConstants.MINIMUM_SIZE)
          // 设置文本内容的背景颜色为白色
          .backgroundColor(Color.White)
          // 设置点击事件处理函数
          .onClick(() => {
            // 当文本被点击时，显示日期选择对话框
            this.showDatePickerDialog();
          })
        }

      }
      .width(CommonConstants.FULL_WIDTH) // 设置外层Column组件的宽度
      .padding({
        // 设置外层Column组件的外边距
        left: $r('app.float.edge_size_M'),
        right: $r('app.float.edge_size_M')
      })

      /**
       * 创建一个确认按钮，用于在界面中确认操作
       * 该按钮根据当前的语言资源文件设置确认文本，并在点击时执行确认逻辑
       * 如果账户类型文本为空或当前索引与新账户的账户类型不匹配，则显示提示信息
       * 如果输入的金额符合正则表达式规则，则将金额赋值给新账户，并调用确认回调（如果存在）
       * 最后，关闭控制器
       */
      Column() {
        Button() {
          Text($r('app.string.confirm_text'))
            .fontSize($r('app.float.font_size_M'))
            .fontColor(Color.White)
        }
        .width(CommonConstants.FULL_WIDTH)
        .height($r('app.float.component_size_M'))
        .onClick(() => {
          // 检查账户类型文本是否为空或当前索引与账户类型不匹配
          if (this.newAccount.typeText === '' || this.curIndex !== this.newAccount.accountType) {
            promptAction.showToast({ message: CommonConstants.TOAST_TEXT_1, bottom: CommonConstants.PROMPT_BOTTOM });
          } else {
            // 创建一个正则表达式来匹配有效的金额输入
            let regex: RegExp = new RegExp('[1-9][0-9]*');
            // 检查输入的金额是否符合正则表达式规则
            let matchValue: Array<string> | null = this.inputAmount.match(regex);
            if (matchValue !== null && matchValue[0] === this.inputAmount) {
              // 将输入的金额转换为数字并赋值给新账户
              this.newAccount.amount = Number(this.inputAmount);
              // 将时间字段设置为当前时间
              this.newAccount.time = (this.inputData===''?this.getStringTime(this.selectedDate):this.inputData);

              // 如果存在确认回调，则执行确认逻辑，并传入插入标志和新账户对象
              this.confirm && this.confirm(this.isInsert, this.newAccount);
              // 关闭控制器
              this.controller?.close();
            } else {
              // 如果输入的金额不符合规则，则显示提示信息
              promptAction.showToast({ message: CommonConstants.TOAST_TEXT_2, bottom: CommonConstants.PROMPT_BOTTOM });
            }
          }
        })
      }
      
      // 设置布局权重为充满整个屏幕
      .layoutWeight(CommonConstants.FULL_SIZE)
      // 设置底部、左边和右边的内边距为字体大小L
      .padding({
        bottom: $r('app.float.font_size_L'),
        left: $r('app.float.font_size_L'),
        right: $r('app.float.font_size_L')
      })
      // 设置内容对齐方式为末尾对齐
      .justifyContent(FlexAlign.End)
    }
    // 设置宽度为充满整个屏幕
    .width(CommonConstants.FULL_WIDTH)
    // 设置高度为对话框标准高度
    .height(CommonConstants.DIALOG_HEIGHT)
    // 设置圆角边框，只在顶部的左右两个角有圆角
    .borderRadius({ topLeft: $r('app.float.font_size_L'), topRight: $r('app.float.font_size_L') })
    // 设置背景颜色为白色
    .backgroundColor(Color.White)
    // 设置对齐方式为屏幕的右下角
    .align(Alignment.BottomEnd)
  }
}
