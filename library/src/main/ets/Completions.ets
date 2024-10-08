import { CompletionUsage } from './ChatCompletion'
import axios, { AxiosResponse } from '@ohos/axios'
import { RequestConfig } from './OpenAI'
import { CommonTool } from './CommonTool'

class Logprobs {
  text_offset?: number[]
  token_logprobs?: number[]
  tokens?: string[]
  top_logprobs?: Record<string,string>[]
}

class CompletionChoice {
  finish_reason: string = "stop" // Literal["stop", "length", "content_filter"]
  /*The reason the model stopped generating tokens.

This will be `stop` if the model hit a natural stop point or a provided stop
sequence, `length` if the maximum number of tokens specified in the request was
reached, or `content_filter` if content was omitted due to a flag from our
content filters.
*/

  index: number = 0
  logprobs?: Logprobs
  text: string = ""
}

export class Completion {
  id: string = ""
  //A unique identifier for the completion.//
  choices: CompletionChoice[] = []
  //The list of completion choices the model generated for the input prompt.//
  created: number = 0
  //The Unix timestamp (in seconds) of when the completion was created.//
  model: string = ""
  //The model used for completion.//
  object: string = "" // Literal["text_completion"]
  //The object type, which is always "text_completion" //
  system_fingerprint?: string
  //This fingerprint represents the backend configuration that the model runs with.

  //Can be used in conjunction with the `seed` request parameter to understand when
  //backend changes have been made that might impact determinism.
  //

  usage?: CompletionUsage
  //Usage statistics for the completion request.//
}

interface ICompletingData {
  // openai.com "gpt-3.5-turbo-instruct", "davinci-002", "babbage-002"
  // azure openai deployment name
  model: string,
  prompt: string | string[] | number[] | number[][]
  best_of?: number,
  echo?: boolean,
  frequency_penalty?: number,
  logit_bias?: Record<string, string>,
  logprobs?: number,
  max_tokens?: number,
  n?: number,
  presence_penalty?: number,
  seed?: number,
  stop?: string | string[],
  stream?: boolean,
  suffix?: string,
  temperature?: number,
  top_p?: number,
  user?: string
  timeout?: number,
}

export class Completions {
  private _client: RequestConfig

  constructor(config: RequestConfig) {
    this._client = config;
  }

  create(data: ICompletingData): Promise<Completion> {
    let postData: Map<string,object> = new Map();
    if (data.model) {
      postData["model"] = data.model;
    }
    if (data.prompt) {
      postData["prompt"] = data.prompt;
    }
    if (data.best_of) {
      postData["best_of"] = data.best_of;
    }
    if (data.echo) {
      postData["echo"] = data.echo;
    }
    if (data.frequency_penalty) {
      postData["frequency_penalty"] = data.frequency_penalty;
    }
    if (data.logit_bias) {
      postData["logit_bias"] = data.logit_bias;
    }
    if (data.logprobs) {
      postData["logprobs"] = data.logprobs;
    }
    if (data.max_tokens) {
      postData["max_tokens"] = data.max_tokens;
    }
    if (data.n) {
      postData["n"] = data.n;
    }
    if (data.presence_penalty) {
      postData["presence_penalty"] = data.presence_penalty;
    }
    if (data.seed) {
      postData["seed"] = data.seed;
    }
    if (data.stop) {
      postData["stop"] = data.stop;
    }
    if (data.stream) {
      postData["stream"] = data.stream;
    }
    if (data.suffix) {
      postData["suffix"] = data.suffix;
    }
    if (data.temperature) {
      postData["temperature"] = data.temperature;
    }
    if (data.top_p) {
      postData["top_p"] = data.top_p;
    }
    if (data.user) {
      postData["user"] = data.user;
    }
    if (data.timeout) {
      postData["timeout"] = data.timeout;
    }
    return new Promise<Completion>((resolve, reject) => {
      let url: string = ""
      if (data.model && this._client.baseURL.indexOf("openai.azure.com") >= 0 && !this._client.baseURL.endsWith(data.model)) {
        url = `${this._client.baseURL}/deployments/${data.model}/completions${CommonTool.encodeUrlParams(this._client.params)}`
      } else {
        url = `${this._client.baseURL}/completions${CommonTool.encodeUrlParams(this._client.params)}`
      }
      let timeout = 300;
      if (data.timeout) {
        timeout = data.timeout
      }

      let jsonStr = JSON.stringify(postData)
      axios.request<Completion, AxiosResponse<Completion>>({
        method: "post",
        url: url,
        data: jsonStr,
        headers: this._client.headers,
        timeout: timeout * 1000
      })
        .then((response: AxiosResponse<Completion>) => {
          //console.info(JSON.stringify(response));
          let respData: Completion = response.data;
          resolve(respData)
        })
        .catch((error:Error) => {
          console.info(JSON.stringify(error));
          reject(error)
        });


    });


  }
}