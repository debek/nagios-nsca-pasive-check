#!/bin/sh

# nsca_pasive_send ver:1.0
# Usage: nsca_pasive_send.sh <service_check_name> <ncsa_remote_server_ip>
# Example of usage: ./nsca_pasive_send.sh snmpd.service 185.228.74.239
# by Daniel Debny

source /etc/profile
SVC=$1
SEND_IP=$2
DEVICE=$(hostname)
IP=$(ip route get 8.8.8.8 | awk '/src/ { print $7 }')
TMPFILE=/tmp/ddlog.$$
NOW=$(date +%s)

# check command
systemctl status ${SVC} >/dev/null 2>&1
CODE=$?

if [ $CODE == 0 ] ; then
        systemctl status ${SVC} | grep "Active: active" | sed -e 's/^[ \t]*//' >${TMPFILE} 2>&1
        RESULT=$(cat ${TMPFILE})
        echo -e "${IP}\tnsca/${SVC}\t0\t${RESULT}" > ${TMPFILE}
        /usr/sbin/send_nsca ${SEND_IP} -c /etc/nagios/send_nsca.cfg < ${TMPFILE}
        rm ${TMPFILE}
else
        systemctl status ${SVC} | grep "Active: inactive" | sed -e 's/^[ \t]*//' >${TMPFILE} 2>&1
        RESULT=$(cat ${TMPFILE})
        echo -e "${IP}\tnsca/${SVC}\t2\t${RESULT}" > ${TMPFILE}
        /usr/sbin/send_nsca ${SEND_IP} -c /etc/nagios/send_nsca.cfg < ${TMPFILE}
        rm ${TMPFILE}
fi
