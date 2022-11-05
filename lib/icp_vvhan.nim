# china icp info
# 备案信息查询
# @TODO
# 
# https://icplishi.com/{domain}
import std/[asyncdispatch, httpclient]
import json

proc icpinfo(dst:string):JsonNode = 
    var client = newHttpClient(userAgent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/517.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36")
    var jsondata =  client.getContent("https://api.vvhan.com/api/icp?url=" & dst)
    echo "https://api.vvhan.com/api/icp?url=" & dst
    echo repr(jsondata)
    return parseJson(jsondata)

# {"success":true,"domain":"bing.com","info":{"name":"微软移动联新互联网服务有限公司","nature":"企业","icp":"京ICP备10036305号-11","title":"必应搜索","time":"2022-10-20 21:57:37"}}

# var t = icpinfo("bing.com")

# for k,y in t.mpairs():
#     # echo  i.val
#     y =  %["nope"]
#     echo repr(y)  
#     # x.val = %*{"nope":"fuck"}
#     # 

# echo t 
# (key: "success", val: true)
# (key: "domain", val: "bing.com")
# (key: "info", val: {"name":"微软移动联新互联网服务有限公司","nature":"企业","icp":"京ICP备10036305号-11","title":"必应搜索","time":"2022-10-20 21:57:37"})
# for record in icpinfo("bing.com").items():
#     echo typeof(record)
#     echo repr(record)
#     echo "域名=> [", record["info"]["name"] , "]"
#     echo "类型=> [", record["info"]["icp"] , "]"
#     echo "备案号=> [", record["info"]["name"] , "]"
