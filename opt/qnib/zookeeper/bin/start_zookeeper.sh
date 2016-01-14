#!/bin/sh


function stop_zk {
     zk_pid=$(ps -ef|grep -v grep |grep "java -Dzookeeper.log.dir"|awk '{print $2}')
     if [ "X${zk_pid}" != "X" ];then
         kill -9 ${zk_pid}
     fi
}

## inherited from
# https://raw.githubusercontent.com/mesoscloud/zookeeper/master/3.4.6/centos/7/entrypoint.sh

## In case the zookeeper instance should not be started 
# eg. in case kafka inherits from this image, but uses an external zookeeper

if [ "X${START_ZOOKEEPER}" == "Xfalse" ];then
    echo "Skip starting zookeeper since START_ZOOKEEPER==false"
    sleep 5
    exit 0
fi

trap "echo stopping zookeeper;stop_zk; exit" HUP INT TERM EXIT

echo ${MYID:-1} > /tmp/zookeeper/myid
if [ "${MYID-0}" -gt 0 ];then
   echo "Sleep according to MYID $(echo "${MYID}*2"|bc)"
   sleep $(echo "${MYID}*2"|bc)
fi

/opt/zookeeper/bin/zkServer.sh start-foreground
