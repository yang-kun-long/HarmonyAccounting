import AccountTable from '../common/database/tables/AccountTable';
import AccountData from '../viewmodel/AccountData';
import WeekData from '../viewmodel/MonthData';
import CommonConstants from '../common/constants/CommonConstants';
import { DialogComponent } from '../view/DialogComponent';
import { ImageList, TextList } from '../viewmodel/AccountList';
import Logger from '../common/utils/Logger';
import { McBarChart,McPieChart, Options } from '@mcui/mccharts';

@Entry
@Component
struct MainPage {
  @State accounts: Array<AccountData> = [];
  @State searchText: string = '';
  @State isEdit: boolean = false;
  @State isInsert: boolean = false;
  @State newAccount: AccountData = { id: 0, accountType: 0, typeText: '', amount: 0 ,time: ''};
  @State index: number = -1;
  @State selctedYear: string = new Date().getFullYear().toString();
  @State selctedMonth: string = (new Date().getMonth()+1).toString();
  @State haveWeekData : boolean = true;
  private AccountTable = new AccountTable(() => {});
  private deleteList: Array<AccountData> = [];
  searchController: SearchController = new SearchController();
  // 初始化对话框控制器，用于控制自定义对话框的显示和隐藏
  dialogController: CustomDialogController = new CustomDialogController({
    // 使用DialogComponent构建对话框，传递是否为插入操作和新账户数据
    builder: DialogComponent({
      isInsert: $isInsert,
      newAccount: $newAccount,
      // 定义对话框确认按钮的点击事件处理函数
      confirm: (isInsert: boolean, newAccount: AccountData) => this.accept(isInsert, newAccount)
    }),
    // 设置对话框的样式为自定义样式
    customStyle: true,
    // 设置对话框的对齐方式为底部对齐
    alignment: DialogAlignment.Bottom
  });
  /**
   * 处理账户的插入或更新
   * @param isInsert 指示是插入还是更新账户，true为插入，false为更新
   * @param newAccount 要插入或更新的账户数据
   */
  accept(isInsert: boolean, newAccount: AccountData): void {
    if (isInsert) {
      // 当插入新账户时，记录日志并插入数据
      Logger.info(`${CommonConstants.INDEX_TAG}`, `The account inserted is:  ${JSON.stringify(newAccount)}`);
      this.AccountTable.insertData(newAccount, (id: number) => {
        newAccount.id = id;
        this.accounts.push(newAccount);
      });
    } else {
      // 当更新账户时，先更新数据，然后重置accounts数组和index
      this.AccountTable.updateData(newAccount, () => {
      });
      let list = this.accounts;
      this.accounts = [];
      list[this.index] = newAccount;
      this.accounts = list;
      this.index = -1;
    }
  }
  /**
   * 在组件即将出现时执行的操作。
   * 此方法用于在组件出现之前获取并设置账户数据。
   */
  aboutToAppear() {
    // 获取RDB存储，回调函数中将执行对数据库的操作
    this.AccountTable.getRdbStore(() => {
      // 查询账户数据，从0开始，返回所有匹配的结果
      this.AccountTable.query(0, (result: AccountData[]) => {
        // 将查询结果赋值给accounts属性
        this.accounts = result;
      }, true);
    });
  }
  // 参数：字符串时间，"2024-09-11 10:18:19"
  // 返回值，返回周几，以及今年第几周



  // 获取一个月内的数据，并按照账户类型进行分组，并计算每个分组的总金额

  slectMonthData(date:string,y:string,m:string): number{
    date=date.split(' ')[0];
    let year = date.split('-')[0];
    let month = date.split('-')[1];
    if(year==y&&month==m)
      return 0;
    else if(year==y)
      return 1;
    else
      return 2;
  }

  getSourceString(name:string): string {
    return getContext(this).resourceManager.getStringByNameSync(name).toString();
  }
  getWeekData(y:string,m:string): Options {
    let weekdatas: Array<WeekData> = [];

    for (const item of this.accounts) {
      if(this.slectMonthData(item.time,y,m)!=0)
        continue;
      if(item.accountType==1)
        continue;
      // 如果item.typeText不在数据weekdata中，则创建一个新对象，并设置其name和value属性
      let weekdata = weekdatas.find((data: WeekData) => data.name == this.getSourceString(item.typeText));
      if (!weekdata) {
        weekdata = {name: '', value: 0};
        weekdata.name = this.getSourceString(item.typeText);
        weekdata.value = item.amount;
        weekdatas.push(weekdata);
      }
      else {
        // 将item.amount加到weekdata.value上
        weekdata.value += item.amount;
      }
    }
    let defOption: Options = new Options({
      legend: {
        show: true,
        left: '50%',
        top: '2%',
        itemGap: 10,
        itemTextGap: 10,
        itemWidth: 8,
        itemHeight: 8,
        textStyle: {
          color: '#000',
          fontWeight: 'normal',
          fontFamily: 'sans-serif',
          fontSize: 40
        }
      },
      tooltip: {
        borderColor: '#f72659f5',
        borderWidth: 1,
        backgroundColor: '#fff',
        textStyle: { // 文本样式配置
          color: '#000'
        }
      },
      title:{
        show:true,
        text:this.getSourceString('bing_title'),
        textStyle:{
          color:'#fff',
          fontSize:20,

        },
        subtext:this.getSourceString('bing_subtitle'),
        subtextStyle:{
          color:'#fff',
          fontSize:14,
        }
      },
      series:[
        {
          data:weekdatas,
          label:{
            show:true,
            fontSize:64,
          }
        }
      ]
    })
    if(weekdatas.length==0)
      this.haveWeekData = false;
    else
      this.haveWeekData = true;
    return defOption ;
  }


  /**
   * 选择列表项
   *
   * 此方法用于处理列表项选择逻辑它在选择一个账户数据后，
   * 准备将这个数据应用到某个操作中这里主要是通过设置类内部状态，
   * 来指示一个现有条目被选中，并且保存这个条目的所有相关信息
   *
   * @param item 被选中的列表项，类型为 AccountData，包含账户的所有必要信息
   */
  selectListItem(item: AccountData) {
    // 设置插入标志为 false，表示当前操作不是插入新条目
    this.isInsert = false;

    // 查找当前选中项在账户列表中的索引
    this.index = this.accounts.indexOf(item);

    // 复制选中项的数据到新账户对象
    // 这样可以确保操作现有数据时不会直接修改原始数据源
    this.newAccount = {
      id: item.id, // 账户ID
      accountType: item.accountType, // 账户类型
      typeText: item.typeText, // 账户类型的文本表示
      amount: item.amount, // 账户金额
      time: item.time // 账户操作时间
    };
  }

  /**
   * 删除列表项
   *
   * 遍历并删除待删除列表中的每个项。首先找到项在总列表中的索引，然后使用splice方法将其移除，
   * 同时调用AccountTable的deleteData方法来删除项。最后清空待删除列表，并设置编辑状态为false。
   */
  deleteListItem() {
    // 遍历待删除列表
    for (let i = 0; i < this.deleteList.length; i++) {
      // 找到当前项在总列表中的索引
      let index = this.accounts.indexOf(this.deleteList[i]);
      // 从总列表中移除该项
      this.accounts.splice(index, 1);
      // 调用AccountTable的deleteData方法删除项，不需处理回调结果
      this.AccountTable.deleteData(this.deleteList[i], () => {
      });
    }
    // 清空待删除列表
    this.deleteList = [];
    // 设置编辑状态为false
    this.isEdit = false;
  }

  lastMonth(){
    if (this.selctedMonth==='1'){
      this.selctedMonth='12';
      this.selctedYear=String(Number(this.selctedYear)-1);
    }
    else{
      this.selctedMonth=String(Number(this.selctedMonth)-1);
    }
    this.setHaveWeekData();
  }
  nextMonth(){
    if (this.selctedMonth==='12'){
      this.selctedMonth='1';
      this.selctedYear=String(Number(this.selctedYear)+1);
    }
    else{
      this.selctedMonth=String(Number(this.selctedMonth)+1);
    }
    this.setHaveWeekData();
  }
  setHaveWeekData():boolean{
    this.getWeekData(this.selctedYear,this.selctedMonth);

    return this.haveWeekData;

  }

  getMonthData(y:string): Options {
    let monthPaydatas: Array<number> = [];
    let monthIncomedatas: Array<number> = [];
    for (let i=0;i<12;i++){
      monthPaydatas.push(0);
      monthIncomedatas.push(0);
    }
    for (const item of this.accounts) {
      if (this.slectMonthData(item.time,y,this.selctedMonth)==2)
        continue;
      let month = Number(item.time.split('-')[1]);
      if (item.accountType==0)
        monthPaydatas[month-1]+=item.amount;
      else if(item.accountType==1)
        monthIncomedatas[month-1]+=item.amount;
    }
    let defOption: Options = new Options({
      legend:{
        show:true,
        left:'50%',
        top:'2%',
        itemGap:10,
        itemWidth:8,
        itemHeight:8,
        textStyle:{
          color:'#000',
          fontWeight:'normal',
          fontFamily:'sans-serif',
          fontSize:40
        }
      },
      xAxis:{
        type:'category',
        axisLabel :{
          fontSize:40
        },
        data:this.getSourceString('month_list').split('-'),

      },
      yAxis:{
        type:'value',
        name:this.getSourceString('amount'),
        nameTextStyle:{
          color:'#000',
          fontSize:40,
        }
      },
      // dataZoom: {
      //   show: true,
      //   start: 3,
      //   end: 8
      // },
      title:{
        show:true,
        text:this.selctedYear+this.getSourceString('month_title'),
        textStyle:{
          color:'#fff',
          fontSize:20,

        },
        subtext:this.getSourceString('month_subtitle'),
        subtextStyle:{
          color:'#fff',
          fontSize:14,
        }
      },
      series:[
        {
          name:this.getSourceString('month_pay'),
          data:monthPaydatas,
          label:{
            show:true,
            fontSize:40,
          }
        }
        ,{
          name:this.getSourceString('month_income'),
          data:monthIncomedatas,
          label:{
            show:true,
            fontSize:10,
          }
        }
      ],
      tooltip:{
        borderColor:'#f72659f5',
        borderWidth:1,
        backgroundColor:'#fff',
        textStyle:{
          color:'#000',
          fontSize:18,
        }
      }
    })
    return defOption;
  }

  @State currentIndex: number = 0;
  private tabsController: TabsController = new TabsController();
  @Builder
  tabBarBuilder(title: string, targetIndex: number, selectedIcon: Resource, unselectIcon: Resource) {
    Column() {
      Image(this.currentIndex === targetIndex ? selectedIcon : unselectIcon)
        .width(24)
        .height(24)
      Text(title)
        .fontFamily('HarmonyHeiTi-Medium')
        .fontSize(10)
        .fontColor(this.currentIndex === targetIndex ? '#0A59F7' : 'rgba(0,0,0,0.60)')
        .textAlign(TextAlign.Center)
        .lineHeight(14)
        .fontWeight(500)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.currentIndex = targetIndex;
      this.tabsController.changeIndex(targetIndex);
    })
  }


  @State isActive: boolean = true;



  // 构建用户界面的主要函数
  build() {
    // 初始化一个堆栈布局，用于组织和展示UI组件

    Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
      TabContent() {
        Stack() {
          // 使用列布局来安排UI组件，使其在垂直方向排列
          Column() {
            // 使用行布局来安排UI组件，使其在水平方向排列
            Row() {
              // 创建一个文本组件，显示主标题
              Text($r('app.string.MainAbility_label'))
                // 设置文本组件的高度
                .height($r('app.float.component_size_SP'))
                  // 设置文本组件的字体大小
                .fontSize($r('app.float.font_size_L'))
                  // 在文本组件的左侧添加边距
                .margin({ left: $r('app.float.font_size_L') })

              // 创建一个图像组件，用于显示编辑图标
              Image($rawfile('ic_public_edit.svg'))
                // 设置图像组件的宽度
                .width($r('app.float.component_size_S'))
                  // 设置图像组件的宽高比例
                .aspectRatio(CommonConstants.FULL_SIZE)
                  // 在图像组件的右侧添加边距
                .margin({ right: $r('app.float.font_size_L') })
                  // 为图像组件添加点击事件处理函数，当用户点击时切换编辑模式
                .onClick(() => {
                  this.isEdit = true;
                })
            }

            // 设置组件的宽度为屏幕宽度
            .width(CommonConstants.FULL_WIDTH)
            // 设置组件内容的水平对齐方式为两端对齐
            .justifyContent(FlexAlign.SpaceBetween)
            // 设置组件的上边距和下边距
            .margin({ top: $r('app.float.edge_size_M'), bottom: $r('app.float.edge_size_MM') })

            /**
             * 构建并返回一个搜索框组件
             * 该方法配置了搜索框的属性，如占位符文本、控制器等，并设置了宽度、边框圆角、边框宽度、边框颜色、占位符字体、文本字体和背景颜色
             * 同时实现了搜索框的onChange和onSubmit事件处理，根据用户输入更新搜索文本，并根据搜索值查询账户数据
             */
            Row() {
              // 配置搜索框的属性并绑定事件处理函数
              Search({
                value: this.searchText,
                placeholder: CommonConstants.SEARCH_TEXT,
                controller: this.searchController
              })
                .width(CommonConstants.FULL_WIDTH) // 设置搜索框的宽度
                .borderRadius($r('app.float.radius_size_M')) // 设置边框圆角大小
                .borderWidth($r('app.float.border_size_S')) // 设置边框宽度
                .borderColor($r('app.color.border_color')) // 设置边框颜色
                .placeholderFont({ size: $r('app.float.font_size_M') }) // 设置占位符字体大小
                .textFont({ size: $r('app.float.font_size_M') }) // 设置文本字体大小
                .backgroundColor(Color.White) // 设置背景颜色为白色
                .onChange((searchValue: string) => {
                  this.searchText = searchValue; // 当搜索内容变化时，更新搜索文本
                })
                .onSubmit((searchValue: string) => {
                  // 当提交搜索时，根据搜索值查询账户数据
                  if (searchValue === '') {
                    // 如果搜索值为空，查询所有账户数据
                    this.AccountTable.query(0, (result: AccountData[]) => {
                      this.accounts = result; // 更新账户数据列表
                    }, true);
                  } else {
                    // 如果搜索值不为空，根据搜索值查询账户数据
                    this.AccountTable.query(Number(searchValue), (result: AccountData[]) => {
                      this.accounts = result; // 更新账户数据列表
                    }, false);
                  }
                })
            }
            // 设置行的宽度、内边距和外边距
            .width(CommonConstants.FULL_WIDTH)
            .padding({ left: $r('app.float.edge_size_M'), right: $r('app.float.edge_size_M') })
            .margin({ top: $r('app.float.edge_size_S'), bottom: $r('app.float.edge_size_S') })

            // 创建一个行布局
            Row() {
              // 创建一个列表，设置元素间距为FULL_SIZE
              List({ space: CommonConstants.FULL_SIZE }) {
                // 遍历账户数据数组，为每个账户创建一个列表项
                ForEach(this.accounts, (item: AccountData) => {
                  // 创建一个列表项
                  ListItem() {
                    // 创建一个行布局来容纳列表项内的各个元素
                    Row() {
                      // 根据账户类型加载图像，并设置宽度、高宽比和右侧边距
                      Image(ImageList[item.typeText])
                        .width($r('app.float.component_size_M'))
                        .aspectRatio(CommonConstants.FULL_SIZE)
                        .margin({ right: $r('app.float.edge_size_MP') })

                      // 显示账户类型的文本描述，并设置高度、字体大小和右侧边距
                      Text(TextList[item.typeText])
                        .height($r('app.float.component_size_SM'))
                        .fontSize($r('app.float.font_size_M'))

                      // 添加一个空白区域，用于布局权重调整
                      Blank()
                        .layoutWeight(1)

                      // 根据是否编辑模式，显示不同的内容
                      if (!this.isEdit) {
                        // 非编辑模式下显示账户金额和时间，颜色根据账户类型变化
                        Text(item.accountType === 0 ? '-' + item.amount.toString(): '+' + item.amount.toString())
                          .fontSize($r('app.float.font_size_M'))
                          .fontColor(item.accountType === 0 ? $r('app.color.pay_color') : $r('app.color.main_color'))
                          .align(Alignment.End)
                          .flexGrow(CommonConstants.FULL_SIZE)
                      } else {
                        // 编辑模式下显示选择框
                        Row() {
                          Toggle({ type: ToggleType.Checkbox })
                            .onChange((isOn) => {
                              // 当选择状态变化时，更新待删除列表
                              if (isOn) {
                                this.deleteList.push(item);
                              } else {
                                let index = this.deleteList.indexOf(item);
                                this.deleteList.splice(index, 1);
                              }
                            })
                        }
                        .align(Alignment.End)
                        .flexGrow(CommonConstants.FULL_SIZE)
                        .justifyContent(FlexAlign.End)
                      }

                    }
                    // 设置列表项的宽度、内边距，并绑定点击事件
                    .width(CommonConstants.FULL_WIDTH)
                    .padding({ left: $r('app.float.edge_size_M'), right: $r('app.float.edge_size_M') })
                    .onClick(() => {
                      this.selectListItem(item);
                      this.dialogController.open();
                    })
                  }
                  .width(CommonConstants.FULL_WIDTH)
                  .height($r('app.float.component_size_LM'))
                })
              }
              .width(CommonConstants.FULL_WIDTH)
              .borderRadius($r('app.float.radius_size_L'))
              .backgroundColor(Color.White)
            }
            // 设置外部布局的宽度、内边距和上边距
            .width(CommonConstants.FULL_WIDTH)
            .height('80%')
            .padding({ left: $r('app.float.edge_size_M'), right: $r('app.float.edge_size_M') })
            .margin({ top: $r('app.float.edge_size_SM') })


          }
          // 设置组件的宽度为全屏
          .width(CommonConstants.FULL_WIDTH)
          // 设置组件的高度为全屏
          .height(CommonConstants.FULL_HEIGHT)

          // 如果当前不是编辑状态
          if (!this.isEdit) {
            // 定义一个按钮，用于切换到插入状态
            Button() {
              Image($rawfile('add.png')) // 按钮显示一个加号图片
            }
            .width($r('app.float.component_size_MP')) // 设置按钮宽度
            .height($r('app.float.component_size_MP')) // 设置按钮高度
            .position({ x: CommonConstants.EDIT_POSITION_X, y: CommonConstants.EDIT_POSITION_Y }) // 设置按钮位置
            .onClick(() => { // 设置按钮点击事件
              this.isInsert = true; // 设置插入状态为true
              this.newAccount = { id: 0, accountType: 0, typeText: '', amount: 0 ,time: ''}; // 初始化新的账户对象
              this.dialogController.open(); // 打开对话框
            })
          }


          // 如果当前处于编辑模式
          if (this.isEdit) {
            // 定义一个按钮，用于删除列表项
            Button() {
              Image($rawfile('delete.png')) // 按钮内显示一个删除图标
            }
            .width($r('app.float.component_size_MP')) // 设置按钮宽度
            .height($r('app.float.component_size_MP')) // 设置按钮高度
            .backgroundColor($r('app.color.background_color')) // 设置按钮背景色
            .markAnchor({ x: $r('app.float.mark_anchor'), y: CommonConstants.MINIMUM_SIZE }) // 设置按钮的锚点位置
            .position({ x: CommonConstants.DELETE_POSITION_X, y: CommonConstants.DELETE_POSITION_Y }) // 设置按钮的位置
            .onClick(() => {
              this.deleteListItem(); // 点击按钮时调用删除列表项的方法
            })
          }


        }
        // 设置组件的宽度为全屏
        .width(CommonConstants.FULL_WIDTH)
        // 设置组件的高度为全屏
        .height(CommonConstants.FULL_HEIGHT)
        // 设置组件的背景颜色为应用程序的背景颜色
        .backgroundColor($r('app.color.background_color'))
      }
      .tabBar(this.tabBarBuilder(this.getSourceString('keep_accounts'), 0, $rawfile('ic_01_on.svg'), $rawfile('ic_01_off.svg')))

      TabContent() {
        Column() {
          Column() {
            // 创建一个行容器，用于包含月份切换的UI
            Row() {
              // 创建一个行容器，用于放置返回上月的按钮和文本
              Row() {
                // 使用图标表示返回上月的动作
                SymbolGlyph($r('sys.symbol.arrow_left_circle'))
                  .fontColor([$r('app.color.main_color')])
                  .fontSize($r('app.float.component_size_S'))
                  .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)
                  .effectStrategy(SymbolEffectStrategy.SCALE)
                  // 当isActive状态为真时，应用弹跳效果
                  .symbolEffect(new BounceSymbolEffect(EffectScope.LAYER, EffectDirection.UP), this.isActive)
                  // 点击图标时切换isActive状态，并调用lastMonth方法
                  .onClick(() => {
                    this.isActive = !this.isActive;
                    this.lastMonth();
                  })
                  .margin({
                    left: $r('app.float.font_size_L'),
                    top: $r('app.float.font_size_L')
                  })
                // 显示“上月”文本
                Text($r('app.string.last_month'))
                  .height($r('app.float.component_size_SM'))
                  .fontSize($r('app.float.font_size_M'))
                  .margin({
                    top: $r('app.float.font_size_L')
                  })
              }
              // 设置组件的宽度为屏幕宽度
              .width(CommonConstants.TOP_WIDTH)
              // 设置组件内容的水平对齐方式为左对齐
              .justifyContent(FlexAlign.Start)
              // 设置组件的上边距和下边距
              .margin({ top: $r('app.float.edge_size_SM'), bottom: $r('app.float.edge_size_MM') })

              // 创建一个行容器，用于显示当前选择的年月信息
              Row() {
                // 显示选中的年月信息
                Text(this.selctedYear + this.getSourceString('year')
                  + this.selctedMonth + this.getSourceString('month'))
                  .height($r('app.float.component_size_SM'))
                  .fontSize($r('app.float.font_size_M'))
                  .margin({
                    top: $r('app.float.font_size_L')
                  })
              }
              // 设置组件的宽度为屏幕宽度
              .width(CommonConstants.TOP_WIDTH)
              // 设置组件内容的水平对齐方式为居中对齐
              .justifyContent(FlexAlign.Center)
              // 设置组件的上边距和下边距
              .margin({ top: $r('app.float.edge_size_SM'), bottom: $r('app.float.edge_size_MM') })

              // 创建一个行容器，用于包含下个月切换的UI
              Row() {
                // 显示“下月”文本
                Text($r('app.string.next_month'))
                  .height($r('app.float.component_size_SM'))
                  .fontSize($r('app.float.font_size_M'))
                  .margin({
                    top: $r('app.float.font_size_L')
                  })
                // 使用图标表示跳转到下个月的动作
                SymbolGlyph($r('sys.symbol.arrow_right_circle'))
                  .fontColor([$r('app.color.main_color')])
                  .fontSize($r('app.float.component_size_S'))
                  .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)
                  .effectStrategy(SymbolEffectStrategy.SCALE)
                  // 当isActive状态为真时，应用弹跳效果
                  .symbolEffect(new BounceSymbolEffect(EffectScope.LAYER, EffectDirection.UP), this.isActive)
                  // 点击图标时切换isActive状态，并调用nextMonth方法
                  .onClick(() => {
                    this.isActive = !this.isActive;
                    this.nextMonth();
                  })
                  .margin({
                    right: $r('app.float.font_size_L'),
                    top: $r('app.float.font_size_L')
                  })

              }
              // 设置组件的宽度为屏幕宽度
              .width(CommonConstants.TOP_WIDTH)
              // 设置组件内容的水平对齐方式为右对齐
              .justifyContent(FlexAlign.End)
              // 设置组件的上边距和下边距
              .margin({ top: $r('app.float.edge_size_SM'), bottom: $r('app.float.edge_size_MM') })
            }

          }

          Column() {
            Row() {
              if (!this.haveWeekData) {
                Text($r('app.string.no_data'))
              } else {
                McPieChart({
                  options: this.getWeekData(this.selctedYear, this.selctedMonth)
                })
              }
            }
            .height(CommonConstants.HALF_WIDTH)
            .margin({ top: $r('app.float.edge_size_L') })

            Row() {
              McBarChart({
                options: this.getMonthData(this.selctedYear)
              })
            }
            .height('50%')
          }
          .height('80%')

        }
        .height('100%')
      }
      .tabBar(this.tabBarBuilder(this.getSourceString('Statistics'), 1, $rawfile('ic_02_on.svg'), $rawfile('ic_02_off.svg')))

    }
    .vertical(false)
    .width(CommonConstants.FULL_WIDTH)
    // 设置组件的高度为全屏
    .height(CommonConstants.FULL_HEIGHT)
    .divider({
      strokeWidth: 0.5,
      color: '#0D182431'
    })
    .scrollable(false)
    .backgroundColor('#F1F3F5')
    .padding({ top: '0%', bottom: 28 })

  }
}