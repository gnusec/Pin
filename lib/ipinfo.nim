# /*
#  * @Description: 查询特定ip的信息. cip.cc
#  */
# http://www.cip.cc/122.51.157.137
# 
import std/[asyncdispatch, httpclient]

import streams
import net
import strutils

# ipinfo
# 输入:
#   必须是ip
# 输出:
# 字符串seq
# @["IP\t: 122.51.162.249", "地址\t: 中国  广东  汕尾", "运营商\t: hzgit.com", "数据二\t: 上海市 | 腾讯云", "数据三\t: 中国上海上海市 | 电信", "URL\t: http://www.cip.cc/122.51.162.249"]
#
proc ipinfo(ip:string):   seq[string] =
    if not isIpAddress(ip):
        quit("isIpAddress Chck Error => [" & ip & "]" )
    # 必须用curl 或者
    var client = newHttpClient(userAgent="curl")
    # @TODO
    # 这里会有一个403异常无法处理的情况,需要额外处理
    # 比如提交cip.cc自己的IP的时候
    # unhandled exception: 403 Forbidden 
    # 有时候服务会无法使用，要使用其他的接口来查询
    # https://site.ip138.com/cip.cc
    # https://ipwhois.cnnic.net.cn/bns/query/Query/ipwhoisQuery.do?txtquery=122.51.157.137&queryOption=ipv4
    # 
    var resp =  client.getContent("https://www.cip.cc/" & ip )
    var stream = newStringStream(resp)

    # var result: seq[string]
    for line in stream.lines():
        if not line.isEmptyOrWhitespace():
            result.add(line)

    return result


proc ipinfoPrint(ip:string): seq[string] =
    # @TODO
    result = ipinfo(ip)
    # echo repr(result)
    echo result.join("\r\n")


# echo ipinfo("122.51.162.249")
# discard ipinfoPrint("122.51.162.249")