# china icp info
# 备案信息查询
# 
# https://icplishi.com/{domain}
# 查询多次目前没有封锁
import std/[asyncdispatch, httpclient]
import json
import xmltree, htmlparser
import streams
# 放弃用这个库，无法很好的支持Unicode支付
# padding的字符应该使用中文的 Rune(12288)
# import terminaltables
import sequtils
import strutils

proc icpinfo(dst:string):seq[seq[string]] = 
    var result: seq[seq[string]]
    var client = newHttpClient(userAgent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/517.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36")
    # echo "https://icplishi.com/" & dst
    var resp =""
    try:
        resp =  client.getContent("https://icplishi.com/" & dst)
    except:
        # echo "Exception " & getCurrentExceptionMsg()
        # result.add(@["备案网站",dst])
        return result
        # echo "Fucking Here"
    # return @[@["abc"]]
    # echo "================"

    

    # writeFile("icplishi.txt",resp)
    # echo repr(resp)
    # echo "===================111========================"
    # var stream = newFileStream("icplishi.txt")
    # 没有备案的站点，返回404 http status code
    var stream = newStringStream(resp)
    var html   = htmlparser.parseHtml(stream)

 

    # var result: seq[seq[string]]
    for tagTable in html.findAll("table"):
        # echo "========================"
        for tagTr in tagTable.findAll("tr"):
            var n = 0
            # echo "+++++++++++++++"
            for tagTd in tagTr.findall("td"):
                echo tagTd.innerText
                if n==0:
                    result.add(@[ tagTd.innerText.replace("\n")])
                    (inc n)
                else:
                    result[result.len - 1].add(tagTd.innerText.replace("\n"))
        break #第一个table 的数据处理完就退出, 不管剩下的table
    echo "Finish!!!"
    result.add(@["备案网站",dst])
    return result

proc icpinfo(domains:seq[string]):seq[seq[seq[string]]]=
    # var result: seq[seq[seq[string]]]
    for domain in domains:
        # echo "Fucking => " & domain
        var icp = icpinfo(domain)
        # echo "icp.len=>" & $icp.len
        if icp.len > 0:
            # echo "funking here"
            result.add(icp)
    return result
        


# proc icpinfoPrint(domains:seq[string]) =
#     var record = icpinfo(domains)
#     # let table = newUnicodeTable()
#     let table = newTerminalTable()
#     # let table = newAsciiTable()
#     # table.separateRows = false
#     table.setHeaders(@["备案类型", "备案主体", "备案号" , "备案时间" , "备案网站"])
#     # var tmp = ""
#     table.addRows(record.mapIt(it.mapIt(it[1])))
#     # for siteinfo in record:
#     #     echo siteinfo
#     #     table.addRow(@[siteinfo[0][1],siteinfo[1][1],siteinfo[2][1],siteinfo[3][1], siteinfo[4][1]])
#     #     for item in siteinfo:
#     #         table.addRow(@[])
#     #     # echo(key)
#     #     table.addRow(value[1])
#     # # t2.setHeaders(@[newCell("ID", pad=5), newCell("Name", rightpad=10), newCell("Fav animal", pad=2), newCell("Date", 5)])
#     # table.addRow(@["1", "xmonader", "Cat, Dog", "2018-10-22"])
#     # table.addRow(@["2", "ahmed", "Shark", "2015-12-6"])
#     # table.addRow(@["3", "dr who", "Humans", "1018-5-2"])
#     printTable(table)

import nancy
import termstyle
import unicode
import marshal
# import terminal
proc icpinfoPrint(domains: seq[string]) =
    # var domainseq:seq[string]
    # if typeof(domains) is string:
    #     domainseq = @[domains]
    var record = icpinfo(domains)
    if record.len > 0:
        if defined(GLOBAL_SMART_OUTPUT):
            # 序列化输出
            echo $$record
        # echo record
        var table: TerminalTable
        # table.add yellow  "备案类型", blue unicode.alignLeft("备案主体",10,Rune(12288)), red  "备案号",  red  "备案时间",  red "备案网站"
        # if typeof(domains) is string:
        #     var siteinfo_one = record
        #     table.add yellow  alignLeft(siteinfo_one[0][1],4,Rune(12288)), blue unicode.alignLeft(siteinfo_one[1][1],5,Rune(12288)), red unicode.alignLeft(siteinfo_one[2][1],10,Rune(12288)),  white siteinfo_one[3][1],  white siteinfo_one[4][1]
        # else:
        for siteinfo in record:
            # echo siteinfo
            # styledEcho(fgRed  , unicode.alignLeft(siteinfo[0][1],15,Rune(12288)) , fgBlue , unicode.alignLeft(siteinfo[1][1],25,Rune(12288)))
            table.add yellow  alignLeft(siteinfo[0][1],4,Rune(12288)), blue unicode.alignLeft(siteinfo[1][1],5,Rune(12288)), red unicode.alignLeft(siteinfo[2][1],10,Rune(12288)),  white siteinfo[3][1],  white siteinfo[4][1]
                # table.add yellow   siteinfo[0][1],  blue  siteinfo[1][1] , red siteinfo[2][1] ,  white siteinfo[3][1],  green siteinfo[4][1]
        table.echoTable() 

proc icpinfoPrint(domain:  string) = 
    icpinfoPrint(@[domain])

# icpinfoPrint(@["cip.cc","ip.cn"])
icpinfoPrint("edu.cn")