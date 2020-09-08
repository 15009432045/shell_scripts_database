#!/bin/bash
# Remove the index of one month old in elasticserch
CMD_ECHO='echo'
SCRIPT_NAME=`basename $0`
LOG_PRINT="eval $CMD_ECHO \"[$SCRIPT_NAME]\" @$(date +"%Y%m%d %T") [INFO] :"
time_ago=30
es_cluster_ip=127.0.0.1

function delete_index(){
   comp_date=`date -d "${time_ago} day ago" +"%Y-%m-%d"`
   date1="${1} 00:00:00"
   date2="${comp_date} 00:00:00"
   index_date=`date -d "${date1}" +%s`
   limit_date=`date -d "${date2}" +%s`
    
   if [ $index_date -le $limit_date ];then
        $LOG_PRINT  "$1 will perform the delete task earlier than  ${time_ago} days ago" >> /tmp/delete-elk-log-tmp.txt
        del_date=`echo $1 | awk -F  "-" '{print $1"."$2"."$3}'`
        curl -XDELETE http://${es_cluster_ip}:9200/*$del_date >> /tmp/delete-elk-log-tmp.txt
   fi         

}

# get the date in all index
curl -XGET http://${es_cluster_ip}:9200/_cat/indices|awk -F " " '{print $3}'  | egrep "[0-9]*\.[0-9]*\.[0-9]*" |awk -F  "-" '{print $NF}' | awk -F  "." '{print $((NF-2))"-"$((NF-1))"-"$NF}' | sort | uniq | while read LINE   

do
  delete_index  ${LINE}
done
