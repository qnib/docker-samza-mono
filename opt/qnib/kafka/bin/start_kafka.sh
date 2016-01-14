#!/bin/bash

sleep 5

if [ "X${ZK_DC}" != "X" ];then
    sed -i'' -E "s#service \"zookeeper(@\w+)?\"#service \"zookeeper@${ZK_DC}\"#" /etc/consul-templates/kafka.server.properties.ctmpl
fi
if [ "X${KAFKA_HOST}" == "X" ];then
    export KAFKA_HOST=$(curl -s -XGET "172.17.42.1:8500/v1/catalog/service/zookeeper?dc=dc1&tag=${ZOOKEEPER_ENV_MYID}"|jq ".[0].Node"|sed -e 's/"//g')
fi
if [ "${KAFKA_HOST}" == "null" ];then
    export KAFKA_HOST=$(hostname -f)
fi

consul-template -consul localhost:8500 -once -template "/etc/consul-templates/kafka.server.properties.ctmpl:/opt/kafka/config/server.properties"

JMXD="-Dcom.sun.management.jmxremote"
export KAFKA_JMX_OPTS="${JMXD}.authenticate=false ${JMXD}.ssl=false ${JMXD}.port=54299"

/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties
