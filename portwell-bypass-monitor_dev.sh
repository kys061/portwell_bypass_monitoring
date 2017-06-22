#!/bin/bash
#
# Install portwell bypass driver and enable bypass
#
# Must be run as root.
# $bitw_port_2를 $real_port_2로 변경
# bitw_port_2_pci=$(cat /etc/stm/system_interfaces.csv | grep $bitw_port_2 | cut -d"," -f2 | sed 's/\://g' | sed 's/\.//g')
if [ ! -e /et/stm/system_virt_real_device.csv ]; then
echo 'virt,real' > /etc/stm/system_virt_real_device.csv
echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py admin:admin@localhost |grep Ethernet |awk '{print $1 "," $11}' >> /etc/stm/system_virt_real_device.csv
fi

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

echo -e $virt_port_1_index $virt_port_1 $real_port_1
echo -e $virt_port_2_index $virt_port_2 $real_port_2
echo -e $virt_port_3_index $virt_port_3 $real_port_3
echo -e $virt_port_4_index $virt_port_4 $real_port_4

