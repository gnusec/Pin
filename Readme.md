
##简介
一个用来替代系统自带ping的工具
可以额外用来探测目标IP和域名的相关消息
目前: 反查,ip消息，类型绑定

## 执行流程
get_hostname 解析传输获取域名或者ip
然后
A: 如果ping 域名. 则
    域名->ip
            ipinfo信息归属地等
    域名->子域名
            subdomain   
    域名->历史解析
            iphistory
    域名->备案信息


B: 如果ping ip. 则
    ip->ip信息
            ipinfo信息归属地等
    ip->反查域名
            ->备案信息

C: 其他延申->ip端口->finger
            ->域名ranker(Todk)
TODO:
    windows下彩色支持更新
    数据输出成json和nim seq格式方便后续单独调用个别功能(可以配合管道组合使用后期)
    finger
    whois
    ping底层发送数据控制(发送次数控制)
    tcp ping(端口探测)
    子域名历史解析递归
    关联IP端口扫描和finger

## 编译
Linux: 
        nim c -d:release -d:ssl   -o:pin_linux pin.nim

Windows:
        nim -d:ssl c -d:release   --opt:size --passL:-lws2_32  -o:pin_windowsx64   pin.nim
        也可以在linux下编译, 不过可能无法用wine运行，建议直接在windows平台上编译widnows版本
        nim c -d:release  -d:ssl -d=mingw --app=console  --opt:size --passL:-lws2_32   -o:pin_windowsx64 pin.nim


