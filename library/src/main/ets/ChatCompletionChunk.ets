import { ChatCompletionTokenLogprob, ChoiceLogprobs } from './ChatCompletion'

class ChoiceDeltaFunctionCall {
  arguments?: string
  name?: string
}

class ChoiceDeltaToolCallFunction {
  arguments?: string
  name?: string
}

class ChoiceDeltaToolCall {
  index: number = 0
  id?: string
  function?: ChoiceDeltaToolCallFunction
  type?: string
}

class ChoiceDelta {
  content?: string
  function_call?: ChoiceDeltaFunctionCall
  role?: string
  tool_calls: ChatCompletionTokenLogprob[] = []
}

class Choice {
  delta: ChoiceDelta = new ChoiceDelta()
  finish_reason?: string
  index: number = 0
  logprobs?: ChoiceLogprobs
}

export class ChatCompletionChunk {
  id: string = ""
  choices: Choice[] = []
  created: number = 0
  model: string = ""
  object: string = ""
  system_fingerprint?: string
}


