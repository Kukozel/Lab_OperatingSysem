#！/bin/bash

#初始化条件
INIT(){
#小数点保留位数
sc=2
#结束时间
declare -a FinishTime
#临时存储到达时间,当数组为空时所有进程进入队列
TempArrivalTime=("${ArrivalTime[@]}")
#临时存储服务时间,当服务时间为0时进程结束
TempServiceTime=("${ServiceTime[@]}")
}

#判断当前时间是否有新进程到达，到达加入到NowQueue中
ADD(){
#当存在进程未开始时
until [[ "${#TempArrivalTime[@]}" -eq 0 ]]; do
	#当前进程到达时间小于等于当前时间时加入到队列中
	if [[ "${TempArrivalTime[0]}" -le "${NowTime}" ]]; then	
		NowQueue[${#NowQueue[@]}]=$[${#ArrivalTime[@]}-${#TempArrivalTime[@]}]
		unset TempArrivalTime[0]
		TempArrivalTime=("${TempArrivalTime[@]}")
	else
		break
	fi
done
}

RR(){
INIT
#当前时刻,进程1到达时间为初次当前时刻
NowTime="${ArrivalTime[0]}"
#当前进程队列,进程1在队列中
declare -a NowQueue
#结束进程个数
Finished=0
#当所有进程结束时退出循环
until [[ "$Finished" -eq "${#ServiceTime[@]}" ]]; do
	#当存在未加入执行队列的进程时检测
	if [[ "${#TempArrivalTime[@]}" -gt 0 ]]; then
		ADD
	fi
	#开始执行进程
	echo -e "时间$NowTime:\t进程${PID[${NowQueue[0]}]}开始运行."
	#时间片长度大于等于当前进程剩余时间长度
	if [[ "$q" -ge  "${TempServiceTime[${NowQueue[0]}]}" ]]; then	
		NowTime=$[${NowTime}+${TempServiceTime[${NowQueue[0]}]}]
		FinishTime[${NowQueue[0]}]="$NowTime"
		echo -e "时间$NowTime:\t进程${PID[${NowQueue[0]}]}结束."
		unset NowQueue[0]
		NowQueue=("${NowQueue[@]}")
		Finished=$[${Finished}+1]
	#时间片长度小于当前进程剩余时间长度
	else
		LeftServiceId=${NowQueue[0]}
		unset NowQueue[0]
		NowQueue=("${NowQueue[@]}")
		NowTime=$[${NowTime}+$q]
		if [[ "${#TempArrivalTime[@]}" -gt 0 ]]; then
			ADD
		fi
		NowQueue[${#NowQueue[@]}]="$LeftServiceId"
		TempServiceTime[${LeftServiceId}]=$[${TempServiceTime[${LeftServiceId}]}-$q]
		echo -e "时间$NowTime:\t进程${PID[$LeftServiceId]}停止."
	fi
done
#周转时间	WholeTime
declare -a WholeTime
#带权周转时间	WeightWholeTime
declare -a WeightWholeTime
#平均周转时间
AverageWT=0
#平均带权周转时间
AverageWWT=0
#计算周转时间及计算带权周转时间
echo 
temp_number=$[${#ArrivalTime[@]} - 1]
for i in `seq 0 $temp_number`
do
	WholeTime[i]=$[${FinishTime[i]} - ${ArrivalTime[i]}]
	echo -n -e "进程${PID[i]}周转时间:${WholeTime[i]} \t"
	WeightWholeTime[i]=$(echo "scale=$sc;${WholeTime[i]}/${ServiceTime[i]}"|bc)
	echo "带权周转时间:${WeightWholeTime[i]} "
	AverageWT=$(echo "scale=$sc;${AverageWT}+${WholeTime[i]}"|bc)
	AverageWWT=$(echo "scale=$sc;${AverageWWT}+${WeightWholeTime[i]}"|bc)
done
AverageWT=$(echo "scale=$sc;${AverageWT}/${#ArrivalTime[@]}"|bc)
AverageWWT=$(echo "scale=$sc;${AverageWWT}/${#ArrivalTime[@]}"|bc)
echo 
echo "平均周转时间:	$AverageWT"
echo "平均带权周转时间:	$AverageWWT"
}