# argv传参细节
# https://stackoverflow.com/questions/55646129/nim-argv-equivalent

when defined linux:
  {.compile: "lib/ping/linux_ping.c".}

  proc cmain(argc: cint, argv: cstringArray): cint
    {.importc: "cmain".}

  # import os

  # var argv =  @[getAppFilename()]  &  commandLineParams()
  # var cargc = cint(argv.len)

  # var cargv: cStringArray = argv.allocCStringArray()
  # # echo cint(cargc)
  # # echo "argv=>",repr(argv)
  # # echo repr(cargv)
  # discard cmain(cargc, cargv)
  # cargv.deallocCStringArray()

# var cdata: cstringArray = @["pin","127.0.0.1"].allocCStringArray()
# main(2, cdata)
# cdata.deallocCStringArray()


when defined windows:
  #{.compile: "test.c".}
  {.compile: "lib/ping/windows_ping.c".}
  # echo "Windows Here!!!"
  proc cmain(argc: cint, argv: cstringArray): cint
    {.importc: "cmain".}

import os


proc ping_cli() =
  var argv = @[getAppFilename()] & commandLineParams()
  var cargc = cint(argv.len)
  var cargv: cStringArray = argv.allocCStringArray()
  # echo cint(cargc)
  # echo "argv=>",repr(argv)
  # echo repr(cargv)
  discard cmain(cargc, cargv)
  cargv.deallocCStringArray()


proc ping(dst: string) =
  var argv = @[getAppFilename(), dst]
  var cargc = cint(argv.len)
  var cargv: cStringArray = argv.allocCStringArray()
  # echo cint(cargc)
  # echo "argv=>",repr(argv)
  # echo repr(cargv)
  discard cmain(cargc, cargv)
  cargv.deallocCStringArray()

proc writeVersion() =
  echo "v0.1"

proc writeHelp() =
  echo """Smart Ping tool v0.1 [by winger]
Usage:
  Need use sudo(in linux)
  Simple ping(like linux ping)
  ./Pin 127.0.0.1
  Smart ping(get more info)
  ./Pin -a http://www.somedomain.com
  ./Pin -a somedomain.com
  ./Pin -a 114.114.114.114
  ./Pin --all 114.114.114.114
"""


# 获取参数
# var ARGC: int
# 目标uri
var DST_URI: string
var FLAG_ALL = false
import parseopt

if paramCount() == 0:
  writeHelp()
  quit()
for kind, key, value in getOpt():
  case kind
  of cmdArgument:
    # echo "key-> ",key
    # echo "value-> ",value
    DST_URI = key
    # ARGC.inc
  of cmdLongOption, cmdShortOption:
    case key
    of "all", "a":
      echo "Begin Pin Target!!!"
      FLAG_ALL = true
    of "v", "version":
        writeVersion()
        quit()
    of "h", "help":
        writeHelp()
        quit()
    else:
      echo "Unknown option: ", key
      writeHelp()
      quit()
  of cmdEnd:
    discard


# var DST_URI = commandLineParams()[^1]
# include "lib/domain.nim"
include lib/domain
include lib/icp
include lib/ipinfo
include lib/ip2domain
include lib/domain2iphistory
# import net
# import sequtils

var dstHost : string  = get_hostname(DST_URI)
echo( "[Target Host]  ->  [" & dstHost &  "]") 

import nativesockets
# 这里只获取第一个地址
# 系统全局代理的情况下, 有可能回获取不到真实的IP地址
# var dstHostIp = getHostByName(dstHost).addrList[0]
# echo( "Target IP ->    [" & dstHostIp &  "]") 

# json node
# 通过API接口获取ip信息
# var dstIPinfo = ipinfo(dstHost)
# var dstHostIp = dstIPinfo["ip"].getStr
# 这里要加个容错
var dstHostIp = getHostByName(dstHost).addrList[0]
echo( "[Target   IP]  ->  [" & dstHostIp &  "]") 



if FLAG_ALL:
  # echo dstHost
  # echo icpinfo(dstHost);
  # echo ipinfo(dstHost);
  # echo ip2domain(dstHost);
  # echo sameIpDomains(dstHost);
  # 如果是IP则，先获取同IP所有站点信息，然后查询每个域名备案信息
  # webscan 的 api有时候只会返回一条
  # 得用http查询
  # IP138有时候会少
  # echo "[IP]=>" & $dstHostIp


  
  echo "\n[IP地址信息]"
  discard ipinfoPrint(dstHostIp)

  echo "\n[同IP站点信息]"
  var domainsSameIP =  ip2domainPrint(dstHostIp)
  # echo repr(domainsSameIP)
  var domainsSeq  = newSeq[string]()
  # var domainsIcp  = newJArray()
  for seqDomain in domainsSameIP.items():
    domainsSeq.add(seqDomain[0])
  domainsSeq = domainsSeq.deduplicate()
  # echo "==================================="
  # echo repr(domainsSeq)
  # echo "==================================="
  echo "\n[同IP站点备案信息]"
  for domain in domainsSeq:
    icpinfoPrint(domain)
  # else:
  #     # ./Pin -a xxx.com
  #     # 命令行参数如果是域名则查询此域名的历史解析记录
  #     discard domain2iphistoryPrint(dstHost)
  # # ./Pin -a www.baidu.com
  # 命令行参数如果是IP地址则
  # 命令行参数提供的是域名的话, 则要额外查询其
  if not isIpAddress(dstHost):
    echo "\n[域名历史解析IP记录]"
    discard domain2iphistoryPrint(dstHost)
      

  # quit();
  echo "\n"
  ping(dstHost)


echo "\n"
ping(dstHost)

