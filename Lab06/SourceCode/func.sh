#! /bin/bash

ININT(){
	declare -a MoveDistance
	declare AverageDistance
	declare abs_result
}

#计算两个值的绝对值
abs(){
	#第一个数大于等于第二个数
	if [[ "$1" -ge "$2" ]]; then
		abs_result=$[$1-$2]
		return 0
	#第一个数小于第二个数
	else
		abs_result=$[$2-$1]
		return 1
	fi
}

#先来先服务FCFS
FCFS(){
	local start="$m"
	local totalLength=0
	echo -e "开始磁道号:  ${start}"
	for i in `seq 0 $[$n-1]`; do
		echo -ne "被访问的下一个磁道号:\t${TrackOrder[$i]}"
		abs ${start} ${TrackOrder[$i]}
		MoveDistance[$i]=${abs_result}
		totalLength=$[${totalLength}+${abs_result}]
		start=${TrackOrder[$i]}
		echo -e "\t移动距离:   ${MoveDistance[$i]}"
	done
	AverageDistance=$(echo "scale=${sc};${totalLength}/${n}"|bc)
	echo -e "平均寻道长度:\t${AverageDistance}"
}

#最短寻道时间优先SSTF
SSTF(){
	local start="$m"
	local totalLength=0
	local tempTrackOrder=("${TrackOrder[@]}")
	#最近的磁道号
	local shortestIndex=-1
	echo -e "开始磁道号:  ${start}"
	for i in `seq 0 $[$n-1]`; do
		#定义最近距离
		shortestLength=999
		#寻找最近的磁道
		for j in `seq 0 $[$n-1]`; do
			if [[ "${tempTrackOrder[$j]}" -eq -999 ]]; then
				continue
			fi
			abs ${start} ${tempTrackOrder[$j]}
			if [[ "${shortestLength}" -gt  "${abs_result}" ]]; then
				shortestLength="${abs_result}"
				shortestIndex="$j"
			fi
		done

		echo -ne "被访问的下一个磁道号:\t${tempTrackOrder[${shortestIndex}]}"
		abs ${start} ${tempTrackOrder[${shortestIndex}]}
		MoveDistance[$i]=${abs_result}
		totalLength=$[${totalLength}+${abs_result}]
		start=${tempTrackOrder[${shortestIndex}]}
		tempTrackOrder[${shortestIndex}]=-999
		echo -e "\t移动距离:   ${MoveDistance[$i]}"
	done
	AverageDistance=$(echo "scale=${sc};${totalLength}/${n}"|bc)
	echo -e "平均寻道长度:\t${AverageDistance}"	
}

#排序从小到大
SORT(){
	tempTrackOrder=("${TrackOrder[@]}")
	for i in `seq 0 $[$n-1]`; do
		MIN=999
		MIN_Index=0
		for j in `seq 0 $[$n-1]`; do
			if [[ "${MIN}" -gt "${tempTrackOrder[$j]}" ]]; then
				MIN=${tempTrackOrder[$j]}
				MIN_Index=$j
			fi
		done
		tempTrackOrder[${MIN_Index}]=999
		TrackOrder[$i]="${MIN}"
	done
}

#扫描SCAN
SCAN(){
	SORT
	local start="$m"
	local totalLength=0
	echo -e "开始磁道号:  ${start}"
	#当开始磁道号m最小
	if [[ "${start}" -lt "${TrackOrder[0]}" ]]; then
		for i in `seq 0 $[$n-1]`; do
			echo -ne "被访问的下一个磁道号:\t${TrackOrder[$i]}"
			abs ${start} ${TrackOrder[$i]}
			MoveDistance[$i]=${abs_result}
			totalLength=$[${totalLength}+${abs_result}]
			start="${TrackOrder[$i]}"
			echo -e "\t移动距离:   ${MoveDistance[$i]}"
		done
		AverageDistance=$(echo "scale=${sc};${totalLength}/${n}"|bc)
		echo -e "平均寻道长度:\t${AverageDistance}"	
		return
	fi
	#当开始磁道号m最大
	if [[ "${start}" -gt "${TrackOrder[$[$n-1]]}" ]]; then
		for (( i = $[$n-1]; i >= 0; i-- )); do
			echo -ne "被访问的下一个磁道号:\t${TrackOrder[$i]}"
			abs ${start} ${TrackOrder[$i]}
			MoveDistance[$i]=${abs_result}
			totalLength=$[${totalLength}+${abs_result}]
			start="${TrackOrder[$i]}"
			echo -e "\t移动距离:   ${MoveDistance[$i]}"
		done
		AverageDistance=$(echo "scale=${sc};${totalLength}/${n}"|bc)
		echo -e "平均寻道长度:\t${AverageDistance}"
		return
	fi
	#当开始磁道号在中间,寻找稍大的位置Index
	midIndex=-1
	for i in `seq 0 $[$n-1]`; do
		if [[ "$m" -lt "${TrackOrder[$i]}" ]]; then
			midIndex="$i"
			break
		fi
	done
	#根据direction判断方向
	#1时向外
	if [[ "${direction}" -eq 1 ]]; then
		for (( i = ${midIndex}; i < ${n}; i++ )); do
			echo -ne "被访问的下一个磁道号:\t${TrackOrder[$i]}"
			abs ${start} ${TrackOrder[$i]}
			MoveDistance[$i]=${abs_result}
			totalLength=$[${totalLength}+${abs_result}]
			start="${TrackOrder[$i]}"
			echo -e "\t移动距离:   ${MoveDistance[$i]}"
		done
		for (( i = $[${midIndex}-1]; i >= 0; i-- )); do
			echo -ne "被访问的下一个磁道号:\t${TrackOrder[$i]}"
			abs ${start} ${TrackOrder[$i]}
			MoveDistance[$i]=${abs_result}
			totalLength=$[${totalLength}+${abs_result}]
			start="${TrackOrder[$i]}"
			echo -e "\t移动距离:   ${MoveDistance[$i]}"
		done
		AverageDistance=$(echo "scale=${sc};${totalLength}/${n}"|bc)
		echo -e "平均寻道长度:\t${AverageDistance}"
	#0时向内
	elif [[ "${direction}" -eq 0 ]]; then
		for (( i = $[${midIndex}-1]; i >= 0; i-- )); do
			echo -ne "被访问的下一个磁道号:\t${TrackOrder[$i]}"
			abs ${start} ${TrackOrder[$i]}
			MoveDistance[$i]=${abs_result}
			totalLength=$[${totalLength}+${abs_result}]
			start="${TrackOrder[$i]}"
			echo -e "\t移动距离:   ${MoveDistance[$i]}"
		done		
		for (( i = ${midIndex}; i < ${n}; i++ )); do
			echo -ne "被访问的下一个磁道号:\t${TrackOrder[$i]}"
			abs ${start} ${TrackOrder[$i]}
			MoveDistance[$i]=${abs_result}
			totalLength=$[${totalLength}+${abs_result}]
			start="${TrackOrder[$i]}"
			echo -e "\t移动距离:   ${MoveDistance[$i]}"
		done
		AverageDistance=$(echo "scale=${sc};${totalLength}/${n}"|bc)
		echo -e "平均寻道长度:\t${AverageDistance}" 
	else
		echo "方向错误! '1'时向外 '0'向内."
	fi
}

#循环扫描SCAN
CYCLESCAN(){
	SORT
	local start="$m"
	local totalLength=0
	echo -e "开始磁道号:  ${start}"
	
	#开始磁道号在两侧时结果一致,默认0,不在两端
	Judge=0
	#当开始磁道号m最小
	if [[ "${start}" -lt "${TrackOrder[0]}" ]]; then
		Judge=1
	fi
	#当开始磁道号m最大
	if [[ "${start}" -gt "${TrackOrder[$[$n-1]]}" ]]; then
		Judge=1
	fi

	if [[ "${Judge}" -eq 1 ]]; then
		#1时向外
		if [[ "${direction}" -eq 1 ]]; then
			for i in `seq 0 $[$n-1]`; do
				echo -ne "被访问的下一个磁道号:\t${TrackOrder[$i]}"
				abs ${start} ${TrackOrder[$i]}
				MoveDistance[$i]=${abs_result}
				totalLength=$[${totalLength}+${abs_result}]
				start="${TrackOrder[$i]}"
				echo -e "\t移动距离:   ${MoveDistance[$i]}"
			done
			AverageDistance=$(echo "scale=${sc};${totalLength}/${n}"|bc)
			echo -e "平均寻道长度:\t${AverageDistance}"	
			return
		#0时向内
		elif [[ "${direction}" -eq 0 ]]; then
			for (( i = $[$n-1]; i >= 0; i-- )); do
				echo -ne "被访问的下一个磁道号:\t${TrackOrder[$i]}"
				abs ${start} ${TrackOrder[$i]}
				MoveDistance[$i]=${abs_result}
				totalLength=$[${totalLength}+${abs_result}]
				start="${TrackOrder[$i]}"
				echo -e "\t移动距离:   ${MoveDistance[$i]}"
			done
			AverageDistance=$(echo "scale=${sc};${totalLength}/${n}"|bc)
			echo -e "平均寻道长度:\t${AverageDistance}"
			return
		else
			echo "方向错误! '1'时向外 '0'向内."
		fi
	fi
	#当开始磁道号在中间,寻找稍大的位置Index
	midIndex=-1
	for i in `seq 0 $[$n-1]`; do
		if [[ "$m" -lt "${TrackOrder[$i]}" ]]; then
			midIndex="$i"
			break
		fi
	done
	#根据direction判断方向
	#1时向外
	if [[ "${direction}" -eq 1 ]]; then
		for (( i = ${midIndex}; i < ${n}; i++ )); do
			echo -ne "被访问的下一个磁道号:\t${TrackOrder[$i]}"
			abs ${start} ${TrackOrder[$i]}
			MoveDistance[$i]=${abs_result}
			totalLength=$[${totalLength}+${abs_result}]
			start="${TrackOrder[$i]}"
			echo -e "\t移动距离:   ${MoveDistance[$i]}"
		done
		for (( i = 0; i < ${midIndex}; i++ )); do
			echo -ne "被访问的下一个磁道号:\t${TrackOrder[$i]}"
			abs ${start} ${TrackOrder[$i]}
			MoveDistance[$i]=${abs_result}
			totalLength=$[${totalLength}+${abs_result}]
			start="${TrackOrder[$i]}"
			echo -e "\t移动距离:   ${MoveDistance[$i]}"
		done
		AverageDistance=$(echo "scale=${sc};${totalLength}/${n}"|bc)
		echo -e "平均寻道长度:\t${AverageDistance}"
	#0时向内
	elif [[ "${direction}" -eq 0 ]]; then
		for (( i = $[${midIndex}-1]; i >= 0; i-- )); do
			echo -ne "被访问的下一个磁道号:\t${TrackOrder[$i]}"
			abs ${start} ${TrackOrder[$i]}
			MoveDistance[$i]=${abs_result}
			totalLength=$[${totalLength}+${abs_result}]
			start="${TrackOrder[$i]}"
			echo -e "\t移动距离:   ${MoveDistance[$i]}"
		done		
		for (( i = $[${n}-1]; i >= ${midIndex}; i-- )); do
			echo -ne "被访问的下一个磁道号:\t${TrackOrder[$i]}"
			abs ${start} ${TrackOrder[$i]}
			MoveDistance[$i]=${abs_result}
			totalLength=$[${totalLength}+${abs_result}]
			start="${TrackOrder[$i]}"
			echo -e "\t移动距离:   ${MoveDistance[$i]}"
		done
		AverageDistance=$(echo "scale=${sc};${totalLength}/${n}"|bc)
		echo -e "平均寻道长度:\t${AverageDistance}" 
	else
		echo "方向错误! '1'时向外 '0'向内."
	fi
}