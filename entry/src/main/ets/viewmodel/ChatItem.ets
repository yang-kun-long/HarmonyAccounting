
// 对话元素的单个显示数据
@Observed
export default class ChatItem {
  id: number = -1; // 消息唯一标识符
  name: string = ''; // 发送者名称
  avatar: string = ''; // 发送者头像URL
  content: string = ''; // 消息内容
  time: string = ''; // 消息发送的时间戳或格式化时间
  isSelf: boolean = false; // 是否是用户自己发送的消息
  isShowTime: boolean = false; // 是否显示时间
  isFunctionCall: boolean = false; // 是否为函数调用消息
  isShowAvatar : boolean = false;
  functionProgress: number = 0; // 函数调用进度百分比
  functionName: string = ''; // 被调用的函数名称
  functionArguments: string = '';
  functionResult: string = '';
}


// 对话的样例列表
export const ChatList: Array<ChatItem> = [
  {
    id: 1,
    name: ' 我',
    avatar: 'https://gw.alicdn.com/tfs/TB1.ZBecq67gK0jSZFqXXcpaXXa-64-64.png',
    content: '帮我记录一下账单，去旅游消费了 100 元',
    time: '09:00',
    isSelf: true,
    isShowTime: false,
    isShowAvatar: false,
    isFunctionCall: false,
    functionProgress: 0,
    functionName: '',
    functionArguments: '',
    functionResult: '',
  },
  {
    id: 2,
    name: 'AI',
    avatar: 'https://gw.alicdn.com/tfs/TB1.ZBecq67gK0jSZFqXXcpaXXa-64-64.png',
    content: '正在记录账单，请稍后...',
    time: '09:00',
    isSelf: false,
    isShowTime: false,
    isShowAvatar: false,
    isFunctionCall: false,
    functionProgress: 0,
    functionName: '',
    functionArguments: '',
    functionResult: '',
  },
  {
    id: 3,
    name: 'AI',
    avatar: 'https://gw.alicdn.com/tfs/TB1.ZBecq67gK0jSZFqXXcpaXXa-64-64.png',
    content: '',
    time: '09:00',
    isSelf: false,
    isShowTime: false,
    isShowAvatar: false,
    isFunctionCall: true,
    functionProgress: 50,
    functionName: 'addBill',
    functionArguments: `{
      name: '去旅游消费',
      amount: 100.00,
      category: '交通',
      date: '
      2023-05-01'
    }`,
    functionResult: `{
      name: '去旅游消费',
      amount: 100.00,
      category: '交通',
      date: '2023-05-01'
    }`,
  }
]