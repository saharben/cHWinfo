######################################################################################
# cHWinfo - Easy-to-Read Server hardware information								 #
# Version: 2.1 - Dec 20, 2017														 #
# Author: Sahar Ben-Attar <sahar@corintech.net>										 #
# URL: https://www.corintech.net													 #
# Github: https://github.com/saharben/cHWinfo										 #
# License: GNU General Public License v3.0											 #
# Credits: Rafa Marruedo, CacheNetworks LLC											 #
# Special thanks to Rafa Marruedo. cHWinfo is based on his vHWINFO project.	 		 #
# cHWinfo's Speed test is done thanks to CacheNetworks's CacheFly service.			 #
# 																					 #
# Copyright (C) 2017 Corintech														 #
# 																					 #
# This program is free software: you can redistribute it and/or modify it under the  #
# terms of the GNU GPL as published by the Free Software Foundation, either			 #
# version 3 of the License, or (at your option) any later version.					 #
# 																					 #
# This program is distributed in the hope that it will be useful, 					 #
# but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or  #
# FITNESS FOR A PARTICULAR PURPOSE. Use it at your own risk. Corintech and/or the 	 #
# author will not be liable for data loss, damages, loss of profits or any other 	 #
# kind of loss See the while using or misusing this program.						 #
# 																					 #
# You should have received a copy of the GNU General Public License along with		 #
# this program. If not, please refer to the GNU General Public License at			 #
# http://www.gnu.org/licenses/ for more details.									 #
######################################################################################

#!/bin/bash

######################################################################################
# Header																			 #
######################################################################################

clear

echo "																			";
echo "																			";
echo "          ____															";
echo "    _____/\   \             __  ___       _______   ____________			";
echo "   /\   /  \___\      _____/ / / / |     / /  _/ | / / ____/ __ \			";
echo "  /  \  \  /   /     / ___/ /_/ /| | /| / // //  |/ / /_  / / / /			";
echo " /    \  \/___/ \   / /__  __  / | |/ |/ // // /|  / __/ / /_/ / 			";
echo "/      \_________\ /____/_/ /_/  |__/|__/___/_/ |_/_/    \____/			";
echo "\      /         /														";
echo " \    /         / cHWinfo v2.1    20 Dec 2017    corintech.net			";
echo "  \  /         /  覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧				  ";
echo "______________________________________________________________			";
echo "																			";
echo "																			";


######################################################################################
# Hostname																			 #
######################################################################################

hostname=`hostname`;
dnsdomainname=`dnsdomainname`;

echo -e -n " Hostname:\t ";

case $hostname in
	(*[![:blank:]]*) echo ""$hostname"";;
	(*) echo " ";
esac;


######################################################################################
# IP's (Local, Internal & Public)													 #
######################################################################################

ip=`domainname -I`;
local_ip=`hostname -i`;

ip_array=($ip);
public_ip=${ip_array[0]};
internal_ip_address=""${ip_array[1]}" (LAN)";
local_ip_address=""${local_ip#::1 }" (local)";

case $public_ip in
	(*[![:blank:]]*) public_ip_address="/ "$public_ip" (Public)";;
	(*) public_ip_address="";
esac

echo -e " IP:\t\t "$internal_ip_address" "$public_ip_address"";

# Optional: Get IP via http call (w3m package is required)
# ip=`w3m -no-cookie -dump http://whatismyip.com | sed -n 's/^\([0-9\.]\+\)$/\1/p'`;


######################################################################################
# Operating System																	 #
######################################################################################

if hash sw_vers 2>/dev/null; then

	# --- macOS --- #

	virtual="Dedicated Server (not virtual)";
	echo -e " OS:\t\t "`sw_vers -productName` `sw_vers -productVersion`" (Build "`sw_vers -buildVersion`")";

	kernel_version=`system_profiler SPSoftwareDataType | grep 'Kernel Version:'`;
	echo -e " Kernel:\t "${kernel_version:22};
	echo -e " Virtual:\t "$virtual;

	cpu=`sysctl -a machdep.cpu.brand_string`;
	echo -e " CPU:\t\t "${cpu:26};

	cores=`sysctl hw.ncpu | awk '{print $2}'`;
	echo -e -n " Virtual CPU's:\t\t "$cores;

	if [[ $cores>1 ]]; then
		echo " Cores";
	else
		echo " Core";
	fi

	ram=`sysctl hw.memsize`;
	ram=${ram:12};
	ram=$((ram/1024/1024));
	echo -e -n " RAM:\t\t "$ram "MB";

	free=`vm_stat | grep 'Pages free:'`;
	free=${free:12};
	free=${free%.*};
	free=$((free*4));
	free=$((free/1024));
	free=$((free*100));
	free=$((free/ram));
	used=$((100-$free));
	echo " ("$used"% Used)";

	hd=`diskutil info /dev/disk0 | grep 'Total Size:'`;
	hd=${hd:29};
	hd=${hd%.*};
	echo -e " HD:\t\t "$hd "GB";

	speed="`wget -O /dev/null http://cachefly.cachefly.net/1mb.test 2>&1 | grep '\([0-9.]\+ [KM]B/s\)'`";
	speed=${speed:21};
	speed=${speed%)*};
	echo -e " Cachefly 1Mb:\t "$speed;

else

	# --- Linux  --- #

	virtual="\e[42mDedicated Server\e[0m (Not Virtual)";
	kernel_version=`uname -r`;

	machine_type=`uname -m`;
	if [ ${machine_type} == 'x86_64' ]; then
		os_type=" 64-Bit";
	else
		os_type=" 32-Bit";
	fi

	if [ -f /etc/os-release ]; then
		. /etc/os-release;
		os_name=$NAME;
		os_version=$VERSION_ID;
	elif [ -f /etc/system-release ]; then
		os_name=$(cat /etc/system-release);
		os_version="";
	elif type lsb_release >/dev/null 2>&1; then
		os_name=$(lsb_release -si);
		os_version=$(lsb_release -s);
	elif [ -f /etc/lsb-release ]; then
		. /etc/lsb-release;
		os_name=$DISTRIB_ID d;
		os_version=$DISTRIB_RELEASE;
	elif [ -f /etc/debian_version ]; then
		os_name=Debian Linux;
		os_version=$(cat /etc/debian_version);
	elif [ -f /etc/redhat-release ]; then
		os_name=$(cat /etc/redhat-release);
		os_version="";
	elif [ -f /etc/centos-release ]; then
		os_name=$(cat /etc/centos-release);
		os_version="";
	else
		os_name=$(uname -s);
		os_version="";
	fi

	echo -e " OS:\t\t "$os_name $os_version $os_type;
fi


######################################################################################
# Kernel																			 #
######################################################################################

echo -e " Kernel:\t "$kernel_version;

if hash ifconfig 2>/dev/null; then
	eth=`ifconfig`;
else
	eth="";
fi


######################################################################################
# Virtualization																	 #
######################################################################################

virtualx=`dmesg`

if [[ "$eth" == *eth0* ]]; then
	virtual="\e[42mDedicated Server\e[0m (Not Virtual)";

	if [[ "$virtualx" == *kvm-clock* ]]; then
		virtual="KVM";
	fi

	if [[ "$virtualx" == *"VMware Virtual Platform"* ]]; then
		virtual="VMware";
	fi

	if [[ "$virtualx" == *"Parallels Software International"* ]]; then
		virtual="Parallels";
	fi

	if [[ "$virtualx" == *VirtualBox* ]]; then
		virtual="VirtualBox";
	fi

else

	if [ -f /proc/user_beancounters ]; then
		virtual="OpenVZ";
	fi
fi

if [ -e /proc/xen ]; then
	virtual="Xen";
fi

echo -e " Virtualization: "$virtual;


######################################################################################
# CPU(s) / Virtual CPU(s)															 #
######################################################################################

cpu=`cat /proc/cpuinfo | grep "model name" | head -n 1`;
bogo=`cat /proc/cpuinfo | grep "bogomips" | head -n 1`;
cores=`grep -c processor /proc/cpuinfo`;

if [[ "$cores" > 1 ]]; then
	label="Cores";
else
	label="Core";
fi

echo -e " CPU(s):\t "${cpu:13};
echo -e " Virtual CPU(s): "$cores $label / ${bogo:11} BogoMips;


######################################################################################
# Memory																			 #
######################################################################################

mem=`free -m`;

pos=`expr index "$mem" M`;
ram=${mem:($pos+10):10};
ram=${ram//[[:blank:]]/};

pos=`expr index "$mem" p`;
swap=${mem:($pos+10):10};
swap=${swap//[[:blank:]]/};

busy=`free -t -m | egrep Mem | awk '{print $3}'`;
busy=$((busy*100));
busy=$((busy/ram));

busy_swap=`free -t -m | egrep Swap | awk '{print $3}'`;
busy_swap=$((busy_swap*100));

if (($swap>0)); then
	busy_swap=$((busy_swap/swap));
fi

if (($busy>75)); then
	label1="\e[43m";
	label2="\e[0m";
else
	label1="";
	label2="";

	if (($busy>90)); then
		label1="\e[41m";
		label2="\e[0m";
	else
		label1="";
		label2="";
	fi
fi

echo -e " RAM:\t\t "$ram" MB ("$label1$busy"% Used"$label2")" / Swap $swap MB "("$busy_swap"% Used)"


######################################################################################
# HDD/SSD																			 #
######################################################################################

total=`df -h --total | grep 'total' | awk '{print $2}'`;
used=`df -h --total | grep 'total' | awk '{print $5}'`;
used="${used//%}"

if (($used>75)); then
	label1="\e[43m";
	label2="\e[0m";
else
	label1="";
	label2="";

	if (($used>90)); then
		label1="\e[41m";
		label2="\e[0m";
	else
		label1="";
		label2="";
	fi
fi

hdspeed=`dd if=/dev/zero of=ddfile bs=16k count=12190 2>&1`;
sync
rm -rf ddfile;
hdspeed1=" / Inkling Speed "`echo $hdspeed | grep "s, " | awk '{print $14}'`;
hdspeed2=`echo $hdspeed | grep "s, " | awk '{print $15}'`;

if (($used>0)); then
	echo -e " HDD:\t\t "$total "("$label1$used"% Used"$label2")"$hdspeed1 $hdspeed2;
else
	echo -e " HDD:\t\t (\e[43mMultiple partitions is not supported yet\e[0m)"$hdspeed1 $hdspeed2;
fi


######################################################################################
# Network Speed	Test																 #
######################################################################################

speed="`wget -O /dev/null http://cachefly.cachefly.net/10mb.test 2>&1 | grep '\([0-9.]\+ [KM]B/s\)'`";
pos=`expr index "$speed" "s"`;

unidad=${speed:($pos-4):4};
speed=${speed:21:($pos-25)};

if [[ "$unidad" == "MB/s" ]]; then
	pos=`expr index "$speed" .`;
fi

if (($pos<1)); then
		pos=`expr index "$speed" ,`;
fi

num=${speed:0:$pos-1};

if (($num>12)); then
	speed_test_info="(\e[42mProbably Gigabit Port\e[0m)";
else
	speed_test_info="";
fi

echo -e " Speed Test:\t "$speed $unidad $speed_test_info"(10MB Test)";


######################################################################################
# Footer																			 #
######################################################################################

echo " ";
echo "______________________________________________________________    ";
echo " ";
echo " ";


######################################################################################
# cHWinfo END																		 #
######################################################################################
