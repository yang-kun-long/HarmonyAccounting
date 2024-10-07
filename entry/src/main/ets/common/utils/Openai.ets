import { ChatCompletion, ChatCompletionChunk,
  ChatCompletionSystemMessageParam,
  ChatCompletionUserMessageParam,
  ChatCompletionAssistantMessageParam,
  ChatCompletionFunctionMessageParam,
  IChatCompletionMessageParam, OpenAI,
  ChatCompletionToolMessageParam } from '@changwei/openai'
import ChatItem from '../../viewmodel/ChatItem';
import Logger from '../utils/Logger'
import { AiDialogComponent } from '../../view/AiDialogComponent';

@Observed
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
  // 使用代理模式，否则@State 无法更新
  chat(messages:Array<ChatItem>,inputText:string) {


    console.debug("Openai", "chat", inputText)


    // 添加用户信息消息
    this.messageList.push(new ChatCompletionUserMessageParam(inputText))

    let messageLength = messages.length
    messages.push(new ChatItem())
    messages[messageLength-1].id = messageLength
    messages[messageLength-1].content = ""
    getContext(this).eventHub.emit('messages', messages);
    console.debug("Openai", "chat", JSON.stringify(messages))
    console.debug("Openai", "chat", JSON.stringify(this.messageList))

    // 获取聊天信息
    this.getCompletionByStream((response) => {
      console.log(JSON.stringify((response)));
      let resp = response as ChatCompletionChunk[]

      for (let chunck of resp) {
        if (chunck?.choices[0]?.delta?.content) {

          messages[messageLength-1].content += chunck.choices[0].delta.content as string
          getContext(this).eventHub.emit('messages', messages);


          console.log("更新消息中：",JSON.stringify(messages[messageLength-1]))
        }
      }

      console.debug("Openai", "getCompletionByStream", messages[messageLength-1].content)

      inputText = ""

      // getContext(this).eventHub.emit('messages', messages);
      getContext(this).eventHub.emit('inputText', inputText);

    })
  }


  // 获取非流式数据
  getCompletion(streamFunction:(res:ChatCompletion | ChatCompletionChunk[])=>void) {
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
  getCompletionByStream(streamFunction:(res:ChatCompletion | ChatCompletionChunk[])=>void) {
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
