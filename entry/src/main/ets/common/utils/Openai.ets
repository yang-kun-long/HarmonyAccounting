import { ChatCompletion, ChatCompletionChunk,
  ChatCompletionSystemMessageParam,
  ChatCompletionUserMessageParam,
  ChatCompletionAssistantMessageParam,
  ChatCompletionFunctionMessageParam,
  IChatCompletionMessageParam, OpenAI,
  ChatCompletionToolMessageParam } from '@changwei/openai'
import ChatItem from '../../viewmodel/ChatItem';


class Openai {

  private openaiClient: OpenAI
  private messageList: IChatCompletionMessageParam[];

  constructor() {
    this.openaiClient = new OpenAI(
      "sk-sX5SuWY74QzIusIjfKaefj416JVXYRwCX9LGfSCsVx069AUv",
      undefined,
      "https://api.chatanywhere.tech/v1",
    )
    this.messageList = []
  }

  // 添加系统消息
  addSystemMessage(content:string) {
    this.messageList.push(new ChatCompletionSystemMessageParam(content))
  }

  // 添加用户消息
  addUserMessage(content:string) {
    this.messageList.push(new ChatCompletionUserMessageParam(content))
  }

  // 添加机器人消息
  addAssistantMessage(content:string) {
    this.messageList.push(new ChatCompletionAssistantMessageParam(content))
  }

  // 添加函数消息
  addFunctionMessage(content:string) {
    this.messageList.push(new ChatCompletionFunctionMessageParam(content))
  }

  // 添加工具消息
  addToolMessage(content:string) {
    this.messageList.push(new ChatCompletionToolMessageParam(content))
  }

  // 进行一次对话
  chat(content:string, messageList:ChatItem[]) {

  }

  // 获取非流式数据
  getCompletion(content:string) {
    return this.openaiClient.chat.completions.create(
      {
        messages: this.messageList,
        model: "gpt-4o-mini",
        stream: false
      }
    )
  }

  // 获取流式数据并进行处理
  getCompletionByStream(content:string,streamFunction:(res:ChatCompletion | ChatCompletionChunk[])=>void) {
    this.openaiClient.chat.completions.create(
      {
        messages: this.messageList,
        model: "gpt-4o-mini",
        stream: true
      }
    )
    .then(streamFunction)
    .catch((error:Error) => {
      console.log(JSON.stringify((error)));
    })
  }

}

export default new Openai()
