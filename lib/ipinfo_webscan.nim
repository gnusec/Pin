# /*
#  * @Description: 使用 webscan 接口，ip信息获取
#  */


import std/[asyncdispatch, httpclient]
import json

proc ipinfo(dst:string): JsonNode = 
    var client = newHttpClient(userAgent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36")
    var jsondata =  client.getContent("https://api.webscan.cc/getip/" & dst)
    return parseJson(jsondata)
# {
#     "ip": "220.181.38.150",
#     "info": "\u4e2d\u56fd\u5317\u4eac\u5317\u4eac\u5e02\u7535\u4fe1"
# }