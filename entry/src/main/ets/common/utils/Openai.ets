import { ChatCompletion, ChatCompletionChunk,
  ChatCompletionSystemMessageParam,
  ChatCompletionUserMessageParam,
  ChatCompletionAssistantMessageParam,
  ChatCompletionFunctionMessageParam,
  IChatCompletionMessageParam, OpenAI,
  ChatCompletionToolMessageParam } from '@changwei/openai'
import ChatItem from '../../viewmodel/ChatItem';
import Logger from '../utils/Logger'
import { AiDialogComponent, AiDialogData } from '../../view/AiDialogComponent';

@Observed
class Openai {

  private openaiClient: OpenAI
  public  messageList: IChatCompletionMessageParam[];

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
  // 使用代理模式，否则@State 无法更新
  // async chat(messages:Array<ChatItem>,inputText:string) {

  chat(data:AiDialogData) {

    console.debug("Openai", "chat", data.inputText)


    // 添加用户信息消息
    this.messageList.push(new ChatCompletionUserMessageParam(data.inputText))

    // 添加一个新的聊天项到消息列表中，并发送更新后的消息列表事件
    let messageLength = data.messages.length
    data.messages.push(new ChatItem())
    data.messages[messageLength-1].id = messageLength
    data.messages[messageLength-1].content = ""
    getContext(this).eventHub.emit('messages', data.messages);
    console.debug("Openai", "chat", JSON.stringify(data.messages))
    console.debug("Openai", "chat", JSON.stringify(this.messageList))


    data.inputText = ""

    // 通过流式处理获取聊天完成信息
    this.getCompletionByStream((response) => {
      console.log(JSON.stringify((response)));
      let resp = response as ChatCompletionChunk[]

      // 遍历响应中的每个消息块，并追加内容到消息列表的最后一个元素中
      for (let chunck of resp) {
        if (chunck?.choices[0]?.delta?.content) {

          data.messages[messageLength-1].content += chunck.choices[0].delta.content as string
          console.log("消息块：",chunck.choices[0].delta.content as string)

        }
      }

      console.debug("Openai", "getCompletionByStream", data.messages[messageLength-1].content)



      data.inputText = ""
      getContext(this).eventHub.emit('inputText', data.inputText);
      getContext(this).eventHub.emit('messages', data.messages);

    })

    console.debug("Openai", "chat", "end")

  }


  // 获取非流式数据
  async getCompletion(streamFunction:(res:ChatCompletion | ChatCompletionChunk[])=>void) {
    this.openaiClient.chat.completions.create(
      {
        messages: this.messageList,
        model: "gpt-4o-mini",
        stream: false
      }
    )
    .then(streamFunction)
    .catch((error:Error) => {
      console.log(JSON.stringify((error)));
    })
  }

  // 获取流式数据并进行处理
  async getCompletionByStream(streamFunction:(res:ChatCompletion | ChatCompletionChunk[])=>void) {
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
