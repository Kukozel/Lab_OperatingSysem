#! /bin/bash

. func.sh

#进程个数n
n=5
#资源种类m
m=3
#可用资源
declare -a Available
Available=(3 3 2)
#最大需求资源
declare -a Max
Max=(7 5 3 3 2 2 9 0 2 2 2 2 4 3 3)
#分配资源
declare -a Allocation
Allocation=(0 1 0 2 0 0 3 0 2 2 1 1 0 0 2)


echo "实验三  预防进程死锁的银行家算法"
echo "----------默认数据-------------"
echo -e "进程名\t MAX\tAllocation"
for i in `seq 0 $[$n-1]`; do
	echo -n -e  "  P$i\t"
	for j in `seq 0 $[$m-1]`; do
		echo -n -e "${Max[$[$i*$m+$j]]} "
	done
	echo -n -e "\t  "
	for j in `seq 0 $[$m-1]`; do
		echo -n -e "${Allocation[$[$i*$m+$j]]} "
	done
	echo ""
done
echo "可用资源:  ${Available[@]}"
echo "-------------------------------"

echo "实验数据选择 1-使用默认数据，2-输入新数据"

read keypress
case "$keypress" in
	1 )
		echo "算法开始:"
		;;
	2 )
		echo "请输入进程个数n:"
		read new_n
		n=$new_n
		echo "请输入资源种类m:"
		read new_m
		m=$new_m
		unset Max
		unset Allocation
		declare -a Max
		declare -a llocation
		echo "请输入最大需求资源(MAX)和分配资源(Allocation):"
		for i in `seq 0 $[$n-1]`; do
			echo "请输入P$[$i+1]进程的最大需求资源(MAX) (长度$m)"
			read -a arr1
			for j in `seq 0 $[$m-1]`; do
				site=$[$i*$m+$j]
				Max[${site}]=${arr1[$j]}
			done
				
			echo "请输入P$[$i+1]进程的分配资源(Allocation) (长度$m)"
			read -a arr2
			for j in `seq 0 $[$m-1]`; do
				site=$[$i*$m+$j]
				Allocation[${site}]="${arr2[$j]}"
			done
		done
		echo "请输入可用资源(Available):"
		read -a new_Available
		Available=("${new_Available[@]}")

		echo "Max : ${Max[@]}   len: ${#Max[@]}"
		echo "Allocation : ${Allocation[@]}   len: ${#Allocation[@]}"
		echo "Available : ${Available[@]}"

		echo "算法开始:"
		;;
	* )
		echo "输入无效,请输入 '1' 或 '2' 选择!"
		exit
		;;
esac



#初始化
INIT
CALRESULT
while [[ 0 ]]; do
	CALREQUEST
	echo "--------------下一时刻---------------"
done
