#!/bin/bash

SENSORS=(
	/sys/class/hwmon/hwmon4/temp2_input # CPU core0
	/sys/class/hwmon/hwmon4/temp4_input # CPU core1
)
START_TRIGGER=55000 # Temp when to start fan
STOP_TRIGGER=40000 # Temp when to stop fan
FREQ=5 # Main loop frequency

CMD_START="sudo echo 2 | sudo tee /sys/class/hwmon/hwmon3/pwm1_enable"
CMD_STOP="sudo echo 2 | sudo tee /sys/class/hwmon/hwmon3/pwm1"
fan_status=1 # internal flag for FAN status | 0=stopped, 1=running

function stopFan { # stop fan
	if [[ $fan_status -eq 1 ]]
	then
		fan_status=0
		eval $CMD_STOP
		echo "Fan stopped" # debug
	fi
}

function startFan { # start fan
	if [[ $fan_status -eq 0 ]]
	then
		fan_status=1
		eval $CMD_START
		echo "Fan started" # debug
	fi
}

function getTemp { # get total temp (sum of all sensors / number of sensors)
	total=0
	for s in ${SENSORS[*]}
	do
		temp=$(cat $s)
		total=$(($total+$temp))
	done
	echo $(($total/${#SENSORS[*]}))
}

function main { # Main loop
	stopFan
	while true
	do
		temp=$(getTemp)
		echo "Temperature: $temp" # debug
		if [[ $temp -ge $START_TRIGGER ]]
		then
			startFan
		elif [[ $temp -le $STOP_TRIGGER ]]
		then
			stopFan
		fi
		sleep $FREQ
	done
}

main

startFan
echo "End of script" # debug
