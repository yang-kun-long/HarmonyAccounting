export class CommonTool {
  public static encodeUrlParams(params: undefined|Record<string, string|number|object|boolean|undefined|null>): string {
    let paramsArry:string[] = []
    if (params) {
      for (let key of Object.entries(params)) {
        paramsArry.push(`${key[0]}=${key[1]}`)
      }
    }
    if (paramsArry.length > 0)
      return `?${paramsArry.join("&")}`;
    else {
      return "";
    }
  }
}