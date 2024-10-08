export class Function {
  name: string = ""
  description: string = ""
  parameters: Map<string, object> = new Map()
}

export class ResponseFormat {
  // ["text", "json_object"]
  type: string = "text"
}

export class ChatCompletionNamedToolChoiceParam {
  function: Function = new Function()
  type: string = "function"
}

export class ChatCompletionToolParam {
  function: FunctionDefinition = new FunctionDefinition()
  type: string = "function"
}

export class FunctionDefinition {
  name: string = ""
  description: string = ""
  parameters: Map<string, object> = new Map()
}

export class ChatCompletionFunctionCallOptionParam {
  name: string = ""
}

