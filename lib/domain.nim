# 从uri中提取域名或者ip

import uri
import strutils
proc get_hostname(uri: string): string =
    var uriObj = parseUri(uri)
    if  not isEmptyOrWhitespace(uriObj.hostname):
        return uriObj.hostname 
    elif  not isEmptyOrWhitespace(uriObj.path):
        return uriObj.path
    else:
        quit("Error In uri parse =>[" & uri &  "]")

        

# let host = parseUri("https://nim-lang.org")
# let blog = "/blog.html"
# let bloguri = host / blog
# assert $host == "https://nim-lang.org"
# assert $bloguri == "https://nim-lang.org/blog.html"


# var res = parseUri("ftp://Username:Password@Hostname")
# assert res.username == "Username"
# assert res.password == "Password"
# assert res.scheme == "ftp"
# echo repr(res)

# res = parseUri("https://www.baidu.com")
# echo repr(res)

# res = parseUri("127.0.0.1")
# echo repr(res)

# res = parseUri("https://192.168.9.188")
# echo repr(res)

# res = parseUri("https://www.baidu.com")
# echo repr(res)

# var res = parseUri("127.0.0.1")
# echo repr(res)
# # hostname = "",
# # path = "127.0.0.1",


# res = parseUri("localhost")
# echo repr(res)
# # hostname = "",
# # path = "localhost",

# res = parseUri("winger:pwd@localhost")
# echo repr(res)


# res = parseUri("https://winger:pwd@localhost")
# echo repr(res)

# res = parseUri("https://localhost")
# echo repr(res)


