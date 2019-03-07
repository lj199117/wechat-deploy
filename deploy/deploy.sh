#!/bin/bash

# COMMAND LINE VARIABLES
# tomcat name
# Ex: passport
tomcat_home=/home/myuser/$1
tomcat_bin=$tomcat_home/bin
tomcat_who_run=`ps -ef | grep ${tomcat_bin} |  grep -v "grep" | awk '{print $1}'`
tomcat_who_run_other=`ps -ef | grep ${tomcat_bin} | grep -v "grep\|${0}" | awk '{print $1}' | grep -v "${tomcat_who_run}\|root" | sort | uniq`
tomcat_run_num=`ps -ef | grep ${tomcat_bin} |  grep -v "grep" | wc -l`

ps -ef | grep ${tomcat_bin} |  grep -v "grep"
echo ""

sourFile=$tomcat_home/temp/*.war
distFile=$tomcat_home/deploy/ROOT.war
distUnpackFolder=$tomcat_home/deploy/ROOT/

tomcat_echo_stop () {
    echo "Tomcat Stopping ...          [OK]"
    echo ""
}
tomcat_echo_start () {
    echo ""
    echo "Tomcat Starting ...          [OK]"
}
tomcat_echo_error () {
    echo ""
    echo "Tomcat Stopped ERROR ! Please check privilege or something !"
    echo ""
    exit 1
}
tomcat_stop () {
	$tomcat_bin/shutdown.sh
	sleep 1
    pid=`ps -ef | grep ${tomcat_bin} |  grep -v "grep" | awk '{print $2}'`
    if [ -n "$pid" ]; then
        echo "$tomcat_bin pid: $pid"
        kill -9 $pid
        tomcat_echo_stop;
    fi
}
tomcat_start () {
    sh ${tomcat_bin}/startup.sh
echo "${tomcat_bin}/startup.sh"
    if [ $? -eq 0 ]; then
        tomcat_echo_start;
    else
        tomcat_echo_error;
    fi
}
tomcat_shutdown () {
    if [ ${tomcat_run_num} -eq 0 ]; then
        echo "Tomcat is not running!"
        echo ""
    elif [ ${tomcat_run_num} -eq 1 ]; then
        tomcat_stop;
    else
        if [ ${tomcat_who_run_other} == "" ]; then
            tomcat_stop;
 
        else
            echo "Please shutdown Tomcat with other users (${tomcat_who_run_other}) "
            echo "Tomcat is not stopped !"
            exit 1
        fi
    fi
}
tomcat_startup () {
    tomcat_run_check=`ps -ef | grep ${tomcat_bin} |  grep -v "grep" | wc -l`
    if [ ${tomcat_run_check} -eq 0 ]; then
        tomcat_start;
    else
        echo "Tomcat is not stopped ! Please stop Tomcat at first !"
        echo 1
    fi
}


tomcat_shutdown
sleep 3

echo "remove $distFile ..."
rm $distFile
echo "remove $distUnpackFolder ..."
rm -r $distUnpackFolder
echo ""
ls -l $tomcat_home/deploy
ls -l $sourFile

echo ""
echo "move $sourFile to $distFile"
mv $sourFile $distFile
echo ""

tomcat_start

