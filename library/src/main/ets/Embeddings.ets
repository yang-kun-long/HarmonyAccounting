import { Embedding } from './Embedding';
import { RequestConfig } from './OpenAI';
import axios, { AxiosResponse } from '@ohos/axios'
import { CommonTool } from './CommonTool';

interface IEmbeddingParams {
  input: string | string[] | number[] | number[][]
  //"text-embedding-ada-002", "text-embedding-3-small", "text-embedding-3-large"
  model?: string
  dimensions?: number
  //"float", "base64"
  encoding_format?: string
  user?: string
  timeout?: number
}

export class Embeddings {
  _client: RequestConfig

  constructor(_client: RequestConfig) {
    if (_client) {
      this._client = _client
    }else{
      this._client = new RequestConfig("https://api.openai.com/v1")
    }
  }

  create(
    data: IEmbeddingParams
  ): Promise<CreateEmbeddingResponse> {
    let postData: Map<string, object> = new Map();
    postData["input"] = data.input;
    if (data.model) {
      postData["model"] = data.model;
    }
    if (data.dimensions) {
      postData["dimensions"] = data.dimensions;
    }
    if (data.encoding_format) {
      postData["encoding_format"] = data.encoding_format;
    }
    if (data.user) {
      postData["user"] = data.user;
    }
    return new Promise<CreateEmbeddingResponse>((resolve, reject) => {
      let url: string = ""
      if (data.model && this._client.baseURL.indexOf("openai.azure.com") >= 0 && !this._client.baseURL.endsWith(data.model)) {
        url = `${this._client.baseURL}/deployments/${data.model}/embeddings${CommonTool.encodeUrlParams(this._client.params)}`
      } else {
        url = `${this._client.baseURL}/embeddings${CommonTool.encodeUrlParams(this._client.params)}`
      }
      let timeout = 300;
      if (data.timeout) {
        timeout = data.timeout
      }

      let jsonStr = JSON.stringify(postData)
      axios.request<CreateEmbeddingResponse, AxiosResponse<CreateEmbeddingResponse>>({
        method: "post",
        url: url,
        data: jsonStr,
        headers: this._client.headers,
        timeout: timeout * 1000
      })
        .then((response: AxiosResponse<CreateEmbeddingResponse>) => {
          console.info(JSON.stringify(response));
          let respData: CreateEmbeddingResponse = response.data;
          resolve(respData)
        })
        .catch((error:Error) => {
          console.info(JSON.stringify(error));
          reject(error)
        });


    });

  }
}

export class CreateEmbeddingResponse {
  data: Embedding[] = []
  model: string = ""
  object: string = ""
  usage: Usage = new Usage()
}

class Usage {
  // The number of tokens used by the prompt.
  prompt_tokens: number = 0
  //The total number of tokens used by the request.
  total_tokens: number = 0
}
