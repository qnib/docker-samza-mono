#!/bin/bash

source /etc/bashrc.hadoop

function stop_hdfs {
    supervisorctl stop yarn
    echo stopping hdfs
    su -c stop-hdfs.sh hadoop


}
trap "stop_hdfs; exit" HUP INT TERM EXIT


if [ ! -d /data/hadoopdata/hdfs/namenode ];then
    echo "Formating namenode"
    chown -R hadoop: /data/hadoopdata/hdfs
    su -c 'hdfs namenode -format' hadoop
fi
if [ ! -d /opt/hadoop/logs ];then
    mkdir /data/hadoopdata/logs/
    chown -R hadoop: /data/hadoopdata/logs/
    ln -s /data/hadoopdata/logs /opt/hadoop/
else
    chown -R hadoop: /opt/hadoop/logs
fi

# Wait for sshd to be up'n'running
sleep 5
su -c 'start-dfs.sh' hadoop

while [ true ];do
    sleep 1
done
