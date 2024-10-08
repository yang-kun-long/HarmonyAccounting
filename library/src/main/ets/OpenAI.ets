import axios, { AxiosHeaders, AxiosInstance } from '@ohos/axios'
import { Chat } from './AsyncCall'
import { Completions } from './Completions'
import { Embeddings } from './Embeddings'

const DEFAULT_MAX_RETRIES: number = 2
const DEFAULT_TIMEOUT: number = 300
const DEFAULT_VERSION = "2023-05-15"

const _deployments_endpoints: Set<string> = new Set(
  [
    "/completions",
    "/chat/completions",
    "/embeddings",
    "/audio/transcriptions",
    "/audio/translations",
    "/audio/speech",
    "/images/generations",
  ]
)

export class RequestConfig {
  headers?: Record<string, string>
  params?: Record<string, string>
  baseURL: string

  constructor(baseUrl: string, headers?: Record<string, string>, params?: Record<string, string>) {
    this.baseURL = baseUrl;
    this.headers = headers;
    this.params = params;
  }
}

class BaseClient {
  private api_version: string
  private base_url: string
  private max_retries: number
  private timeout: number
  //transport: Transport | None = None,
  //proxies: ProxiesTypes | None = None,
  //limits: Limits | None = None,
  private http_client?: RequestConfig
  private custom_headers?: Record<string, string>
  private custom_query?: Record<string, string>
  private api_key: string
  chat: Chat
  embeddings: Embeddings
  completions: Completions

  //_strict_response_validation: bool,

  constructor(api_key: string, api_version: string = DEFAULT_VERSION, base_url: string, max_retries: number = DEFAULT_MAX_RETRIES,
              timeout: number = DEFAULT_TIMEOUT, custom_headers: Record<string, string> = {}, custom_query: Record<string, string> = {}) {
    this.api_key = api_key
    this.api_version = api_version
    this.base_url = base_url
    this.max_retries = max_retries
    this.timeout = timeout

    //let axiosHeaders = new AxiosHeaders();
    // if (custom_headers) {
    //   if (custom_headers) {
    //     for (let [key, val] of custom_headers) {
    //       axiosHeaders.set(key, val, true);
    //     }
    //   }
    // }
    if (custom_headers) {
      custom_headers["Content-Type"] = "application/json";
    } else {
      custom_headers = { "Content-Type": "application/json" };
    }
    if (!this.http_client) {
      this.http_client = new RequestConfig(base_url,
        custom_headers,
        custom_query
      );
    }


    this.custom_headers = custom_headers;
    this.custom_query = custom_query;
    this.chat = new Chat(this.http_client);
    this.embeddings = new Embeddings(this.http_client);
    this.completions = new Completions(this.http_client)
  }

  _build_request() {

  }
}

export class OpenAI extends BaseClient {
  organization?: string

  constructor(api_key: string, organization?: string, base_url?: string, max_retries: number = DEFAULT_MAX_RETRIES,
              timeout?: number, custom_headers?: Record<string, string>, custom_query?: Record<string, string>) {
    if (!api_key)
      throw new Error("The api_key client option must be set either by passing api_key to the client or by setting the OPENAI_API_KEY environment variable")
    if (custom_headers) {
      custom_headers["Authorization"] = `Bearer ${api_key}`;
    } else {
      custom_headers = {
        "Authorization": `Bearer ${api_key}`
      }
    }
    if (!base_url)
      base_url = "https://api.openai.com/v1"
    super(api_key, undefined, base_url, max_retries, timeout, custom_headers, custom_query)
    if (organization) {
      this.organization = organization
    }

  }
}

class BaseAzureClient extends BaseClient {
  _build_request() {

  }
}

// Azure OpenAI Client
export class AzureOpenAI extends BaseAzureClient {
  azure_endpoint: string = ""
  azure_deployment: string = ""

  constructor(azure_endpoint: string, api_version: string = DEFAULT_VERSION, api_key: string, azure_deployment?: string, max_retries?: number,
              timeout?: number, custom_headers?: Record<string, string>, custom_query?: Record<string, string>) {
    let base_url = ""
    if (azure_endpoint) {
      if (azure_deployment) {
        base_url = `${azure_endpoint}/openai/deployments/${azure_deployment}`
      }
      else {
        base_url = `${azure_endpoint}/openai`
      }
    } else {
      throw new Error("Must provide one of the `base_url` or `azure_endpoint` arguments")
    }
    if (!api_key)
      throw new Error("The api_key client option must be set either by passing api_key to the client")

    if (custom_headers) {
      custom_headers["api-key"] = api_key
    } else {
      custom_headers = { "api-key": api_key }
    }
    if (!custom_query) {
      custom_query = { "api-version": api_version }
    }
    super(api_key, api_version, base_url, max_retries, timeout, custom_headers, custom_query)

  }
}