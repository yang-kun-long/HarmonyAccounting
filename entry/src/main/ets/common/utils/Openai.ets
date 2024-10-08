import { ChatCompletion, ChatCompletionChunk,
  ChatCompletionSystemMessageParam,
  ChatCompletionUserMessageParam,
  ChatCompletionAssistantMessageParam,
  ChatCompletionFunctionMessageParam,
  IChatCompletionMessageParam, OpenAI,
  ChatCompletionToolMessageParam } from '@adrian_wang/openai'
import ChatItem from '../../viewmodel/ChatItem';

import { AiDialogComponent, AiDialogData } from '../../view/AiDialogComponent';
import { HashMap } from '@kit.ArkTS';
import { IChatCompletionPostData } from '@adrian_wang/openai/src/main/ets/AsyncCall';
import { ChatCompletionToolParam } from '@adrian_wang/openai/src/main/ets/Function';
import { ChatCompletionMessage } from '@adrian_wang/openai/src/main/ets/ChatCompletion';

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
  addToolMessage(content:string,name:string,toolCallId:string) {
    this.messageList.push(new ChatCompletionToolMessageParam(content,name,toolCallId))
  }

  addMessage(message: ChatCompletionMessage) {
    this.messageList.push(message)
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




  // 获取流式数据并进行处理
  async getCompletionByStream(streamFunction:(res:ChatCompletion | ChatCompletionChunk[])=>void) {
    this.openaiClient.chat.completions.create(this.getModelParams(true))
    .then(streamFunction)
    .catch((error:Error) => {
      console.log(JSON.stringify((error)));
    })
  }



  // 获取初始化的模型参数，用于构造请求
  getModelParams(isStream:boolean): IChatCompletionPostData {

    let tools: ChatCompletionToolParam[] = []



    let parameters: Map<string, object>;



    /*TODO*******************************************************************
     *                     这里添加函数清单                                    *
     *TODO*******************************************************************/
    parameters = new Map<string, object>();
    let time_format = new Map<string, object>();

    time_format["type"] = "string"
    time_format["description"] = "The format of the time"

    parameters["type"] = "object"
    parameters["properties"] = {
      "time_format": time_format
    }

    /***********************************************************************/




    tools.push({
      function:{
        name: "get_current_time",
        description: "Get the current time",
        parameters:parameters
      },
      type: "function"
    })


    return {
      messages: this.messageList,
      model: "gpt-4o-mini",
      stream: isStream,
      tools: tools
    }
  }


  // 获取非流式数据
  async getCompletion(chatFunction:(res:ChatCompletion | ChatCompletionChunk[])=>void) {

    console.debug("Openai", "getCompletion =================================")
    console.debug("Openai", "getCompletion", JSON.stringify(this.getModelParams(false)))
    console.debug("Openai", "getCompletion", JSON.stringify(this.messageList))
    console.debug("Openai", "getCompletion =================================")


    let response = await this.openaiClient.chat.completions.create(this.getModelParams(false))
    chatFunction(response)
  }




}

export default new Openai()
