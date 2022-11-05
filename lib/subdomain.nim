# /*
#  * @Description: 查询子域名
#  */
# https://rapiddns.io/subdomain/cip.cc
# 国内还是用ip138靠谱点
# https://chaziyu.com/IP138.com/


import random
import std/[asyncdispatch, httpclient]
# import std/httpclient
import std/xmltree
import xmltree, htmlparser, strtabs
import streams

# 输入:
# 一定得是域名 
# 输出:
# 返回所有子域名的 seq
# @["static.cip.cc", "www.cip.cc", "ip.cip.cc", "cip.cc"]
proc subdomain(domain:string):    seq[string] =
    var client = newHttpClient(userAgent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/5" &  $rand(40) &  ".36 (KHTML, like Gecko) Chrome/" & $rand(104) & ".0.0.0 Safari/537.36")
    # var jsondata =  client.getContent("https://api.webscan.cc/query/" & domain)
    var resp =  client.getContent("https://chaziyu.com/" & domain)

    # writeFile("subdomain.txt",resp)

    # echo repr(resp)

    var stream = newStringStream(resp)
    # var stream = newFileStream("subdomain.txt")
    var html   = htmlparser.parseHtml(stream)
    var result: seq[string]
    for tagDiv in html.findAll("div"):
        if tagDiv.attrs.hasKey("class") and tagDiv.attr("class") == "c-bd":
            for tagA in tagDiv.findAll("a"):
                # echo  tagA.innerText
                # echo typeof(tagA.innerText)
                if tagA.innerText notin  result:
                    result.add(tagA.innerText)
    return result

proc subdomainPrint(domain:string) =
    echo subdomain(domain)

# echo subdomain("cip.cc")
subdomainPrint("cip.cc")
