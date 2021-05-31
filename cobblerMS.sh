#!/usr/bin/env bash

function install {
echo "---------------------------------------------------------------"
echo "welcome to use cobbler one setup install porgamme ver 0.27(beta)"
echo "author:sddkwolf time:2020-11-23 15:16:59"
echo "---------------------------------------------------------------"
echo "*"
echo "*"
echo "*"
echo "*"
echo "*"
echo "*"
echo -e '\n'
echo "***Install start***"
echo -e '\n'

read -r -p "This step may will stop your firewalld and selinux service are you contiune? [Y/n]" input
    case $input in
        [yY][eE][sS]|[yY])
     clear
   systemctl stop firewalld  #stop the firewall and selinux
   systemctl disable firewalld
   setenforce 0
   sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/sysconfig/selinux
#################################################################### change source
   yum install wget -y
   wget git.io/superupdate.sh
   chmod +x git.io/superupdate.sh
   yum update -y
#################################################################### mkdir
   mkdir  /cobbler_dir
   mkdir  /cobbler_dir/image
   mkdir  /cobbler_dir/iso
#################################################################### basic part
   yum -y install epel-release
   yum -y install cobbler cobbler-web tftp-server dhcp httpd xinetd
   systemctl start httpd cobblerd
   systemctl enable httpd cobblerd
   sed -ri '/allow_dynamic_settings:/c\allow_dynamic_settings: 1' /etc/cobbler/settings
   systemctl restart cobblerd
#################################################################### setting
echo "Please enter your server value(IPV4)"
   read server_value
   cobbler setting edit --name=server --value=$server_value
echo  "Please enter your next_server value(IPV4)"
   read next_server_value
   cobbler setting edit --name=next_server --value=192.168.2.128
#############   tftp_server setting
sed -ri '/disable/c\disable = no' /etc/xinetd.d/tftp
   systemctl start xinetd
   systemctl enable xinetd
   systemctl restart xinetd
echo "--------------------------------------------------------------------------------------------------------"
echo "basic setting complete the next step is cobbler get-loaders maybe use much time"
echo "if process is not responding please press Ctrl+c to stop this script and run cobbler get-loaders again"
echo "the cobbler get-loaders executes successful rerun this script"
echo "--------------------------------------------------------------------------------------------------------"
   cobbler get-loaders
   systemctl start rsyncd
   systemctl enable rsyncd
   yum -y install pykickstart
################################## salt_passwd_setting
echo "please enter your root password(default_password_crypted)"
   read root_pwd
   openssl passwd -1 -salt `openssl rand -hex 4` '$root_pwd'
echo "please enter salt password"
   read salt_password
   cobbler setting edit --name=default_password_crypted --value='$salt_password'
echo "ok....please stand by"
################################## dhcp_setting
   yum -y install fence-agents
   cobbler setting edit --name=manage_dhcp --value=1
#################################
echo "basic install please edit /etc/cobbler/dhcp.template "
echo "how to edit ? visit this web ...."
exit 1
;;
[nN][oO]|[nN])
            echo "Exit install script"
            exit 1
            ;;

        *)
            echo "Invalid input..."
            ;;
    esac
}

function image_add {
clear
echo "  "
echo "  "
echo "  "
echo "Your system name?"
read system_name
    mkdir  /cobbler_dir/image/$system_name
echo "create dir done..."
echo "please choise your iso"
echo "--------------------------------------------------"
   ls /cobbler_dir/iso/
echo "--------------------------------------------------"
   read iso_dir
   mount -o loop  /cobbler_dir/iso/$iso_dir /cobbler_dir/image/$system_name
echo "Define a name for the installation source."
  read name_installation
echo "Specify installation source,support |x86│x86_64│ia64|"
  read  cpu_architecture
  cobbler import --path=/cobbler_dir/image/$system_name --name=$name_installation --arch=$cpu_architecture
echo "Adding.........."
read -r -p "Display image information and profile image? [Y/n] " input

case $input in
    [yY][eE][sS]|[yY])
        cobbler distro report --name=$name_installation-$cpu_architecture
        cobbler profile report --name=$name_installation-$cpu_architecture
        ;;

    [nN][oO]|[nN])
        echo "Bye"
          exit
           ;;

    *)
        echo "Invalid input..."
        exit 1
        ;;
esac
}
##############################################
function passwd_change {
clear
echo "please enter your root password(default_password_crypted)"
   read root_pwd
   openssl passwd -1 -salt `openssl rand -hex 4` '$root_pwd'
echo "please enter salt password"
   read salt_password
   sed -i 's%^default_password_crypted.*%default_password_crypted: "$salt_password"%g' /etc/cobbler/settings
   systemctl restart cobblerd
echo "ok...."
}
##############################################
function show_profile {
    clear
    echo "-------Which mirror do you want to show?-------"
    cobbler profile list
    echo "-----------------------------------------------"
    echo "I would like to see...."
    read  pro_list
    cobbler profile report $pro_list
}
##############################################delete_profile
function delete_profile {

    clear
    echo "-------Which mirror do you want to delete?-------"
    cobbler profile list
    echo "-----------------------------------------------"
    echo "I would like to delete...."
    read  pro_list_d
    cobbler profile remove --name=$pro_list_d
}
##############################################update_Scripts
function update_Scripts {

   clear
read -r -p "Are You Sure Update Scripts? [Y/n] " input
case $input in
    [yY][eE][sS]|[yY])
		echo "Downloading..."
		wget http://litterdevice.top:8000/image/cobblerMS.sh -O cobblerMS.sh
		;;

    [nN][oO]|[nN])
    echo "Quit The Scripts"
		exit 1
       	;;
    *)
		echo "Invalid input..."
		exit 1
		;;
esac
}
################################################uinstall_cobbler
function uinstall {

   clear
read -r -p "Are You Sure Uinstall cobbler? [Y/n] " input
case $input in
    [yY][eE][sS]|[yY])
		echo "Uinstall....."
		yum -y remove cobbler cobbler-web tftp-server dhcp httpd xinetd fence-agents pykickstart
		rm -rf /cobbler_dir
		;;

    [nN][oO]|[nN])
    echo "Quit The Scripts"
		exit 1
       	;;
    *)
		echo "Invalid input..."
		exit 1
		;;
esac
}


###############################################function menu
function menu {
clear
echo
echo -e "\t\t\tCobbler install && Image add"
echo "  "
echo "  "
echo -e "\t\t\t1. install cobbler"
echo -e "\t\t\t2. add image to cobbler"
echo -e "\t\t\t3. delete image to cobbler"
echo -e "\t\t\t4. show profile message"
echo -e "\t\t\t5. change passwd"
echo -e "\t\t\t6. update scripts"
echo -e "\t\t\t7. uinstall cobbler"
echo "  "
echo -en "\t\t\tEnter option Ctrl+C to exit:"
echo "  "
#########################################Check installation status
  mystr=`rpm -qa cobbler`
   if [ -z $mystr ];then
     echo "  "
     echo -e "\t\t\tCurrent status: not installed"
  else
     echo "  "
     echo -e "\t\t\tCurrent status: installed"
   fi
##########################################
read -n 1 option
}

while [ 1 ]
do
    menu
    case $option in
    0)
        break ;;
    1)
        install ;;
    2)
        image_add ;;
    3)
        delete_profile ;;
    4)
        show_profile ;;
    5)
        passwd_change ;;
    6)
        update_Scripts ;;
    7)
        uinstall ;;
    *)
        clear
        echo "sorry,wrong selection" ;;
    esac
    echo -en "\n\n\t\thit any to contunue"
    read -n 1 line
done
clear
