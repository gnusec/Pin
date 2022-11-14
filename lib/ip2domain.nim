# ip反查
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
# 参数:
# 必须是IP
# 返回:
# 2D seq
# @["bollonline.com", "2020-10-11-----2022-10-11"], @["meikankan.com", "2021-11-30-----2022-10-11"]]
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

    var result: seq[seq[string]]
    for tagUl in html.findAll("ul"):
        # echo "========================"
        if tagUl.attr("id") == "list":
            # echo tagDiv.innerText
            for tagLi in tagUl.findAll("li"):
                var HavetagA = false 
                for tagA in tagLi.findAll("a"):
                    # echo tagA.innerText
                    result.add(@[tagA.innerText])
                    HavetagA = true

                if HavetagA:
                    for tagSpan in tagLi.findAll("span"):
                        # echo tagSpan.innerText
                        result[result.len - 1].add (tagSpan.innerText)

    return result


var sameIpDomains  = ip2domain

import nancy
import termstyle

proc ip2domainPrint(ip:string): seq[seq[string]] =
    result = ip2domain(ip)
    var table: TerminalTable
    for domainAndTime in result:
        table.add yellow  domainAndTime[0] , blue domainAndTime[1]
    if table.rows > 0:
        table.echoTable()


# discard ip2domain("cip.cc")
# discard ip2domain("122.51.162.249")
# echo ip2domain("122.51.162.249")



# echo repr(ip2domain_json("bing.com"))

# test
# for site in ip2domain_json("bing.com").items():
#     echo "domain=> [", site["domain"] , "]"
#     echo "title=> [", site["title"] , "]"

