#! /bin/bash

. func.sh

#保留小数位数
sc=2
#最小物理块数m
m=3
#页面个数n
n=20
#页面序列
PageOrder=(7 0 1 2 0 3 0 4 2 3 0 3 2 1 2 0 1 7 0 1)

echo "实验五  虚拟内存页面置换算法"
echo "----------默认数据-------------"
echo -e "最小物理块数:\t${m}"
echo -e "页面个数:\t${n}"
echo -e "页面序列:"
for i in `seq 1 $n`; do
	echo -en "P${PageOrder[$[$i-1]]}  "
	if [[ $[$i%5] -eq 0 ]]; then
		echo
	fi
done
echo "-------------------------------"

echo "实验数据选择 1-使用默认数据，2-输入新数据"

read keypressData
case "$keypressData" in
	1 )
		;;
	2 )
		echo "请输入最小物理块数m:"
		read new_m
		m="${new_m}""
		echo "请输入页面个数n:"
		read new_n
		n="${new_n}""
		echo "请输入页面序列:(长度$n)"
		read -a new_P
		PageOrder=("${new_P[@]}")
		;;
	* )
		echo "输入无效,请输入 '1' 或 '2' 选择!"
		exit
		;;
esac

echo "算法选择: 1-先进先出FIFO页面置换算法 2-最佳置换OPI页面置换算法 3-最近最久未使用LRU页面置换算法"
read keypressKind
case "$keypressKind" in
	1 )
		echo "----------执行先进先出FIFO页面置换算法----------"
		OPI_FIFO 2
		;;
	2 )
		echo "----------执行最佳置换OPI页面置换算法----------"
		OPI_FIFO 1
		;;
	3 )
		echo "----------执行最近最久未使用LRU页面置换算法----------"
		LRU
		;;
	* )
		echo "输入无效,请输入 '1' 或 '2' 或 '3' 选择!"
		exit
		;;
esac