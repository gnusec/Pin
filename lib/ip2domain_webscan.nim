# ip reverse query associated domain name
# ip 反查关联域名
# webscan 有时候无法使用
# @TODO
# 用ip138
# https://site.ip138.com/cip.cc/whois.htm
# https://github.com/Potato-py/ipInfoSearch/blob/master/module/getDomain.py
# https://rapiddns.io/sameip/cip.cc
# 
import random
import std/[asyncdispatch, httpclient]
# import std/httpclient

proc ip2domain_async(domain:string): Future[string] {.async.}=
    var client = newAsyncHttpClient()
    return await client.getContent("https://api.webscan.cc/query/" & domain)

# echo waitFor ip2domain("bing.com")

import json

proc ip2domain(domain:string):  JsonNode =
    var client = newHttpClient(userAgent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/"& $rand(104) & ".0.0.0 Safari/537.36")
    # var jsondata =  client.getContent("https://api.webscan.cc/query/" & domain)
    # https 会经常只返回一条内容
    var jsondata =  client.getContent("http://api.webscan.cc/?action=query&ip=" & domain)
    echo "=> http://api.webscan.cc/?action=query&ip=" & domain
    return parseJson(jsondata)

var sameIpDomains  = ip2domain
# echo repr(ip2domain_json("bing.com"))

# test
# for site in ip2domain_json("bing.com").items():
#     echo "domain=> [", site["domain"] , "]"
#     echo "title=> [", site["title"] , "]"

