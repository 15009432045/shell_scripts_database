#!/bin/env bash

free -m >>./memory
vmstat >>./cpu
df -Th >>./disk

buf_cach=`free -m |awk 'NR == 2 {print $6}'`
free=`free -m |awk 'NR == 2{print $4}'`
total=`free -m |awk 'NR == 2{print $2}'`

let "ss=($buf_cach+$free)*100"
let ratio_mem=$ss/$total

#let ratio_mem=(($buf_cach+$free)/$total*100)
printf "%d%%\n" $ratio_mem

if [ $ratio_mem -ge 50 ];then
	echo "The memory used than 50%!!" |mail -s "memory infomation." 529898989@qq.com
fi

dis_loo=`df -Th |awk '/^\/dev\/mapper/ {print $6}' |cut -d % -f 1`

printf "%d%%\n" $dis_loo

if [ $dis_loo -ge 50 ];then
	echo "The disk used than 50%!!" |mail -s "memory infomation." 529898989@qq.com
	
fi


cpu_info=`vmstat |awk 'NR ==3 {print $15}'`
printf "%d%%\n" $cpu_info

if [ $cpu_info -le 50 ];then
	echo "The cpu used than 50%!!" |mail -s "memory infomation." 529898989@qq.com
fi
