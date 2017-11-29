#! /bin/bash

. func.sh

#进程名对照数组
PID=('A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L')
#空闲分区个数为n
n=5
#空闲分区大小P1,…,Pn
P=(16 16 32 64 20)
#进程个数m
m=5
#进程需要的分区大小S1,…,Sm
S=(12 10 22 15 6)

echo "实验二  动态分区分配算法"
echo "----------默认数据-------------"
echo -en "进程名\t\t"
for i in `seq 0 $[$m-1]`; do
	echo -en "${PID[$i]}  "
done
echo
echo -e "进程分区大小\t${S[@]}"
echo -en "空闲分区名  \t"
for i in `seq 0 $[$n-1]`; do
	echo -en "P$[$i+1] "
done
echo
echo -e "空闲分区大小\t${P[@]}"
echo "-------------------------------"

echo "实验数据选择 1-使用默认数据，2-输入新数据"

read keypressData
case "$keypressData" in
	1 )
		;;
	2 )
		echo "请输入空闲分区个数:"
		read new_n
		n=new_n
		echo "请按顺序输入空闲分区大小:(长度$n)"
		read -a new_P
		P=("${new_P[@]}")
		echo "请输入进程个数个数:"
		read new_m
		m=new_m
		echo "请按顺序输入进程分区大小:(长度$m)"
		read -a new_S
		S=("${new_S[@]}")
		;;
	* )
		echo "输入无效,请输入 '1' 或 '2' 选择!"
		exit
		;;
esac

echo "算法选择: 1-首次适应算法 2-循环首次适应算法 3-最佳适应算法 4-最坏适应算法"
read keypressKind
case "$keypressKind" in
	1 )
		FF
		;;
	2 )
		NF
		;;
	3 )
		BF
		;;
	4 )
		WF
		;;
	* )
		echo "输入无效,请输入 '1' 或 '2' 或 '3'或 '4' 选择!"
		exit
		;;
esac