#define WIN32_LEAN_AND_MEAN
#include <stdio.h>
#include <stdlib.h>
#include<windows.h>  //Sleep函数所需
#include <winsock2.h>
#pragma  comment(lib,"ws2_32.lib") //套接字编程需要的库文件


#define ICMP_ECHO 8      // 请求回显 ping请求 请求回显8
#define ICMP_ECHOREPLY 0 // 回显应答0
#define ICMP_MIN 12      // minimum 12 byte icmp message(just header)

/* IP头部  20bytes*/
typedef struct iphdr
{
	unsigned char h_len : 4;       // 首部长度
	unsigned char version : 4;     // 版本号
	unsigned char tos;             // 服务类型
	unsigned short total_len;      // 总长度
	unsigned short ident;          // 标识
	unsigned short frag_and_flags; // 标志和片偏移
	unsigned char ttl;             //跳数
	unsigned char proto;           // 协议
	unsigned short checksum;       // 校验和
	unsigned int sourceIP;         //源地址
	unsigned int destIP;           //目的地址
} IpHeader;

/* ICMP头部  12 bytes */
typedef struct _ihdr
{
	BYTE i_type;      //类型
	BYTE i_code;      //代码
	USHORT i_cksum;   //校验和
	USHORT i_id;      //标识符
	USHORT i_seq;     //序号
	/* 下面的时间戳不是标准ICMP头部，是为了容易计算时间定义的，
	整个头部大小因此从8字节扩大到了12字节*/
	ULONG timestamp;
} IcmpHeader;

#define STATUS_FAILED 0xFFFF
#define MAX_PACKET 1024
#define xmalloc(s) HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, (s))
#define xfree(p) HeapFree(GetProcessHeap(), 0, (p))

USHORT checksum(USHORT *, int);
void fill_icmp_head(char *);
void decode_resp(char *, int, struct sockaddr_in *);

//参数过少就会调用该函数输出argv[0]
void Usage(char *progname)
{
	fprintf(stderr, "Usage:\n");
	fprintf(stderr, "%s <host>\n", progname);
	ExitProcess(STATUS_FAILED);
}

int cmain(int argc, char **argv)
{
	WSADATA wsaData;
	SOCKET sockRaw;
	struct sockaddr_in dest, from;
	struct hostent *hp;
	int bread, datasize;
	int fromlen = sizeof(from);
	char *dest_ip;
	char *icmp_data;
	char *recvbuf;
	unsigned int addr = 0;
	USHORT seq_no = 0;

	if (WSAStartup(0x0101, &wsaData) != 0)
	{
		fprintf(stderr, "WSAStartup failed: %d\n", GetLastError());  //错误提示输出到指定设备
		ExitProcess(STATUS_FAILED);  //结束调用的进程和它的线程
	}
	//如果命令参数小于两个，结束，因为argv[0]肯定是路径和文件名，
	//只有argv[1]及以后才是真正的参数，只有1个参数就相当于没参数
	if (argc < 2)
	{
		Usage(argv[0]);
	}
	//创建套接字
	if ((sockRaw = socket(AF_INET, SOCK_RAW, IPPROTO_ICMP)) == INVALID_SOCKET) //ipv4，原始套接字，ICMP协议
	{
		fprintf(stderr, "WSAStartup failed: %d\n", GetLastError());
		ExitProcess(STATUS_FAILED);
	}

	memset(&dest, 0, sizeof(dest));  //目标地址缓存置0
	hp = gethostbyname(argv[1]);   //获取要ping的域名或ip地址
	if (hp != NULL)
	{
		memcpy(&(dest.sin_addr), hp->h_addr, hp->h_length);  //域名解析过来的ip地址给目的地址缓存
		dest.sin_family = AF_INET;  //设置为IPv4协议
		dest_ip = inet_ntoa(dest.sin_addr);  //将缓存里的ip地址转换成点分十进制格式
	}
	else
	{
		fprintf(stderr, "Unable to resolve %s\n", argv[1]);  //输出无法识别参数的错误
		ExitProcess(STATUS_FAILED);  
	}

	datasize = sizeof(IcmpHeader);   //ICMP报文设置为12个字节
	icmp_data = (char*)xmalloc(MAX_PACKET); //为ICMP报文申请了1024字节，最大可以定义65535-20-8
	recvbuf = (char*)xmalloc(MAX_PACKET);   //申请接收缓冲区，大小和上面的一样，1024
	if (!icmp_data)
	{
		fprintf(stderr, "HeapAlloc failed %d\n", GetLastError());
		ExitProcess(STATUS_FAILED);
	}//申请不成功就输出这个错误咯
	memset(icmp_data, 0, MAX_PACKET);  //刚申请的ICMP缓存置0
	fill_icmp_head(icmp_data);  //填充ICMP数据报

	//无限ping循环
	while (1)
	{
		int bwrote;
		//以下四行是每次发送请求对ICMP报文的相关字段做修改
		((IcmpHeader *)icmp_data)->i_cksum = 0;  //校验和置0
		((IcmpHeader *)icmp_data)->timestamp = GetTickCount();  //GetTickCount函数的作用是返回从操作系统启动所经过的毫秒数
		((IcmpHeader *)icmp_data)->i_seq = seq_no++;  //序列号加一
		((IcmpHeader *)icmp_data)->i_cksum = checksum((USHORT *)icmp_data, sizeof(IcmpHeader));  //计算校验和并填充
		
		bwrote = sendto(sockRaw, icmp_data, datasize, 0, (struct sockaddr *)&dest, sizeof(dest));  //发送报文
		if (bwrote == SOCKET_ERROR)
		{
			fprintf(stderr, "sendto failed: %d\n", WSAGetLastError());
			ExitProcess(STATUS_FAILED);
		}//发送失败的错误
		if (bwrote < datasize)
		{
			fprintf(stdout, "Wrote %d bytes\n", bwrote);
		}//发送的报文长小于ICMP报文长的话就有问题了

		bread = recvfrom(sockRaw, recvbuf, MAX_PACKET, 0, (struct sockaddr *)&from, &fromlen);  //接收应答报文
		if (bread == SOCKET_ERROR)
		{
			if (WSAGetLastError() == WSAETIMEDOUT)  //WSAGetLastError返回windows socket操作的最后一个错误状态
			{
				printf("timed out\n");
				continue;
			}//超时错误
			fprintf(stderr, "recvfrom failed: %d\n", WSAGetLastError());
			perror("revffrom failed.");  //其它接收失败错误
			ExitProcess(STATUS_FAILED);
		}
		decode_resp(recvbuf, bread, &from);  //对收到的报文做解析
		Sleep(1000);  //每次请求停个1000微秒
	}
	closesocket(sockRaw);  //关闭socket
	xfree(icmp_data);  //释放icmp报文缓存，和前面的xmalloc对应
	xfree(recvbuf);  //释放接收缓存
	WSACleanup(); /* 清除ws2_32.dll */
	return 0;
}

void fill_icmp_head(char *icmp_data)
{
	IcmpHeader *icmp_hdr;

	icmp_hdr = (IcmpHeader *)icmp_data;
	icmp_hdr->i_type = ICMP_ECHO;  //类型字段置8，标识回送请求
	icmp_hdr->i_code = 0;  //代码字段填0
	icmp_hdr->i_cksum = 0;  //校验和置0
	icmp_hdr->i_id = (USHORT)GetCurrentProcessId();  //标识符字段填写当前进程ID
	icmp_hdr->i_seq = 0;  //序列号初始为0
}

/* 	收到的应答数据包是IP包，我们需要对其进行解析，
    然后才能获得想要的信息                     */
void decode_resp(char *buf, int bytes, struct sockaddr_in *from)
{
	IpHeader *iphdr;
	IcmpHeader *icmphdr;
	unsigned short iphdrlen;
	iphdr = (IpHeader *)buf;
	iphdrlen = iphdr->h_len * 4; // 首部长度字段的单位是4字节
	if (bytes < iphdrlen + ICMP_MIN)
	{
		printf("Too few bytes from %s\n", inet_ntoa(from->sin_addr));
	}//收到的报文总长小于IP头部+ICMP头部的长度，说明没什么数据。。。
	icmphdr = (IcmpHeader *)(buf + iphdrlen);  //指针移动到ICMP头部
	if (icmphdr->i_type != ICMP_ECHOREPLY)
	{
		fprintf(stderr, "non-echo type %d recvd\n", icmphdr->i_type);
		return;
	}//ICMP的类型字段应为0，回送应答
	if (icmphdr->i_id != (USHORT)GetCurrentProcessId())
	{
		fprintf(stderr, "someone else's packet!\n");
		return;
	}//Id应为当前进程Id
	printf("%d bytes from %s:", bytes, inet_ntoa(from->sin_addr));  //包长和地址输出
	printf(" icmp_seq = %d. ", icmphdr->i_seq);  //包序号
	printf(" time: %d ms ", GetTickCount() - icmphdr->timestamp);  //经历的时间，这就是头部多定义的时间戳字段的作用了
	printf("\n");
}

//校验和计算
USHORT checksum(USHORT *buffer, int size)
{
	unsigned long cksum = 0;
	//下面要注意的是之所以定为USHORT类型，是因为这个类型刚好16位
	while (size > 1)
	{
		cksum += *buffer++;  //指针以十六位一组移动加到校验和
		size -= sizeof(USHORT);  //计算过的部分把长度减掉
	}
	if (size)
	{
		cksum += *(UCHAR *)buffer;  //最后有剩余，强制类型转换并加到校验和
	}
	cksum = (cksum >> 16) + (cksum & 0xffff);  //右移16位的值加上和全一与运算的值
	cksum += (cksum >> 16);  //再加上右移十六位的值
	return (USHORT)(~cksum);  //返回非运算结果
}