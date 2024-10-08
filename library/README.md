# openai-arkts

#### 介绍
OpenAI SDK鸿蒙原生版，采用ArkTS编写，支持ChatCompletiong,Embedding等接口实现，调用方式和python SDK一致

[观看演示视频](https://www.ixigua.com/7347279931354645026)
## 下载安装

```javascript
ohpm install @changwei/openai
```

OpenHarmony ohpm 环境配置等更多内容，请参考[如何安装 OpenHarmony ohpm 包](https://gitee.com/openharmony-tpc/docs/blob/master/OpenHarmony_har_usage.md)



## 接口和属性列表

可以在 platform.openai.com 上找到 REST API 文档。
如果使用Azure OpenAI服务，请访问：https://learn.microsoft.com/en-us/azure/ai-services/openai/chatgpt-quickstart


## 使用方法

#### 使用openai.com API

```typescript
import { OpenAI } from '@changwei/openai'

openaiClient: OpenAI = new OpenAI(
    "your sk-xxx"
)
openaiClient.chat.completions.create(
    {
        messages: [
            {
                "role": "user",
                "content": "Say this is a test",
            }
        ],
        model: "gpt-3.5-turbo",
    }
)
```
#### 使用Azure OpenAI 聊天API

```typescript
import { AzureOpenAI } from '@changwei/openai'

openaiClient: AzureOpenAI = new AzureOpenAI(
    // https://learn.microsoft.com/en-us/azure/cognitive-services/openai/how-to/create-resource?pivots=web-portal#create-a-resource
    "your endpoint",
    // https://learn.microsoft.com/en-us/azure/ai-services/openai/reference#rest-api-versioning
    "2023-07-01-preview",
    "your api-key"
)
openaiClient.chat.completions.create(
    {
        messages: [
            {
                "role": "user",
                "content": "Say this is a test",
            }
        ],
        model: "deployment-name"  // e.g. gpt-35-instant
    }
)
```


#### 流式接口
因为目前axios还不支持SSE模式，此处流式实现有延时。此处以openai.com接口调用为例
```typescript
import { OpenAI,ChatCompletionChunk } from '@changwei/openai'

openaiClient: OpenAI = new OpenAI(
    "your sk-xxx"
)
openaiClient.chat.completions.create(
    {
        messages: [
            {
                "role": "user",
                "content": "Say this is a test",
                stream: true
            }
        ],
        model: "gpt-3.5-turbo",
    }
)
.then((response) => {
    console.log(JSON.stringify((response)));
    let resp = response as ChatCompletionChunk[]
    let output: string = ""
    for (let chunck of resp) {
        if (chunck?.choices[0]?.delta?.content) {
            output += chunck.choices[0].delta.content as string
        }
    }
    console.log(output);
})
.catch((error) => {
    console.log(JSON.stringify((error)));
})

```

#### Embedding接口
```typescript
 import { OpenAI } from '@changwei/openai'

openaiClient: OpenAI = new OpenAI(
    "your sk-xxx"
)
openaiClient.embeddings.create({
                input: "your input text",
                model: "text-embedding-ada-002"
              })
```

#### 访问原始响应数据（例如header）
```typescript
import { OpenAI } from '@changwei/openai'

openaiClient: OpenAI = new OpenAI(
    "your sk-xxx"
)
openaiClient.chat.completions.with_raw_response.create(
    {
        messages: [
            {
                "role": "user",
                "content": "Say this is a test",
            }
        ],
        model: "gpt-3.5-turbo",
    }
)
.then((response)=>{
    console.log(response.headers["content-type"]);
    let completion = response.parse();
    console.log(completion);
        
})

```

#### Completion API 文本补全
```typescript
openaiClient.completions.create({
              model: "gpt-3.5-turbo-instruct",
              prompt: "Say this is a test",
              max_tokens: 7,
              temperature: 0
            })
```

## 约束与限制

在下述版本验证通过：
DevEco Studio: 4.0.0.600, SDK: API9

## 贡献代码

使用过程中发现任何问题都可以提[Issue](https://gitee.com/changweizhang/ChatUI/issues) 给我 。

## 开源协议

本项目基于 [MIT](https://gitee.com/openharmony-sig/axios/blob/master/LICENSE) ，请自由地享受和参与开源。

## 联系我

B站 @[Changwei同学](https://space.bilibili.com/395257724)  

抖音/西瓜 @梦断代码

**求点赞 求关注 求分享**
