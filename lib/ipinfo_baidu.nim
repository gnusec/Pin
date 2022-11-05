# /*
#  * @Description: 查询特定ip的信息. 使用baidu查询曲线调用ip138 干
#  */
# @TODO
# 还没做。现在先用cip.cc
# 
import random
import std/[asyncdispatch, httpclient]
import sequtils
# import std/httpclient

# proc ipinfo_async(domain:string): Future[string] {.async.}=
#     var client = newAsyncHttpClient()
#     return await client.getContent("https://api.webscan.cc/query/" & domain)

# # echo waitFor ipinfo("bing.com")

import json
import streams,htmlparser
import std/xmltree
import xmltree, htmlparser, strtabs
# import dom

# 输入:
#   必须是域名
# 输出:
# 2D 的字符串seq
# 历史解析IP, 解析时间段
# @[@["122.51.162.249", "2019-11-20-----2022-10-26"],
# @["122.51.157.137", "2021-05-17-----2022-10-26"],
# @["106.12.206.251", "2019-02-06-----2019-11-07"],
# @["106.12.204.122", "2019-05-25-----2019-11-07"],
# @["120.27.134.98", "2016-12-02-----2018-10-31"]]'

proc ipinfo(domain:string):  seq[seq[string]] =
    var client = newHttpClient(userAgent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/"& $rand(104) & ".0.0.0 Safari/537.36")
    # # var jsondata =  client.getContent("https://api.webscan.cc/query/" & domain)
    # # https 会经常只返回一条内容
    var resp =  client.getContent("https://site.ip138.com/" & domain & "/")
    # # echo "=> http://api.webscan.cc/?action=query&ip=" & domain
    writeFile("ip138.txt",resp)
    # echo repr(resp)
    # echo "==========================================="
    # var stream = newStringStream(resp)
    var stream = newFileStream("ip138.txt")
    var html   = htmlparser.parseHtml(stream)

    # import nimquery
    # let elements  =  html.querySelectorAll("[id=J_ip_history]")

    var result: seq[seq[string]]
    for tagDiv in html.findAll("div"):
        # echo "========================"
        if tagDiv.attr("id") == "J_ip_history":
            # echo tagDiv.innerText
            for tagP in tagDiv.findAll("p"):
                # echo tagP.text
                # for x in tagP.items:
                #     echo typeof(x)
                #     echo x.kind
                    # echo x.attr("date")
                for tagA in tagP.findAll("a"):
                    # echo tagA.innerText
                    result.add(@[tagA.innerText])


                for tagSpan in tagP.findAll("span"):
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


# var sameIpDomains  = ipinfo

echo ipinfo("cip.cc")

# echo repr(ipinfo_json("bing.com"))

# test
# for site in ipinfo_json("bing.com").items():
#     echo "domain=> [", site["domain"] , "]"
#     echo "title=> [", site["title"] , "]"

