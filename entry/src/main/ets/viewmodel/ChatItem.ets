
// 对话元素的单个显示数据
export default class ChatItem {
  id: number = -1;
  name: string = '';
  avatar: string = '';
  content: string = '';
  time: string = '';
  isSelf: boolean = false; // 是不是自己发送的
  isShowTime: boolean = false;
  isShowAvatar: boolean = false;
}

// 对话的样例列表
export const ChatList: Array<ChatItem> = [
  {
    id: 1,
    name: ' AI',
    avatar: 'https://gw.alicdn.com/tfs/TB1.ZBecq67gK0jSZFqXXcpaXXa-64-64.png',
    content: '你好，我是小明，请问有什么可以帮到您的？',
    time: '09:00',
    isSelf: false,
    isShowTime: false,
    isShowAvatar: false,
  },
  {
    id: 2,
    name: 'AI',
    avatar: 'https://gw.alicdn.com/tfs/TB1.ZBecq67gK0jSZFqXXcpaXXa-64-64.png',
    content: '你好，我是小明，请问有什么可以帮到您的？',
    time: '09:00',
    isSelf: false,
    isShowTime: false,
    isShowAvatar: false,
  },
  {
    id: 3,
    name: '我',
    avatar: 'https://gw.alicdn.com/tfs/TB1.ZBecq67gK0jSZFqXXcpaXXa-64-64.png',
    content: '你好，我是小明，请问有什么可以帮到您的？',
    time: '09:00',
    isSelf: true,
    isShowTime: false,
    isShowAvatar: false,
  }
]