
#!/bin/env bash

#echo "
#    # If you are installing a virtual machine for the first time, 
#    # please select option one. If not, please ignore the first item.
#    1.)Install a virtual machine template;
#    2.)Create custom configuration virtual machines in batches
#    3.)Create default configuration virtual machines in batches
#    4.)Delete virtual machine
#    5.)exit
#"
#read -p "Please enter your choice[1|2|3|4|5]：" option

images_dir=/var/lib/libvirt/images
xml_dir=/etc/libvirt/qemu

function get_mac(){
    mac_prefix='52:54:00:'
    mac_as_num=`openssl rand -hex 3`
    mac_postfix=`echo $mac_as_num | sed -r 's/..\B/&:/g'`
    mac=${mac_prefix}${mac_postfix}
}

function menu(){
    echo "
    ----------虚拟机基础管理------------
    1.安装kvm
    2.查看已安装的虚拟机及状态
    3.批量安装虚拟机
    4.删除虚拟机 
    5.打开虚拟机
    6.关闭虚拟机
    7.克隆虚拟机
    q.退出管理程序
    h.查看帮助
"
}


function virsh_list(){
    list=(`virsh list --all  |grep "centos*" |awk '{print $2}'`)    
    list_state=(`virsh list --all |grep "centos*" |awk '{print $3$4}'`)
    num=`echo ${#list[@]}`
    
    for i in `seq $num`
    do
        MAC_ADDR=''
        IP_ADDR=''
        a=$(($i-1))
        MAC_ADDR=`virsh domifaddr ${list[a]} 2>/dev/null |awk 'NR==3{print $2}'`
        IP_ADDR=`virsh domifaddr ${list[a]} 2>/dev/null |awk 'NR==3{print $4}'`
        echo "你的第 $i 台虚拟机名字是： ${list[a]} 状态为： ${list_state[a]}"
        echo "MAC_ADDR: ${MAC_ADDR} IP_ADDR: ${IP_ADDR}"
        printf "\n"
    done
}

while true
do
    menu
    read -p "请输入选项：" choice
    case $choice in
    1)
        rpm -qa |grep virt-manager &>/dev/null
        if [ $? -ne 0 ];then
            echo "Beginning install kvm..."
            yum -y install *virt* *qemu* *kvm*
            
            systemctl start virt-manger || systemctl start libvirtd 
            
            if [ $? -eq 0 ];then
                systemctl enable virt-manger || systemctl enable libvirtd 
                echo "kvm was installed and running!"
            fi
        else
            systemctl enable virt-manger || systemctl enable libvirtd
            if [ $? -eq 0 ];then
                printf "kvm is already installed and running!\n"
            else
                printf "Please check if the kvm application is properly installed or configured！！！"
            fi
        fi
        ;;
    2)
        virsh_list
        read -p "Please enter any key to continue：" key
        wait
        clear
        ;;
    3)
       read -p "please enter the numbers of your want: " choose
       #wget -O $xml_dir/centos7u3_base.xml   ftp://10.3.145.114/kvm/centos7u3_base.xml
       
       for i in `seq $choose`
       do
           get_mac
           printf "starting create virtual machine..."
           now_num=$mac_as_num
           cp $xml_dir/centos7u3_base.xml  $xml_dir/centos7u3_$now_num.xml
           cp $images_dir/centos7u3_base.qcow2  $images_dir/centos7u3_$now_num.qcow2
           vm_name=centos7u3_$now_num
           vm_uuid=`uuidgen`
           vm_disk=centos7u3_$now_num.qcow2
           vm_mac=$mac
            
           sed -i 's/VM_NAME/'${vm_name}'/'   $xml_dir/centos7u3_$now_num.xml
           sed -i 's/VM_UUID/'${vm_uuid}'/'   $xml_dir/centos7u3_$now_num.xml
           sed -i 's/VM_DISK/'${vm_disk}'/'   $xml_dir/centos7u3_$now_num.xml
           sed -i 's/VM_MAC/'${vm_mac}'/'   $xml_dir/centos7u3_$now_num.xml
          
           virsh define $xml_dir/centos7u3_${now_num}.xml
      done
      ;;
    4)  
       virsh_list
       read -p "please input you want delete vir_eng name: " vir_eng
       if echo "${list[@]}" | grep -w "$vir_eng" &>/dev/null;then
           rm -rf $xml_dir/${vir_eng}.xml && rm -rf  $images_dir/${vir_eng}.qcow2
           virsh undefine ${vir_eng}
           printf "successfully deleted！"
       else
           printf "ERROR!The virtual machine name you entered is incorrect.\n"
           exit 1
       fi
       ;;
    5)
       virsh_list
       read -p "please input you want open vir_mea: " vir_eng_open
       if echo "${list[@]}" | grep -w "$vir_eng_open" &>/dev/null;then
           virsh start ${vir_eng_open}
           wait
           virsh list --all |grep ${vir_eng_open} |grep "running" &>/dev/null
           if [ $? -eq 0 ];then
               printf "The virtual machine ${vir_mea_open} is successfully started!\n"
           else
               printf "${vir_mea_open} Virtual machine failed to start,please try again!"
               exit 1
           fi
       else
           printf "ERROR!The virtual machine name you entered is incorrect.\n"
       fi
       ;;
    6)
      virsh_list
      read -p "please input you want stop vir_mea: " vir_eng_stop
      if echo "${list[@]}" | grep -w "$vir_eng_stop" &>/dev/null;then
          virsh shutdown ${vir_eng_stop}
          wait
          if virsh list --all |grep ${vir_eng_stop} |grep "shut off";then
              printf "The virtual machine ${vir_eng_stop} is successfully started!\n"
          else
              printf "Stop failure,please try again!\n"
              exit 1
          fi
      else
         printf "ERROR!The virtual machine name you entered is incorrect.\n"
      fi
      ;;
    7) 
      virsh_list
      read -p "请选择你要克隆的虚拟机" clone_name
      vm_name=$clone_name-clone
      virt-clone -o ${clone_name} -n ${vm_name} --auto-clone
     # vm_uuid=$uuid_base$clone
     # vm_disk=$vm_name.qcow2
     # 
     # cp $xml_dir/${clone_name}.xml  $xml_dir/$vm_name.xml
     # sed -i 's/VM_NAME/'${vm_name}'/'   $xml_dir/$clone_name-clone.xml
     # sed -i 's/VM_UUID/'${vm_uuid}'/'   $xml_dir/$clone_name-clone.xml
     # sed -i 's/VM_DISK/'${vm_disk}'/'   $xml_dir/$clone_name-clone.xml
     # sed -i 's/VM_MAC/'${vm_mac}'/'     $xml_dir/$clone_name-clone.xml
     # cp $images_dir/${clone_name}.qcow2  $images_dir/$vm_name.qcow2
      virsh define $xml_dir/$vm_name.xml
      ;;
    q)
      exit
      ;;      
        
    h)      
      :
    ;;

    *) 
      echo "无效的选择，请重新输入"
    ;;

    esac
done





