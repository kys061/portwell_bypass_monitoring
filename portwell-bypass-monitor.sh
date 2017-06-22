#!/bin/bash
#
# Install portwell bypass driver and enable bypass
#
# Must be run as root.
#
bump1_operstatus="down"
bump2_operstatus="down"
stm_operstatus="down"
em1_adminstatus="down"
p1p1_adminstatus="down"
eth0_adminstatus="down"
eth1_adminstatus="down"
eth2_adminstatus="down"
eth3_adminstatus="down"
eth4_adminstatus="down"
eth5_adminstatus="down"
dumping_core="false"
sleep 10

if [ ! -e /et/stm/system_virt_real_device.csv  ]; then
	echo 'virt,real' > /etc/stm/system_virt_real_device.csv
	echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py admin:admin@localhost |grep Ethernet |awk '{print $1 "," $11}' >> /etc/stm/system_virt_real_device.csv
	if [ $? -eq 1 ]; then
		echo 'virt,real' > /etc/stm/system_virt_real_device.csv
		echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py admin:admin@localhost |grep Ethernet |awk '{print $1 "," $11}' >> /etc/stm/system_virt_real_device.csv
	fi
fi

while true
do
    realint_count=$(snmpwalk -v 2c -c public localhost ifIndex |egrep 'INTEGER: [0-9]$' |wc -l)
    for ((i=0; i<$realint_count; i++));
    do
        if [ $i == 0  ]; then
                virt_port_1_index=$(snmpwalk -v 2c -c public localhost ifIndex |egrep 'INTEGER: [0-9]$' |awk 'FNR == 1 {print}' |cut -d " " -f1 |rev |cut -d "." -f1)
                virt_port_1=$(snmpwalk -v 2c -c public localhost ifName |grep -m 1 $virt_port_1_index | rev | cut -d " " -f1 | rev | fgrep -m 1 -v "." | tail -n 1)
                real_port_1=$(cat /etc/stm/system_virt_real_device.csv |grep $virt_port_1 | cut -d "," -f2)
        elif [ $i == 1 ]; then
                virt_port_2_index=$(snmpwalk -v 2c -c public localhost ifIndex |egrep 'INTEGER: [0-9]$' |awk 'FNR == 2 {print}' |cut -d " " -f1 |rev |cut -d "." -f1)
                virt_port_2=$(snmpwalk -v 2c -c public localhost ifName |grep -m 1 $virt_port_2_index | rev | cut -d " " -f1 | rev | fgrep -m 1 -v "." | tail -n 1)
                real_port_2=$(cat /etc/stm/system_virt_real_device.csv |grep $virt_port_2 | cut -d "," -f2)
        elif [ $i == 2 ]; then
                virt_port_3_index=$(snmpwalk -v 2c -c public localhost ifIndex |egrep 'INTEGER: [0-9]$' |awk 'FNR == 3 {print}' |cut -d " " -f1 |rev |cut -d "." -f1)
                virt_port_3=$(snmpwalk -v 2c -c public localhost ifName |grep -m 1 $virt_port_3_index | rev | cut -d " " -f1 | rev | fgrep -m 1 -v "." | tail -n 1)
                real_port_3=$(cat /etc/stm/system_virt_real_device.csv |grep $virt_port_3 | cut -d "," -f2)
        elif [ $i == 3 ]; then
                virt_port_4_index=$(snmpwalk -v 2c -c public localhost ifIndex |egrep 'INTEGER: [0-9]$' |awk 'FNR == 4 {print}' |cut -d " " -f1 |rev |cut -d "." -f1)
                virt_port_4=$(snmpwalk -v 2c -c public localhost ifName |grep -m 1 $virt_port_4_index | rev | cut -d " " -f1 | rev | fgrep -m 1 -v "." | tail -n 1)
                real_port_4=$(cat /etc/stm/system_virt_real_device.csv |grep $virt_port_4 | cut -d "," -f2)
        fi
    done

    if [ $stm_operstatus != "up" ]; then
	echo "stm_operstatus down" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
	bitw_port_1=$virt_port_1
	bitw_port_2=$virt_port_2
	port3=$virt_port_3
	port4=$virt_port_4
	if [ "$port3" != "$bitw_port_1" ] && [ "$port3" != "$bitw_port_2" ] && [ "$port4" != "$bitw_port_1" ] && [ "$port4" != "$bitw_port_2" ]; then
	    bitw2_port_1=$port3
	    bitw2_port_2=$port4
	fi

	if [ ! -z $bitw_port_1 ]; then
	    if [ "$bitw_port_1" != "tree)" ]; then
		bitw_port_1_index=$(snmpwalk -v 2c -c public localhost ifName | grep -m 1 $bitw_port_1 | cut -d " " -f1 | rev | cut -d "." -f1)
		bitw_port_1_adminstatus=$(snmpget -v 2c -c public localhost ifAdminStatus.$bitw_port_1_index | cut -d" " -f4 | tr -d '(' | tr -d '1' | tr -d ')')
		bitw_port_1_pci=$(cat /etc/stm/system_interfaces.csv | grep $real_port_1 | cut -d "," -f2 | sed 's/\://g' | sed 's/\.//g')
		#bitw_port_1_pci=$(cat /etc/stm/system_interfaces.csv | grep $bitw_port_1 | cut -d "," -f2 | sed 's/\://g' | sed 's/\.//g')
	    fi
	fi
	if [ ! -z $bitw_port_1_adminstatus ]; then
	    if [ ! -z $bitw_port_2 ]; then
		bitw_port_2_index=$(snmpwalk -v 2c -c public localhost ifName | grep -m 1 $bitw_port_2 | cut -d " " -f1 | rev | cut -d "." -f1)
		bitw_port_2_adminstatus=$(snmpget -v 2c -c public localhost ifAdminStatus.$bitw_port_2_index | cut -d " " -f4 | tr -d '(' | tr -d '1' | tr -d ')')
		bitw_port_2_pci=$(cat /etc/stm/system_interfaces.csv | grep $real_port_2 | cut -d"," -f2 | sed 's/\://g' | sed 's/\.//g')
		#bitw_port_2_pci=$(cat /etc/stm/system_interfaces.csv | grep $bitw_port_2 | cut -d"," -f2 | sed 's/\://g' | sed 's/\.//g')
	    fi
	fi
	if [ ! -z $bitw2_port_1 ]; then
	    if [ "$bitw_port_1" != "tree)" ]; then
		bitw2_port_1_index=$(snmpwalk -v 2c -c public localhost ifName | grep -m 1 $bitw2_port_1 | cut -d " " -f1 | rev | cut -d "." -f1)
		bitw2_port_1_adminstatus=$(snmpget -v 2c -c public localhost ifAdminStatus.$bitw2_port_1_index | cut -d" " -f4 | tr -d '(' | tr -d '1' | tr -d ')')
		bitw2_port_1_pci=$(cat /etc/stm/system_interfaces.csv | grep $real_port_3 | cut -d "," -f2 | sed 's/\://g' | sed 's/\.//g')
		#bitw2_port_1_pci=$(cat /etc/stm/system_interfaces.csv | grep $bitw2_port_1 | cut -d "," -f2 | sed 's/\://g' | sed 's/\.//g')
	    fi
	fi
	if [ ! -z $bitw2_port_1_adminstatus ]; then
	    if [ ! -z $bitw2_port_2 ]; then
		bitw2_port_2_index=$(snmpwalk -v 2c -c public localhost ifName | grep -m 1 $bitw2_port_2 | cut -d " " -f1 | rev | cut -d "." -f1)
		bitw2_port_2_adminstatus=$(snmpget -v 2c -c public localhost ifAdminStatus.$bitw_port_2_index | cut -d " " -f4 | tr -d '(' | tr -d '1' | tr -d ')')
		bitw2_port_2_pci=$(cat /etc/stm/system_interfaces.csv | grep $real_port_4 | cut -d"," -f2 | sed 's/\://g' | sed 's/\.//g')
		#bitw2_port_2_pci=$(cat /etc/stm/system_interfaces.csv | grep $bitw2_port_2 | cut -d"," -f2 | sed 's/\://g' | sed 's/\.//g')
	    fi
	fi
	if [ ! -z $bitw_port_2_adminstatus ]; then
	    if [ "$bitw_port_1_adminstatus"=="up" ]; then
		if [ "$bitw_port_2_adminstatus"="up" ]; then
		    if [ -d /sys/class/bypass/g3bp0 ]; then
			bump1_port0_pci=$(ls -l /sys/class/bypass/g3bp0/port0/ | grep pci: | rev | cut -d":" -f1 | rev | sed -r 's/^.{2}//')
			if [ "$bitw_port_1_pci" == "$bump1_port0_pci" ] || [ "$bitw_port_2_pci" == "$bump1_port0_pci" ]; then
			    bump1_operstatus="up"
			else 
			    if [ -d /sys/class/bypass/g3bp1 ]; then
				bump2_port0_pci=$(ls -l /sys/class/bypass/g3bp1/port0/ | grep pci: | rev | cut -d":" -f1 | rev | sed -r 's/^.{2}//')
				if [ "$bitw_port_1_pci" == "$bump2_port0_pci" ] || [ "$bitw_port_2_pci" == "$bump2_port0_pci" ]; then
				    bump2_operstatus="up"
				fi
			    fi
			fi
		    fi
		fi
	    fi	    
	fi
	if [ ! -z $bitw2_port_2_adminstatus ]; then
	    if [ "$bitw2_port_1_adminstatus"=="up" ]; then
		if [ "$bitw2_port_2_adminstatus"=="up" ]; then
		    if [ -d /sys/class/bypass/g3bp0 ]; then
			bump1_port0_pci=$(ls -l /sys/class/bypass/g3bp0/port0/ | grep pci: | rev | cut -d":" -f1 | rev | sed -r 's/^.{2}//')
			if [ "$bitw2_port_1_pci" == "$bump1_port0_pci" ] || [ "$bitw2_port_2_pci" == "$bump1_port0_pci" ]; then
			    bump1_operstatus="up"
			else 
			    if [ -d /sys/class/bypass/g3bp1 ]; then
				bump2_port0_pci=$(ls -l /sys/class/bypass/g3bp1/port0/ | grep pci: | rev | cut -d":" -f1 | rev | sed -r 's/^.{2}//')
				if [ "$bitw2_port_1_pci" == "$bump2_port0_pci" ] || [ "$bitw2_port_2_pci" == "$bump2_port0_pci" ]; then
				    bump2_operstatus="up"
				fi
			    fi
			fi
		    fi
		fi
	    fi	    
	fi

       	echo "Bump1 operstatus" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
	echo "================" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
	echo $bump1_operstatus  | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
	echo "Bump2 operstatus" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
	echo "================" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
	echo $bump2_operstatus  | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
	
	if [ "$bump1_operstatus" == "up" ]; then
	    echo "bump1_operstatus up" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
	    stm_operstatus="up"
	    echo "stm_operstatus up" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
	else
	    echo "bump1 operstatus not up" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
	    if [ "$bump2_operstatus" == "up" ]; then
		echo "bump2 operstatus up" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
		stm_operstatus="up"
		echo "stm_operstatus up" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
	    fi
	fi
    else
	if [ "$bump1_operstatus" == "up" ]; then
	    if [ -d /sys/class/bypass/g3bp0 ]; then
		cd /sys/class/bypass/g3bp0
		bypass_status=$(cat bypass)
#	        echo "Bypass Status"
#	        echo $bypass_status 
		if [ "$bypass_status" != "n" ]; then 
		    echo "Disabling bypass on bump1" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
		    echo 1 > func
		    echo n > bypass
		fi
	    fi
	fi
	if [ "$bump2_operstatus" == "up" ]; then
	    if [ -d /sys/class/bypass/g3bp1 ]; then
		cd /sys/class/bypass/g3bp1
		bypass_status=$(cat bypass)
#	        echo "Bypass Status"
#	        echo $bypass_status 
		if [ "$bypass_status" != "n" ]; then 
		    echo "Disabling bypass on bump2" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
		    echo 1 > func
		    echo n > bypass
		fi
	    fi
	fi
    fi
    sleep 2
    if [ -f /opt/stm/target/core ]; then
	echo "Enabling bypasses on bump1 and bump2 due to ongoing core dump operation" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
	/otp/stm/target/enable_bypass.sh
	exit 0
    fi
done

