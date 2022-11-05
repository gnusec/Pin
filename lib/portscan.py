def portscan(host, ports):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(0.5)
        s.connect((host, int(ports)))
        s.close()
        return True
    except:
        return False

def main():
    print("""
    ##############################################################
    #                                                            #
    #   Author:  Mr.R4v3
    #   Date:    2019-05-15
    #   Version: 1.0
    #   Github:  https://github.com
    #                                                            #
    ##############################################################
    """)
    if len(sys.argv) != 2:
        print("Usage: python3 portscan.py <ip>")
        sys.exit()
    ip = sys.argv[1]
    print("Scanning ports from 1 to 1024")
    for port in range(1, 1024):
        if portscan(ip, port):
            print("Port {} is open".format(port))

if __name__ == '__main__':
    main()
    