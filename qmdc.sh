#!/bin/env bash



function sys_start(){
printf "
#####################
##      1).注册    ##
##      2).登陆    ##
##      3).退出    ##
#####################
"
read -p "please input your choices(1|2|3):" var1
}

function menu(){
while :
do
printf "
#############################
##	1).查询
##	2).充值
##	3).消费
##      4).退出     
############################
"
read -p "please input you choice(1|2|3):" var2
case $var2 in
	1)
		clear
		mysql -uroot -p"Zxs142857.*" -e "use ppo;select balance from mylist where username='$Username';"
	;;
	2)
		read -p "please input your amout(50 de beishu): " var3
		chongzhi=`mysql -uroot -p"Zxs142857.*" -e "use ppo;select balance from mylist where username='$Username';"`
		ttl=`echo $chongzhi |awk '{print $2}'`
		printf "$ttl"		
		pull=$(($ttl+$var3))
		echo $pull
		mysql -uroot -p"Zxs142857.*" -e "use ppo;update mylist set balance=$pull where username='$Username';"
		if [ $? -eq 0 ];then
			clear
			printf "chong zhi cheng gong!\n"
		else
			clear
			printf "chong zhi shi bai!\n"
		fi
	;;
	3)
		read -p "please input your consumption: " var4
		xiaofei=`mysql -uroot -p"Zxs142857.*" -e "use ppo;select balance from mylist where username='$Username';"`
		printf "$xiaofei"
		ssl=`echo $xiaofei |awk '{print $2}'`
		push=$(($ssl-$var4))
		mysql -uroot -p"Zxs142857.*" -e "use ppo;update mylist set balance=$push where username='$Username';"
                if [ $? -eq 0 ];then
			clear
                        printf "xiao fei cheng gong!\n"
                else
			clear
                        printf "xiao fei shi bai!\n"
                
                fi

	;;
	4)
		break
	;;	
	*)
		printf "please input (1|2|3|4)!"
	;;
esac
done
}

function zhuce(){
	clear
	while :
	do
		read -p "please input your username:" USERNAME		
		check_user=`mysql -uroot -p"Zxs142857.*" -e "use ppo;select * from mylist where username='$USERNAME';"`
		echo $check_user |grep $USERNAME
		
		if [ $? -eq 0 ];then
			clear
			let x=$x+1
			printf "The username is already exists!"
			if [ $x -gt 2 ];then
				break
			fi
			
		else
			while :
			do
				printf "please input your password:" && read -s PASSWD
				printf "please input your password again:" && read -s  PASSWD_CHECK
				if [ $PASSWD -a $PASSWD_CHECK -a $PASSWD == $PASSWD_CHECK ];then
					mysql -uroot -p"Zxs142857.*" -e "use ppo;insert into mylist (username,password,balance) values ('$USERNAME','$PASSWD',100);" >/dev/null 2>&1
					clear
					printf "zhu ce cheng gong!"
					break 2
				else
					clear
					printf "Password is error!Please input again!\n"
			
				fi
			done	
		fi
	done
}
	

function denglu(){
	i=1
	while :
	do
		read -p "please input your name:" Username
		printf "please input your password:" && read -s Passwd
		check_denglu=`mysql -uroot -p"Zxs142857.*" -e "use ppo;select * from mylist where username='$Username' and password='$Passwd';"`
		echo $check_denglu |egrep $Username
		if [ $? -eq 0 ];then
			printf "deng lu cheng gong!\n"
			clear
			menu	
			break
		else
			let i=$i+1
			printf "user or passwd is error,please input again!\n"
			if [ $i -gt 3 ];then
				clear
				printf "your username and password is error than three!\n"
				exit
			fi
		fi
	done
}

function menu_choice(){
	while :
do
	sys_start
	case $var1 in
	    1)
		zhuce	
		;;
	    2)	
		denglu	
		;;
	    3)
		exit
		;;
	esac
done
}

menu_choice
