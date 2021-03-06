# Cobbler-Manage-Scripts
在您的服务器上一键部署cobbler以及管理cobbler镜像
## 如何使用？
PS:目前仅支持Centos 7系统  

1.下载本脚本到服务器。  
2.chmod +x 赋予权限然后运行该脚本。  

** 主界面浏览 **  
目前支持的功能有这些，如有需要可以提一下Issues，能做尽量做。
![https://github.com/tiny-wolf/Cobbler-Manage-Scripts/blob/main/cobble_imager/main.PNG](https://github.com/tiny-wolf/Cobbler-Manage-Scripts/blob/main/cobble_imager/main.PNG)  


### 安装cobbler  
1.运行脚本，选择1，然后安装即可，目前还不能做到完全自动，有两个步骤需要手动完成  
第一个是定义default_password_crypted，输入明文密码以后会对明文密码加盐，需要您自己手动复制这个密码，然后根据输出信息黏贴确认。  
![https://github.com/tiny-wolf/Cobbler-Manage-Scripts/blob/main/cobble_imager/passwd.PNG](https://github.com/tiny-wolf/Cobbler-Manage-Scripts/blob/main/cobble_imager/passwd.PNG)  
第二个是编辑dhcp.sample，由于部署环境存在较大差异，所以dhcp.sample文件需要自己手动修改，如何编辑？请看下文。

### 编辑 dhcp.sample  
做一个简单的假设，我有一台服务器打算作为PXE Server，目前有三个网口在使用，eth1作为外网数据通信端口，eth2作为内网数据交换口，eth3作为PXE装机专用口，我们应该如何配置？  
设：  
eth 1：xxx.xxx.xxx.xxx(外网地址)  
eth 2：192.168.30.5（内网地址）  
eth 3：192.168.50.1（server,next_server)  
![https://github.com/tiny-wolf/Cobbler-Manage-Scripts/blob/main/cobble_imager/dhcp.PNG](https://github.com/tiny-wolf/Cobbler-Manage-Scripts/blob/main/cobble_imager/dhcp.PNG)  
subnet该填写为您eth3网段，netmask根据需求填写，option routers以及option domain-name-servers可以注释掉，如果有再填写，subnet_mask应要与上面的netmask一致，range dynamic-bootp为ip的分配范围，也决定了您能在在同一时间安装多少台服务器。  
然后保存，输入cobbler rsync，结果为 *** TASK COMPLETE *** 即为完成，随便找台未安装系统的服务器，接到eth3上通过网络启动，如果弹出cobbler的启动界面，安装成功。  


更新记录  
ver 0.30
更新时间：更新时间：2021年6月24日15:45:14  
1.由于官方停止了老版本的cobbler支持，直接cobbler get-loaders命令会提示404，现在会主动下载cobbler-old文件，修复了这个问题，官方推荐使用Centos8或者较新的fedora，后续会做这个系统的版本。 
2.修复了dhcpd，tftp可能在完成安装后无法启动的问题。 
3.一些排版方面的修正 

ver 0.28    
更新时间：2021年6月21日15:25:10   
1.现在改密码的时候不需要再次输入加盐密码 


ver 0.27    
更新时间：2020年11月19日11:32:21  
1.添加了脚本更新的功能 

ver 0.26  
更新时间：2020年10月10日11:40:56  
1.修改了一些死亡机翻  
2.修改了排版格式，会更加美观一些  
3.增加了删除镜像、显示profile、修改default_password_crypted的选项  

ver 0.22  
1.修改了一些错误  

ver 0.21  
1.简化了添加镜像的步骤  
2.提升了可读性，修改部分排版和文本信息  

ver 0.2  
1.添加多级菜单  
2.增加了添加镜像的选项  

ver 0.1  
版本发布，可以实现自动化安装Cobbler，dhcp需要手动设定  
