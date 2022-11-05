# UserAgent 必须是非curl
# 域名做参数查询的是域名的历史解析IP
# https://site.ip138.com/cip.cc

# 反查 必须用IP
# https://site.ip138.com/122.51.157.137/
# 
#
# C段反查
# https://chapangzhan.com/122.51.157.0/24
# 


import random
import std/[asyncdispatch, httpclient]
import sequtils
# import std/httpclient

# proc ip2domain_async(domain:string): Future[string] {.async.}=
#     var client = newAsyncHttpClient()
#     return await client.getContent("https://api.webscan.cc/query/" & domain)

# # echo waitFor ip2domain("bing.com")

import json
import streams,htmlparser
import std/xmltree
import xmltree, htmlparser, strtabs
import net
# import dom

# ip138 必须使用IP才能逆查询
proc ip2domain(ip:string):  seq[seq[string]] =
    if not isIpAddress(ip):
        quit("isIpAddress Chck Error => [" & ip & "]" )
    var client = newHttpClient(userAgent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/"& $rand(104) & ".0.0.0 Safari/537.36")
    var resp =  client.getContent("https://site.ip138.com/" & ip & "/")
    # writeFile("ip138-2.txt",resp)
    # # echo repr(resp)
    # # echo "==========================================="
    var stream = newStringStream(resp)
    # var stream = newFileStream("ip138-2.txt")
    var html   = htmlparser.parseHtml(stream)

    # import nimquery
    # let elements  =  html.querySelectorAll("[id=J_ip_history]")

    var result: seq[seq[string]]
    for tagUl in html.findAll("ul"):
        # echo "========================"
        if tagUl.attr("id") == "list":
            # echo tagDiv.innerText
            for tagLi in tagUl.findAll("li"):
                # echo tagP.text
                # for x in tagP.items:
                #     echo typeof(x)
                #     echo x.kind
                    # echo x.attr("date")
                var HavetagA = false 
                for tagA in tagLi.findAll("a"):
                    # echo tagA.innerText
                    result.add(@[tagA.innerText])
                    HavetagA = true

                if HavetagA:
                    for tagSpan in tagLi.findAll("span"):
                        # echo tagSpan.innerText
                        result[result.len - 1].add (tagSpan.innerText)
    
    # return
    # @[@["122.51.162.249", "2019-11-20-----2022-10-26"],

    # @["122.51.157.137", "2021-05-17-----2022-10-26"],
    # @["106.12.206.251", "2019-02-06-----2019-11-07"],
    # @["106.12.204.122", "2019-05-25-----2019-11-07"],
    # @["120.27.134.98", "2016-12-02-----2018-10-31"]]'
    return result
    # return "stream.readAll()"


var sameIpDomains  = ip2domain

# discard ip2domain("cip.cc")
# discard ip2domain("122.51.162.249")
echo ip2domain("122.51.162.249")



# echo repr(ip2domain_json("bing.com"))

# test
# for site in ip2domain_json("bing.com").items():
#     echo "domain=> [", site["domain"] , "]"
#     echo "title=> [", site["title"] , "]"

