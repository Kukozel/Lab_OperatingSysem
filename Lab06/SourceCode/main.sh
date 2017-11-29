#! /bin/bash

. func.sh

#小数点保留位数
sc=2
#磁道个数n
n=9
#开始磁道号m
m=100
#磁盘访问序列
TrackOrder=(55 58 39 18 90 160 150 38 184)
#磁头移动方向(对SCAN和循环SCAN算法有效)定义为1向外,0向内
declare -i direction
direction=1

echo "实验六  磁盘调度算法"
echo "----------默认数据-------------"
echo -e "磁道个数:\t${n}"
echo -e "开始磁道号:\t${m}"
echo -e "磁盘访问序列:\t${TrackOrder[@]}"
echo -e "磁头移动方向:\t向外"
echo "-------------------------------"

echo "实验数据选择 1-使用默认数据，2-输入新数据"

read keypressData
case "$keypressData" in
	1 )
		;;
	2 )
		echo "请输入磁道个数n:"
		read new_n
		n="${new_n}"
		echo "请输入开始磁道号m:"
		read new_m
		m="${new_m}"
		echo "请输入磁盘访问序列:(长度${n})"
		read -a new_P
		TrackOrder=("${new_P[@]}")
		echo "请输入磁头移动方向:(向外为1,向内为0)"
		read new_direction
		direction=new_direction
		;;
	* )
		echo "输入无效,请输入 '1' 或 '2' 选择!"
		exit
		;;
esac

echo "算法选择: 1-先来先服务FCFS 2-最短寻道时间优先SSTF 3-扫描SCAN 4-循环扫描SCAN"
read keypressKind
case "$keypressKind" in
	1 )
		echo "----------执行先来先服务FCFS算法----------"
		FCFS
		;;
	2 )
		echo "----------执行最短寻道时间优先SSTF算法----------"
		SSTF
		;;
	3 )
		echo "----------执行扫描SCAN算法----------"
		SCAN
		;;
	4 )
		echo "----------执行循环扫描SCAN算法----------"
		CYCLESCAN
		;;
	* )
		echo "输入无效,请输入 '1' 或 '2' 或 '3' 或 '4' 选择!"
		exit
		;;
esac