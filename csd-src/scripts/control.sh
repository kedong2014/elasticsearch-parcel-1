#!/bin/sh
#
#    Licensed to the Apache Software Foundation (ASF) under one or more
#    contributor license agreements.  See the NOTICE file distributed with
#    this work for additional information regarding copyright ownership.
#    The ASF licenses this file to You under the Apache License, Version 2.0
#    (the "License"); you may not use this file except in compliance with
#    the License.  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#
# chkconfig: 2345 20 80
# description: Apache NiFi is a dataflow system based on the principles of Flow-Based Programming.
#

# Script structure inspired from Apache Karaf and other Apache projects with similar startup approaches

export ES_HOME=/opt/cloudera/parcels/ELASTICSEARCH

PROGNAME=`basename "$0"`

warn() {
    echo "${PROGNAME}: $*"
}

die() {
    warn "$*"
    exit 1
}

locateJava() {
	echo
    export JAVA_HOME=/usr/java/latest
    echo "Changing Java Home to: $JAVA_HOME"
	export JAVA="$JAVA_HOME/bin/java"
	echo "Changing Java to: $JAVA"
    echo
}

config() {
	echo
	echo "Creating jvm.properties"
	echo
	echo "" > jvm.options
	while IFS= read -r line; do echo ${line#*=} >> jvm.options; done < jvm.properties
	cp -uf jvm.options $ES_HOME/config/
	
	echo
	echo "discovery.zen.ping.unicast.hosts"
	hosts="["
	while IFS= read -r line; do hosts=$hosts`echo $line | awk -F':' '{print $1}'`", " ; done < nodes.properties
	hosts="discovery.zen.ping.unicast.hosts: "$hosts"localhost]"
	echo $hosts
	echo
	
	echo
	echo "Creating elasticsearch.yml"
	echo
	echo "" > elasticsearch.yml
	while IFS= read -r line; do echo ${line%=*}": "${line#*=} >> elasticsearch.yml ; done < elasticsearch.properties
	echo $hosts >> elasticsearch.yml
	cp -uf elasticsearch.yml $ES_HOME/config/
}

init() {
    mkdir -p /var/log/elasticsearch
	mkdir -p /var/lib/elasticsearch
	chown elasticsearch:elasticsearch /var/log/elasticsearch
	chown elasticsearch:elasticsearch /var/lib/elasticsearch
	chmod 755 /var/log/elasticsearch
	chmod 755 /var/lib/elasticsearch
	sysctl -w vm.max_map_count=262144
	# Locate the Java VM to execute
	locateJava
	config
	ulimit -n 65536
	
}

start() {
	echo "Running Elastic Search Node"
    runuser -l  elasticsearch -c "ulimit -n 65536 && cd $ES_HOME/bin/ && JAVA_HOME=$JAVA_HOME ./elasticsearch"
}

stop() {
    kill -15 `$JAVA_HOME/bin/jps | grep Elasticsearch | awk '{print $1}'`
}


init
case "$1" in
    start)
        start
        ;;
	stop)
		stop
		;;
    restart)
        start
		stop
		;;
    *)
        echo "Usage Elastic Search {start|stop|restart}"
        ;;
esac
