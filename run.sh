#!/bin/sh
#------------------------------------------------
# Simple shell-script to run HornetQ standalone
#------------------------------------------------

export HORNETQ_HOME=..
mkdir -p ../logs

# By default, the server is started in the non-clustered standalone configuration

if [ a"$1" = a ]; then CONFIG_DIR=$HORNETQ_HOME/config/stand-alone/non-clustered; else CONFIG_DIR="$1"; fi
if [ a"$2" = a ]; then FILENAME=hornetq-beans.xml; else FILENAME="$2"; fi

if [ ! -d $CONFIG_DIR ]; then
    echo script needs to be run from the HORNETQ_HOME/bin directory >&2
    exit 1
fi

RESOLVED_CONFIG_DIR=`cd "$CONFIG_DIR"; pwd`
export CLASSPATH=$RESOLVED_CONFIG_DIR:$HORNETQ_HOME/schemas/

# Use the following line to run with different ports
#export CLUSTER_PROPS="-Djnp.port=1099 -Djnp.rmiPort=1098 -Djnp.host=localhost -Dhornetq.remoting.netty.host=localhost -Dhornetq.remoting.netty.port=5445"

export JVM_ARGS="$CLUSTER_PROPS -XX:+UseParallelGC -XX:+AggressiveOpts -XX:+UseFastAccessorMethods -Xms512M -Xmx1024M -Dhornetq.config.dir=$RESOLVED_CONFIG_DIR -Djava.util.logging.manager=org.jboss.logmanager.LogManager -Dlogging.configuration=file://$RESOLVED_CONFIG_DIR/logging.properties -Djava.library.path=./lib/linux-i686:./lib/linux-x86_64"

export JMX_PORT=6000
export JMX_ARGS="-Djava.rmi.server.hostname=0.0.0.0 \
                -Dcom.sun.management.jmxremote \
                -Dcom.sun.management.jmxremote.port=${JMX_PORT} \
                -Dcom.sun.management.jmxremote.rmi.port=${JMX_PORT} \
                -Dcom.sun.management.jmxremote.local.only=false \
                -Dcom.sun.management.jmxremote.authenticate=false \
                -Dcom.sun.management.jmxremote.ssl=false"

for i in `ls $HORNETQ_HOME/lib/*.jar`; do
	CLASSPATH=$i:$CLASSPATH
done

echo "***********************************************************************************"
echo "java $JVM_ARGS -classpath $CLASSPATH $JMX_ARGS org.hornetq.integration.bootstrap.HornetQBootstrapServer $FILENAME"
echo "***********************************************************************************"
java $JVM_ARGS -classpath $CLASSPATH $JMX_ARGS -Dcom.sun.management.jmxremote org.hornetq.integration.bootstrap.HornetQBootstrapServer $FILENAME