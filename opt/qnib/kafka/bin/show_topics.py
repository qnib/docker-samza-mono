#! /usr/bin/env python
# -*- coding: utf-8 -*-


import envoy
import re

def eval_line(line):
   #Topic:ring0	PartitionCount:1	ReplicationFactor:3	Configs:
   reg1 = "Topic:(?P<topic>\w+)\s+PartitionCount:(?P<part_cnt>[0-9]+)\s+ReplicationFactor:(?P<repl_factor>[0-9]+)"
   reg2 = "Topic:\s+(?P<topic>\w+)\s+Partition:\s+(?P<partitions>[0-9]+)\s+Leader:\s+(?P<leader>[0-9]+)\s+Replicas:\s+(?P<replicas>[0-9\,]+)\s+Isr:\s+(?P<isr>[0-9\,]+)"
   mat1 = re.match(reg1, line)
   mat2 = re.match(reg2, line)
   if mat1:
      dic = mat1.groupdict()
      return dic['topic'], dic
   elif mat2:
      dic = mat2.groupdict()
      return dic['topic'], dic
   else:
      return None, None


def main():
   cmd = "/opt/kafka/bin/kafka-topics.sh --zookeeper zookeeper.service.consul:2181 --list"
   proc = envoy.run(cmd)
   topics = []
   for line in proc.std_out.split("\n"):
      topics.append(line.strip())
   cmd = "/opt/kafka/bin/kafka-topics.sh --zookeeper zookeeper.service.consul:2181 --describe %s" % ",".join(topics)
   proc = envoy.run(cmd)
   topic_dic = {}
   for line in proc.std_out.split("\n"):
      topic, res = eval_line(line.strip())
      if topic is not None:
          if topic not in topic_dic.keys():
              topic_dic[topic] = {}
          topic_dic[topic].update(res)

   topics = sorted(topic_dic.keys())
   for topic in topics:
       res = topic_dic[topic]
       del res['topic']
       print "### %s" % topic
       print ",".join(["%s:%s" % kv for kv in res.items()])



if __name__ == "__main__":
    main()
