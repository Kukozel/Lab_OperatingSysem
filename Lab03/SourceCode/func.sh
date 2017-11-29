#! /bin/bash

#初始化
INIT(){
	#安全序列
	declare -a SafeOrder
	OranAvailable=("${Available[@]}")
	#需求资源
	declare -a Need
	#请求资源
	declare -a Request
}

#根据Max和Allocation计算Need
CALNEED(){
	local len=$[$m*$n-1]
	for i in `seq 0 $len`; do
		Need[$i]=$[${Max[$i]}-${Allocation[$i]}]
		if [[ ${Need[$i]} -lt 0 ]]; then
			echo "错误!Need资源不能为负值."
			echo "错误!MAX资源不应该小于Allocation资源."
		fi
	done
	#echo "Need are ${Need[@]}"
	#echo "Available are ${Available[@]}"
}

#银行家算法
CALRESULT(){
	#计算Need资源
	CALNEED
	#进程个数n减1
	local len1=$[$n-1]
	#资源种类m减1
	local len2=$[$m-1]
	#判断是否安全
	until [[ "${#SafeOrder[@]}" -eq n ]]; do
		for i in `seq 0 "${len1}"`; do
			#存在进程Need小于Available安全,释放资源,将该进程加入到安全队列
			for j in `seq 0 "${len2}"`; do
				#定位当前资源位置
				site=$[$i*$m+$j]
				if [[ "${Need[$site]}" -gt "${Available[$j]}" ]]; then
					#当前进程不合适切换到下一进程
					continue 2
				fi
			done
			#当前进程安全
			SafeOrder[${#SafeOrder[@]}]="$i"
			for k in `seq 0 ${len2}`; do
				#修改Need，Available
				site=$[$i*$m+$k]
				#标记999为已经判断过
				Need[$site]=999
				Available[$k]=$[${Available[$k]}+${Allocation[$site]}]
			done
			continue 2
		done
		echo "当前状态不安全"
		exit
	done
	echo "当前状态安全"
	echo -n "安全序列为:"

	for (( l = 0; l < "${#SafeOrder[@]}"; l++ )); do
		echo -n "  P${SafeOrder[$l]}"
	done
	echo
}

#调用request资源请求
CALREQUEST(){
	echo "是否添加输入下一时刻进程资源请求Request?"
	echo "1-添加资源请求  2-不添加资源请求"
	read ifRequest
	case "${ifRequest}" in
		1 )
			echo -n "请输入进程ID:(可供选择的进程ID有"
			for idNumber in `seq 0 $n`; do
				echo -n "${idNumber}"
			done
			echo ")"
			read ifProcessId
			echo "请输入资源请求向量:(长度为$m)"
			read -a requestVector
			Request=("${requestVector[@]}")

			#执行状态
			Available=("${OranAvailable[@]}")
			unset SafeOrder
			state=0
			len_m=$[$m-1]
			#如果Requesti[j]>Need[i,j],资源数已超过它所宣布的最大值
			for i in `seq 0 $len_m`; do
				site=$[${ifProcessId}*$m+$i]
				need=$[${Max[$site]}-${Allocation[$site]}]
				if [[ "${Request[$i]}" -gt "${need}" ]]; then
					echo "资源数已超过它所宣布的最大值!"
					state=1
					break
				fi
			done

			#Requesti[j]>Available[j],尚无足够资源，Pi须等待
			if [[ "$state" -eq 0 ]]; then
				for i in `seq 0 $len_m`; do
					if [[ "${Request[$i]}" -gt "${Available[$i]}" ]]; then
						echo "尚无足够资源，P${ifProcessId}须等待.(当前可用资源: ${Available[@]})"
						state=1
						break
					fi
				done
			fi
			

			if [[ "$state" -eq 0 ]]; then
				#更新状态
				for i in `seq 0 $len_m`; do
					site=$[${ifProcessId}*$m+$i]
					Available[$i]=$[${Available[$i]}-${Request[$i]}]
					Allocation[$site]=$[${Allocation[$site]}+${Request[$i]}]
					#Need[$site]=$[${Allocation[$site]}-${Request[$i]}]
				done
				#执行银行家算法
				CALRESULT
			fi

			;;
		2 )
			echo "无新请求,程序退出."
			exit
			;;
		* )
			echo "无效输入!"
			exit
			;;
	esac
}