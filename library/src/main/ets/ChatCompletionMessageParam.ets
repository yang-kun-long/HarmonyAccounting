export interface IChatCompletionMessageParam {
  content?: string | string[]
  role: string
  name?: string
}

export class ChatCompletionSystemMessageParam implements IChatCompletionMessageParam {
  content: string
  role: string = "system"
  name?: string

  constructor(content: string, name?: string) {
    this.content = content;
    this.name = name;

  }
}

export class ChatCompletionUserMessageParam implements IChatCompletionMessageParam {
  content: string
  role: string = "user"
  name?: string

  constructor(content: string, name?: string) {
    this.content = content;
    if (name) {
      this.name = name;
    }
  }
}

export class ChatCompletionAssistantMessageParam implements IChatCompletionMessageParam {
  content: string
  role: string = "assistant"
  name?: string

  constructor(content: string, name?: string) {
    this.content = content;
    this.name = name;

  }
}

export class ChatCompletionToolMessageParam implements IChatCompletionMessageParam {
  content: string
  role: string = "tool"
  name?: string
  tool_call_id:string

  constructor(content: string, name: string,toolCallId:string) {
    this.content = content;
    this.name = name;
    this.tool_call_id = toolCallId
  }
}

export class ChatCompletionFunctionMessageParam implements IChatCompletionMessageParam {
  content: string
  role: string = "function"
  name?: string

  constructor(content: string, name?: string) {
    this.content = content;
    this.name = name;

  }
}