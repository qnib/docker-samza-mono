#!/bin/bash

source /opt/qnib/consul/etc/bash_functions

## Should move to a bash_function file as well
function qnib_kafka_bootstrap_topics {
    for topic in $(echo ${1}|sed -e 's/,/ /g');do
        name=$(echo ${topic}|awk -F\: '{print $1}')
        if [ $(/opt/kafka/bin/kafka-topics.sh --zookeeper zookeeper.service.consul:2181 --describe --topic ${name}|wc -l) -ne 0 ];then
	    echo "It seems that '${name}' already exists..."
            /opt/kafka/bin/kafka-topics.sh --zookeeper zookeeper.service.consul:2181 --describe --topic ${name}
        elif [ $(echo ${topic} | awk 'BEGIN{FS=":"} {print NF}') -eq 1 ];then
            /opt/kafka/bin/kafka-topics.sh --zookeeper zookeeper.service.consul:2181 --replication-factor 3 --partitions 1 --create --topic ${name}
        elif [ $(echo ${topic} | awk 'BEGIN{FS=":"} {print NF}') -eq 2 ];then
            replicas=$(echo ${topic}|awk -F\: '{print $2}')
            /opt/kafka/bin/kafka-topics.sh --zookeeper zookeeper.service.consul:2181 --replication-factor ${replicas} --partitions 1 --create --topic ${name}
        elif [ $(echo ${topic} | awk 'BEGIN{FS=":"} {print NF}') -eq 3 ];then
            name=$(echo ${topic}|awk -F\: '{print $1}')
            replicas=$(echo ${topic}|awk -F\: '{print $2}')
            partitions=$(echo ${topic}|awk -F\: '{print $3}')
            /opt/kafka/bin/kafka-topics.sh --zookeeper zookeeper.service.consul:2181 --replication-factor ${replicas} --partitions 1 --create --topic ${name}
        fi 
    done
}

qnib_wait_for_srv kafka ${KAFKA_MIN_INSTANCES-1}

qnib_kafka_bootstrap_topics ${KAFKA_BOOTSTRAP_TOPICS}
exit 0
