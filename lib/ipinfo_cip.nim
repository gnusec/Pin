# /*
#  * @Description: 查询特定ip的信息. cip.cc
#  */
# http://www.cip.cc/122.51.157.137
# 
import std/[asyncdispatch, httpclient])

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

    var resp =  client.getContent("https://www.cip.cc/" & ip )

    var stream = newStringStream(resp)


    var result: seq[string]
    for line in stream.lines():
        if not line.isEmptyOrWhitespace():
            result.add(line)

    return result



# echo ipinfo("122.51.162.249")
