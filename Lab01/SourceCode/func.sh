#! /bin/bash

#初始化
INIT(){
#小数点保留位数
sc=2
}

#先来先服务
FCFS(){
INIT
#完成时间	FinishTime	
declare -a FinishTime
#进程数量	p_number
declare -i p_number
p_number="${#ArrivalTime[@]}"
#第一个进程
echo "进程调度:"
echo -e "时刻${ArrivalTime[0]}:\t进程${PID[0]}开始运行."
FinishTime[0]=$[${ArrivalTime[0]}+${ServiceTime[0]}]
echo -e "时刻${FinishTime[0]}:\t进程${PID[0]}结束."
#计数从1开始,从第二个进程开始
temp_number=$[$p_number - 1]
for i in `seq 1 $temp_number`
do
	#当前进程到达时，上一进程未结束
	if [ ${ArrivalTime[i]} -lt ${FinishTime[i-1]} ];then
		echo -e "时刻${FinishTime[i-1]}:\t进程${PID[i]}开始运行."
		FinishTime[i]=$[${ServiceTime[i]} + ${FinishTime[i-1]}]
		echo -e "时刻${FinishTime[i]}:\t进程${PID[i]}结束."
	else
		#当前进程到达时，上一进程已结束
		echo -e "时刻${ArrivalTime[i]}:\t进程${PID[i]}开始运行."
		FinishTime[i]=$[${ServiceTime[i]} + ${ArrivalTime[i]}]
		echo -e "时刻${FinishTime[i]}:\t进程${PID[i]}结束."
	fi	
done
#周转时间	WholeTime
declare -a WholeTime
#带权周转时间	WeightWholeTime
declare -a WeightWholeTime
#平均周转时间
AverageWT_FCFS=0
#平均带权周转时间
AverageWWT_FCFS=0
#计算周转时间及计算带权周转时间
echo 
for i in `seq 0 $temp_number`
do
	WholeTime[i]=$[${FinishTime[i]} - ${ArrivalTime[i]}]
	echo -n -e "进程${PID[i]}周转时间:${WholeTime[i]} \t"
	WeightWholeTime[i]=$(echo "scale=$sc;${WholeTime[i]}/${ServiceTime[i]}"|bc)
	echo "带权周转时间:${WeightWholeTime[i]} "
	AverageWT_FCFS=$(echo "scale=$sc;${AverageWT_FCFS}+${WholeTime[i]}"|bc)
	AverageWWT_FCFS=$(echo "scale=$sc;${AverageWWT_FCFS}+${WeightWholeTime[i]}"|bc)
done
AverageWT_FCFS=$(echo "scale=$sc;${AverageWT_FCFS}/${p_number}"|bc)
AverageWWT_FCFS=$(echo "scale=$sc;${AverageWWT_FCFS}/${p_number}"|bc)
echo 
echo "平均周转时间:	$AverageWT_FCFS"
echo "平均带权周转时间:	$AverageWWT_FCFS"
}

#短作业优先
#当前FinishTime
nowFinishTime=0
#返回当前服务时间最短且已到达的进程id
NEXT(){
local minTime=999
local resultId=0
local ts=$[$#-1]
shift
for i in `seq 1 $ts`
do
	#当前进程已结束
	if [ $1 -eq 999 ];then
		shift
		continue
	fi
	#当前进程还未到
	if [[ ${ArrivalTime[i]} -gt ${nowFinishTime} ]];then
		shift
		continue
	fi
	#当前进程服务时间最小
	if [[ ${ServiceTime[i]} -lt $minTime ]];then
		minTime=${ServiceTime[i]}
		resultId=$i
	fi
	shift
done
#如果所有进程都未到达,返回到达值最小的
if [[ "${resultId}" -eq 0 ]]; then
	for i in `seq 1 $[${#ServiceTime[@]}-1]`; do
		if [[ "${tempServiceTime[$i]}" -ne 999 ]]; then
			nowFinishTime="${ArrivalTime[$i]}"
			resultId=$i
			break
		fi
	done
fi
return "$resultId"
}

SJF(){
INIT
#完成时间	FinishTime	
declare -a FinishTime
#进程数量	p_number
declare -i p_number
p_number="${#ArrivalTime[@]}"
#第一个进程
echo "进程调度:"
echo -e "时刻${ArrivalTime[0]}:\t进程${PID[0]}开始运行."
FinishTime[0]=$[${ArrivalTime[0]}+${ServiceTime[0]}]
echo -e "时刻${FinishTime[0]}:\t进程${PID[0]}结束."
nowFinishTime=${FinishTime[0]}
#临时数组储存ServiceTime以供删除
tempServiceTime=("${ServiceTime[@]}")
#完成的进程ServiceTime标记为999
tempServiceTime[0]=999
#从第二个进程开始
left_number=$[$p_number - 2]
for i in `seq 0 $left_number`
do
	NEXT "${tempServiceTime[@]}"
	NEXT_ID="$?"
	echo -e "时刻${nowFinishTime}:\t进程${PID[$NEXT_ID]}开始运行."
	FinishTime[$NEXT_ID]=$[${nowFinishTime}+${ServiceTime[NEXT_ID]}]
	nowFinishTime=${FinishTime[$NEXT_ID]}
	echo -e "时刻$nowFinishTime:\t进程${PID[$NEXT_ID]}结束."
	tempServiceTime[$NEXT_ID]=999
done
#周转时间	WholeTime
declare -a WholeTime
#带权周转时间	WeightWholeTime
declare -a WeightWholeTime
#平均周转时间
AverageWT_SJF=0
#平均带权周转时间
AverageWWT_SJF=0
#计算周转时间及计算带权周转时间
echo 
temp_number=$[$p_number - 1]
for i in `seq 0 $temp_number`
do
	WholeTime[i]=$[${FinishTime[i]} - ${ArrivalTime[i]}]
	echo -n -e "进程${PID[i]}周转时间:${WholeTime[i]} \t"
	WeightWholeTime[i]=$(echo "scale=$sc;${WholeTime[i]}/${ServiceTime[i]}"|bc)
	echo "带权周转时间:${WeightWholeTime[i]} "
	AverageWT_SJF=$(echo "scale=$sc;${AverageWT_SJF}+${WholeTime[i]}"|bc)
	AverageWWT_SJF=$(echo "scale=$sc;${AverageWWT_SJF}+${WeightWholeTime[i]}"|bc)
done
AverageWT_SJF=$(echo "scale=$sc;${AverageWT_SJF}/${p_number}"|bc)
AverageWWT_SJF=$(echo "scale=$sc;${AverageWWT_SJF}/${p_number}"|bc)
echo 
echo "平均周转时间:	$AverageWT_SJF"
echo "平均带权周转时间:	$AverageWWT_SJF"
}