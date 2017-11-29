#! /bin/bash

INIT(){
	#剩余空间
	declare -a FreePartition
	#首次适应算法结果ID;-1为分配失败
	declare -a FirstPartition
	#循环首次适应算法ID;-1为分配失败
	declare -a CycleFirstPartition
	#最佳适应算法结果ID;-1为分配失败
	declare -a BestPartition
	#最坏适应算法结果ID;-1为分配失败
	declare -a WorstPartition
}

#剩余空间输出
LEFT(){
	echo "分配结束后空闲分区大小情况:"
	#循环空闲分区个数为n
	for i in `seq 0 "$[$n-1]"`; do
		echo "空闲分区P$[$i+1]剩余空间: ${FreePartition[$i]}K"
	done
}

#1-首次适应算法
FF(){
	INIT
	FreePartition=("${P[@]}")
	#是否分配失败,失败为1
	local success=1
	#循环进程个数m
	for i in `seq 0 "$[$m-1]"`; do
		success=1
		#循环空闲分区个数为n
		for j in `seq 0 "$[$n-1]"`; do
			#S[i]进程需要分区小于等于空闲分区大小FreePartition[i]
			if [[ "${S[$i]}" -le "${FreePartition[$j]}" ]]; then
				success=0
				FirstPartition[$i]=$j
				FreePartition[$j]=$[${FreePartition[$j]}-${S[$i]}]
				break
			fi
		done
		#分配失败
		if [[ "$success" -eq 1 ]]; then
			FirstPartition[$i]=-1
		fi
	done
	echo -e "------首次适应算法-----\n内存空闲分区的分配情况:"
	#循环进程个数m
	for i in `seq 0 "$[$m-1]"`; do
		if [[ ${FirstPartition[$i]} -ge 0 ]]; then
			echo -e "进程${PID[$i]}分配至空闲分区:  P$[${FirstPartition[$i]}+1]"
		else
			echo "进程${PID[$i]}分配至空闲分区失败"
		fi
	done
	LEFT
}



#2-循环首次适应算法
NF(){
	INIT
	FreePartition=("${P[@]}")
	#是否分配失败,失败为1
	local success=1
	#循环进程个数m
	#定义循环标记
	CycleIndex=0
	for i in `seq 0 "$[$m-1]"`; do
		success=1
		#循环空闲分区个数为n
		for j in `seq 0 "$[$n-1]"`; do
			#S[i]进程需要分区小于等于空闲分区大小FreePartition[i]
			if [[ "${S[$i]}" -le "${FreePartition[${CycleIndex}]}" ]]; then
				success=0
				CycleFirstPartition[$i]="${CycleIndex}"
				FreePartition[${CycleIndex}]=$[${FreePartition[${CycleIndex}]}-${S[$i]}]
				CycleIndex=$[(${CycleIndex}+1)%$n]
				break
			fi
			CycleIndex=$[(${CycleIndex}+1)%$n]
		done
		#分配失败
		if [[ "$success" -eq 1 ]]; then
			CycleFirstPartition[$i]=-1
		fi
	done
	echo -e "------循环首次适应算法-----\n内存空闲分区的分配情况:"
	#循环进程个数m
	for i in `seq 0 "$[$m-1]"`; do
		if [[ ${CycleFirstPartition[$i]} -ge 0 ]]; then
			echo -e "进程${PID[$i]}分配至空闲分区:  P$[${CycleFirstPartition[$i]}+1]"
		else
			echo "进程${PID[$i]}分配至空闲分区失败"
		fi
	done
	LEFT
}


#3-最佳适应算法
BF(){
	INIT
	FreePartition=("${P[@]}")
	#是否分配失败,失败为1
	local success=1
	#循环进程个数m
	for i in `seq 0 "$[$m-1]"`; do
		success=1
		#定义最佳标记
		BestIndex=999
		BestSize=999
		#循环空闲分区个数为n
		for j in `seq 0 "$[$n-1]"`; do
			#S[i]进程需要分区小于等于空闲分区大小FreePartition[i]
			if [[ "${S[$i]}" -le "${FreePartition[$j]}" ]]; then
				if [[ "${BestSize}" -gt ${FreePartition[$j]} ]]; then
					BestIndex="$j"
					BestSize="${FreePartition[$j]}"
				fi
			fi

		done
		if [[ "${BestIndex}" -ne 999 ]]; then
			success=0
			BestPartition[$i]="${BestIndex}"
			FreePartition[${BestIndex}]=$[${FreePartition[${BestIndex}]}-${S[$i]}]
		fi
		#分配失败
		if [[ "$success" -eq 1 ]]; then
			BestPartition[$i]=-1
		fi
	done
	echo -e "------最佳适应算法-----\n内存空闲分区的分配情况:"
	#循环进程个数m
	for i in `seq 0 "$[$m-1]"`; do
		if [[ ${BestPartition[$i]} -ge 0 ]]; then
			echo -e "进程${PID[$i]}分配至空闲分区:  P$[${BestPartition[$i]}+1]"
		else
			echo "进程${PID[$i]}分配至空闲分区失败"
		fi
	done
	LEFT
}

#4-最坏适应算法
WF(){
	INIT
	FreePartition=("${P[@]}")
	#是否分配失败,失败为1
	local success=1
	#循环进程个数m
	for i in `seq 0 "$[$m-1]"`; do
		success=1
		#定义最坏标记
		WorstIndex=-1
		WorstSize=-1
		#循环空闲分区个数为n
		for j in `seq 0 "$[$n-1]"`; do
			#S[i]进程需要分区小于等于空闲分区大小FreePartition[i]
			if [[ "${S[$i]}" -le "${FreePartition[$j]}" ]]; then
				if [[ "${WorstSize}" -lt ${FreePartition[$j]} ]]; then
					WorstIndex="$j"
					WorstSize="${FreePartition[$j]}"
				fi
			fi

		done
		if [[ "${WorstIndex}" -ne -1 ]]; then
			success=0
			WorstPartition[$i]="${WorstIndex}"
			FreePartition[${WorstIndex}]=$[${FreePartition[${WorstIndex}]}-${S[$i]}]
		fi
		#分配失败
		if [[ "$success" -eq 1 ]]; then
			WorstPartition[$i]=-1
		fi
	done
	echo -e "------最坏适应算法-----\n内存空闲分区的分配情况:"
	#循环进程个数m
	for i in `seq 0 "$[$m-1]"`; do
		if [[ ${WorstPartition[$i]} -ge 0 ]]; then
			echo -e "进程${PID[$i]}分配至空闲分区:  P$[${WorstPartition[$i]}+1]"
		else
			echo "进程${PID[$i]}分配至空闲分区失败"
		fi
	done
	LEFT
}