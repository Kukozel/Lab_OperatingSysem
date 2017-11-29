#! /bin/bash

INIT(){
	#模拟物理块状态
	declare -a Simulate
	#计算持续时间
	declare -a PageCount
	#当前页号
	declare -i PageNum
	#缺页次数
	declare -i LackNum
	#缺页率
	declare LackPageRate
	#FIFO替换点的Index默认0
	FIFO_Change_Index=0
}

#OPI置换
OPI_CHANGE(){
	#判断是否发生缺页中断,默认发生中断
	local cut=1
	for i in `seq 0 $[$m-1]`; do
		if [[ "$1" -eq "${Simulate[$i]}" ]]; then
			cut=0
		fi
	done
	#发生中断
	if [[ "${cut}" -eq 1 ]]; then		
		LackNum=$[${LackNum}+1]
		#寻找被替换的页号
		local delPageIndex=-1
		local delPageLength=0
		#循环块数
		for i in `seq 0 $[$m-1]`; do
			local tempLength=0
			for j in `seq $2 $[$n-1]`; do
				if [[ "${PageOrder[j]}" -eq "${Simulate[i]}" ]]; then
					break
				fi
				tempLength=$[${tempLength}+1]
			done
			if [[ "${tempLength}" -gt "${delPageLength}" ]]; then
				delPageLength="${tempLength}"
				delPageIndex="$i"
			fi
		done
		#开始替换
		Simulate[${delPageIndex}]="$1"
	fi
}

#FIFO置换
FIFO_CHANGE(){
	#判断是否发生缺页中断,默认发生中断
	local cut=1
	for i in `seq 0 $[$m-1]`; do
		if [[ "$1" -eq "${Simulate[$i]}" ]]; then
			cut=0
		fi
	done

	#发生中断
	if [[ "${cut}" -eq 1 ]]; then		
		LackNum=$[${LackNum}+1]
		#开始替换
		Simulate[${FIFO_Change_Index}]="$1"
		FIFO_Change_Index=$[(${FIFO_Change_Index}+1)%${m}]
	fi
}

#OPI最佳置换算法
OPI_FIFO(){
	#初始化
	INIT
	#PageNum从第一页到最后一页
	PageNum=0
	#起始缺页次数为0
	LackNum=0
	#页数少于物理块数,存在情况,页面种类小于物理块数
	if [[ "$n" -le "$m" ]]; then
		for i in `seq 0 $[$n-1]`; do
			echo "到达页面:P${PageOrder[$i]}"
			if [[ "$i" -eq 0 ]]; then
				Simulate[0]="${PageOrder[0]}"
			else
				for j in `seq 0 $[${#Simulate[@]}-1]`; do
					if [[ "${PageOrder[$i]}" -eq "${Simulate[$j]}" ]]; then
						echo "当前物理块内页数状态：${Simulate[@]}"
						continue 2
					fi
				done
				Simulate[${#Simulate[@]}]="${PageOrder[$i]}"
			fi		
			echo "当前物理块内页数状态：${Simulate[@]}"
		done
		LackNum=$[$n-${#Simulate[@]}]
		LackPageRate=$(echo "scale=${sc};${LackNum}/${n}"|bc)
		echo "缺页次数为:${LackNum}"
		if [[ "${LackNum}" -eq "$n" ]]; then
			echo "缺页率为:1"
		else
			LackPageRate=$(echo "scale=${sc};${LackNum}/${n}"|bc)
			echo "缺页率为:0${LackPageRate}"
		fi
			exit
	fi
	#定义Simulate满标记,0为满
	FullSimulate=1
	#页数大于物理块数,存在情况,页面种类小于物理块数
	for i in `seq 0 $[$n-1]`; do
		echo "到达页面:P${PageOrder[$i]}"
		PageNum="$[${PageNum}+1]"
		if [[ "$i" -eq 0 ]]; then
			LackNum=$[${LackNum}+1]
			Simulate[0]="${PageOrder[0]}"
			if [[ "${#Simulate[@]}" -eq "$m" ]]; then
				FullSimulate=0
				echo "当前物理块内页数状态：${Simulate[@]}"
				break
			fi
		else
			for j in `seq 0 $[${#Simulate[@]}-1]`; do
				if [[ "${PageOrder[$i]}" -eq "${Simulate[j]}" ]]; then
					echo "当前物理块内页数状态：${Simulate[@]}"
					continue 2
				fi
			done
			LackNum=$[${LackNum}+1]
			Simulate[${#Simulate[@]}]="${PageOrder[$i]}"
			if [[ "${#Simulate[@]}" -eq "$m" ]]; then
				FullSimulate=0
				echo "当前物理块内页数状态：${Simulate[@]}"
				break
			fi
		fi		
		echo "当前物理块内页数状态：${Simulate[@]}"
	done
	#Simulate装满之后
	if [[ "${FullSimulate}" -eq 0 ]]; then
		local startPagenum=${PageNum}
		for (( i_page = ${startPagenum}; i_page < $n; i_page++ )); do
			PageNum="$[${PageNum}+1]"
			local -i tempPage="${PageOrder[$i_page]}"
			echo "到达页面:P${tempPage}"
			#置换页面,接收两个参数，1是tempPage,2是PageNum
			if [[ "$1" -eq 1 ]]; then
				OPI_CHANGE ${tempPage} ${PageNum}
				elif [[ "$1" -eq 2 ]]; then
					FIFO_CHANGE ${tempPage} ${PageNum}
			fi
			
			echo "当前物理块内页数状态：${Simulate[@]}"
		done
	fi
	echo "缺页次数为:${LackNum}"
	if [[ "${LackNum}" -eq "$n" ]]; then
		echo "缺页率为:1"
	else
		LackPageRate=$(echo "scale=${sc};${LackNum}/${n}"|bc)
		echo "缺页率为:0${LackPageRate}"
	fi
}

#LRU置换
LRU_CHANGE(){
	#判断是否发生缺页中断,默认发生中断
	local cut=1
	for i in `seq 0 $[$m-1]`; do
		if [[ "$1" -eq "${Simulate[$i]}" ]]; then
			cut=0
			#不发生中断时将该也放到栈低
			tempValue=${Simulate[$i]}
			unset Simulate[$i]
			Simulate=("${Simulate[@]}")
			Simulate[${#Simulate[@]}]="${tempValue}"
		fi
	done

	#发生中断
	if [[ "${cut}" -eq 1 ]]; then		
		LackNum=$[${LackNum}+1]
		#出栈第一个，新进入放最后
		unset Simulate[0]
		Simulate=("${Simulate[@]}")
		Simulate[${#Simulate[@]}]="$1"
	fi
}
#最近最久未使用LRU置换算法 采用堆栈实现
LRU(){
	#初始化
	INIT
	#PageNum从第一页到最后一页
	PageNum=0
	#起始缺页次数为0
	LackNum=0
	#页数少于物理块数,存在情况,页面种类小于物理块数
	if [[ "$n" -le "$m" ]]; then
		for i in `seq 0 $[$n-1]`; do
			echo "到达页面:P${PageOrder[$i]}"
			if [[ "$i" -eq 0 ]]; then
				Simulate[0]="${PageOrder[0]}"
			else
				for j in `seq 0 $[${#Simulate[@]}-1]`; do
					if [[ "${PageOrder[$i]}" -eq "${Simulate[$j]}" ]]; then
						echo "当前物理块内页数状态：${Simulate[@]}"
						continue 2
					fi
				done
				Simulate[${#Simulate[@]}]="${PageOrder[$i]}"
			fi		
			echo "当前物理块内页数状态：${Simulate[@]}"
		done
		LackNum=$[$n-${#Simulate[@]}]
		LackPageRate=$(echo "scale=${sc};${LackNum}/${n}"|bc)
		echo "缺页次数为:${LackNum}"
		if [[ "${LackNum}" -eq "$n" ]]; then
			echo "缺页率为:1"
		else
			LackPageRate=$(echo "scale=${sc};${LackNum}/${n}"|bc)
			echo "缺页率为:0${LackPageRate}"
		fi
			exit
	fi

	#定义Simulate满标记,0为满
	FullSimulate=1
	#页数大于物理块数,存在情况,页面种类小于物理块数
	for i in `seq 0 $[$n-1]`; do
		echo "到达页面:P${PageOrder[$i]}"
		PageNum="$[${PageNum}+1]"
		if [[ "$i" -eq 0 ]]; then
			LackNum=$[${LackNum}+1]
			Simulate[0]="${PageOrder[0]}"
			if [[ "${#Simulate[@]}" -eq "$m" ]]; then
				FullSimulate=0
				echo "当前物理块内页数状态：${Simulate[@]}"
				break
			fi
		else
			for j in `seq 0 $[${#Simulate[@]}-1]`; do
				if [[ "${PageOrder[$i]}" -eq "${Simulate[$j]}" ]]; then
					local tempValue=${Simulate[$j]}
					unset Simulate[$j]
					Simulate=("${Simulate[@]}")
					Simulate[${#Simulate[@]}]="${tempValue}"
					echo "当前物理块内页数状态：${Simulate[@]}"
					continue 2
				fi
			done
			LackNum=$[${LackNum}+1]
			Simulate[${#Simulate[@]}]="${PageOrder[$i]}"
			if [[ "${#Simulate[@]}" -eq "$m" ]]; then
				FullSimulate=0
				echo "当前物理块内页数状态：${Simulate[@]}"
				break
			fi
		fi		
		echo "当前物理块内页数状态：${Simulate[@]}"
	done

	#Simulate装满之后
	if [[ "${FullSimulate}" -eq 0 ]]; then
		local startPagenum=${PageNum}
		for (( i_page = ${startPagenum}; i_page < $n; i_page++ )); do
			PageNum="$[${PageNum}+1]"
			local -i tempPage="${PageOrder[$i_page]}"
			echo "到达页面:P${tempPage}"
			#置换页面,接收两个参数，1是tempPage,2是PageNum
			LRU_CHANGE ${tempPage} ${PageNum}
			echo "当前物理块内页数状态：${Simulate[@]}"
		done
	fi

	echo "缺页次数为:${LackNum}"
	if [[ "${LackNum}" -eq "$n" ]]; then
		echo "缺页率为:1"
	else
		LackPageRate=$(echo "scale=${sc};${LackNum}/${n}"|bc)
		echo "缺页率为:0${LackPageRate}"
	fi
}