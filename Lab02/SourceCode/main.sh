#！/bin/bash

. func.sh

#进程名对照数组
PID=('A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L')
#到达时间
ArrivalTime=(0 1 2 3 4)
#服务时间
ServiceTime=(4 3 5 2 4)
#时间片长度
q=1

echo "实验二  时间片轮转RR进程调度算法"
echo "----------默认数据-------------"
echo -e "进程名  \t${PID[@]:0:${#ArrivalTime[@]}}"
echo -e "到达时间\t${ArrivalTime[@]}"
echo -e "服务时间\t${ServiceTime[@]}"
echo -e "时间片长度\t$q"
echo "-------------------------------"

echo "实验数据选择 1-使用默认数据，2-输入新数据"
read keypress
case "$keypress" in 
	1)
		echo "---- 执行时间片长度为${q}的轮转RR进程调度算法 -----"
		RR 
		;;
	2)
		echo "请输入到达时间:"
		read -a arrive_array
		if [[ "${#arrive_array[@]}" -eq 0 ]]; then
			echo "到达时间的长度不能为0"
			exit
		fi
		echo "请输入服务时间:"
		read -a service_array
		if [[ "${#arrive_array[@]}" -nt "${#service_array[@]}" ]]; then
			echo "到达时间与服务时间长度不匹配"
			exit
		fi
		echo "请输入时间片长度:"
		read new_q
		if [[ "${new_q}" -eq 0 ]]; then
			echo "时间片的长度不能为0"
			exit
		fi
		ArrivalTime=("${arrive_array[@]}")
		ServiceTime=("${service_array[@]}")
		q="${new_q}"
		echo "------------新数据-------------"
		echo -e "进程名  \t${PID[@]:0:${#ArrivalTime[@]}}"
		echo -e "到达时间\t${ArrivalTime[@]}"
		echo -e "服务时间\t${ServiceTime[@]}"
		echo -e "时间片长度\t$q"
		echo "-------------------------------"
		echo
		echo "----- 执行时间片为${q}的轮转RR进程调度算法 -----"
		RR 
		;;
	*)
		echo "输入无效,请输入 '1' 或 '2' 选择!"
		;;
esac