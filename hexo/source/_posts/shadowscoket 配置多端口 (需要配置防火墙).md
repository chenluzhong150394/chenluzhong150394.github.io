---
title: Shadowsocet配置多端口
date: 2019-08-10 13:52:50
tags: Shadowsocet
---









## shadowscoket 配置多端口 (需要配置防火墙)



先将要设置的端口在firewall防火墙放行

~~~
firewall-cmd --zone=public --add-port=52300/tcp --permanent  
firewall-cmd --zone=public --add-port=52300/udp --permanent  
~~~

查看firewall 开放的所有端口

~~~
firewall-cmd --zone=public --list-ports
~~~



然后去将原来的shadowscoket配置文件进行备份

~~~  
cp  /etc/shadowsocks.json  /etc/shadowsocks.json.bak
~~~

然后打开配置文件替换成以下内容

~~~
vim   /etc/shadowsocks.json
~~~

~~~
{
"server":"0.0.0.0",
"local_address":"127.0.0.1",
"local_port":1080,
"port_password":{
"52300":"chenshuo003",
"52500":"chenshuo003"
},
"obfs":"plain",
"obfs_param":"",
"timeout":300,
"method":"aes-256-cfb",
"fast_open": false
}
~~~



然后重启shadowsocket服务并查看状态

~~~
# 重启服务
/etc/init.d/shadowsocks restart
## 查看服务状态
/etc/init.d/shadowsocks status
~~~

重启锐速

~~~
## 重启锐速
service serverSpeeder restart

##查看锐速状态
service serverSpeeder status
~~~







#### 查看当前端口有多少IP链接(脚本有后台,需要手动禁止ip--hosts.deny)

---

使用netstat 命令

~~~
netstat -anp |  grep 52300
~~~

找到链接的ip,只要不是自己的,全部禁了

~~~
### 打开hosts.deny文件
vim /etc/hosts.deny 
### 将想要禁止的ip添加上去
125.23.223.2
~~~

然后重启网卡服务,使hosts.deny文件生效

~~~
systemctl restart network
~~~







