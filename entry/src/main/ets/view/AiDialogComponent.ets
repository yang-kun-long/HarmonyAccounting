
import Openai from '../common/utils/Openai'

import CommonConstants from '../common/constants/CommonConstants';
import ChatItem, { ChatList } from '../viewmodel/ChatItem';

@CustomDialog
export struct AiDialogComponent {
  controller?: CustomDialogController;

  @State messages: Array<ChatItem> = ChatList;
  @State inputText: string = '';

  // 构建方法，用于创建和配置用户界面组件
  build() {
    // 定义一个列组件，包含一个图像，并且点击该图像可以关闭当前控制器
    Column() {
      Scroll() {
        Column(){
          ForEach(this.messages, (message:ChatItem) => {
            //message.id 表示消息 id
            //message.name 表示消息发送名字
            //message.avatar 表示消息发送者头像
            //message.content 表示消息内容
            //message.time 表示消息发送时间
            //message.isSelf 表示是否是用户自己发送的
            //message.isShowTime 表示是否显示时间
            //message.isShowAvatar 表示是否显示头像
            /**
             * TODO 根据已有的消息渲染消息列表，要求美观点，消息样式就是 ChatList
             * TODO 用户的消息显示在右边，AI 的消息显示在左边
             * TODO 时间显示在消息下方，并且只显示一次，如果连续两个消息时间相同，则不显示时间
             * TODO 如果是 AI 的函数调用，则显示正在进行函数调用进度，且需要描述出调用的具体函数
             * TODO 如果调用完成，需要让用户选择要执行的操作，即显示两个按钮，应用或者放弃
             */


            Text(message.content)
              .backgroundColor(message.content.startsWith('AI:')? '#f0f0f0' : '#e0e0e0')
              .borderRadius(10)
              .padding(10);
          }, (item:ChatItem) => String(item.id));
        }

      }
      .height('80%')
      .border({
        width: 1,
        color: '#e0e0e0'
      })
      Row() {
        TextArea({ placeholder: '输入对话...' })
          .width('70%')
          .onChange((value:string) => {
            this.inputText = value;
          });
        Button(){
          Image($rawfile('send.svg'))// 设置图像的宽度
            .width($r('app.float.button_image_width'))// 设置图像的高度
            .height($r('app.float.button_image_height'))// 当图像被点击时，关闭当前控制器（如果存在）
        }
        .width($r('app.float.button_width'))
        .height($r('app.float.button_height'))
        .onClick(() => {
          if (this.inputText.trim()!== '') {
            this.messages.push({
              id: 0,
              name: '我',
              avatar: '',
              content: this.inputText,
              time: '',
              isSelf: true,
              isShowTime: false,
              isFunctionCall: false,
              isShowAvatar: false,
              functionProgress: 0,
              functionName: '',
              functionResult: ''
            });
            // 这里可以调用网络请求实现与 AI 的交互并更新 messages
            Openai.chat(this.inputText, this.messages)

            this.inputText = '';
          }
        });

        Button(){
          Image($rawfile('clear.svg'))// 设置图像的宽度
            .width($r('app.float.button_image_width'))// 设置图像的高度
            .height($r('app.float.button_image_height'))// 当图像被点击时，关闭当前控制器（如果存在）
        }
        .width($r('app.float.button_width'))
        .height($r('app.float.button_height'))
        .onClick(() => {
          this.messages = [];
        });
      }
      .height($r('app.float.component_size_M'))
      // 设置布局权重为充满整个屏幕
      .layoutWeight(CommonConstants.FULL_SIZE)
      // 设置底部、左边和右边的内边距为字体大小L
      .padding({
        bottom: $r('app.float.font_size_L'),
        left: $r('app.float.font_size_L'),
        right: $r('app.float.font_size_L')
      })
      // 设置内容对齐方式为末尾对齐
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Bottom)

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

// ai 对话气泡

