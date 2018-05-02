#!/bin/bash

#FAN SETTINGS
SENSORS=(
	/sys/class/hwmon/hwmon4/temp2_input # CPU core0
	/sys/class/hwmon/hwmon4/temp4_input # CPU core1
)
START_TRIGGER=55000 # Temp when to start fan
STOP_TRIGGER=40000 # Temp when to stop fan
CMD_START="sudo echo 2 | sudo tee /sys/class/hwmon/hwmon3/pwm1_enable"
CMD_STOP="sudo echo 2 | sudo tee /sys/class/hwmon/hwmon3/pwm1"

#GOVERNOR SETTINGS
GOVERNOR_AC=performance # CPU governor when charging
GOVERNOR_DC=powersave # CPU governor when not charging

#OTHER SETTINGS
FREQ=5 # Main loop frequency


#VARIABLES
fan_status=1 # internal flag for FAN status | 0=stopped, 1=running
acPrev=10 # internal flag for Charging status | 0=discharging, 1=charging


#FUNCTIONS

#FAN Functions
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

#Governor Functions
function getAC { # Returns AC status (1=charging, 0=discharging)
	echo $(cat /sys/class/power_supply/AC0/online)
}
function setGovernor { # Set CPU governor to $1
	echo "$1" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
	echo "CPU Governor set to $1" # debug
}
function setGovernorCharge { # Set governor for charging
	setGovernor $GOVERNOR_AC
}
function setGovernorDischarge { # Set governor for discharging
	setGovernor $GOVERNOR_DC
}

#Main Loop
function main {
	stopFan
	while true
	do
		#Get Temperature and Charging status
		temp=$(getTemp)
		acNow="$(getAC)"
		echo "Temperature: $temp - Charging: $acNow" # debug

		#Fan control
		if [[ $temp -ge $START_TRIGGER ]]
		then
			startFan
		elif [[ $temp -le $STOP_TRIGGER ]]
		then
			stopFan
		fi

		#Governor control
		if [[ ! $acNow -eq $acPrev ]] # AC state changed
		then
			if [[ $acNow -eq 1 ]]
			then # Charging
				setGovernorCharge
			elif [[ $acNow -eq 0 ]]
			then # Discharging
				setGovernorDischarge
			fi
			acPrev=$acNow
		fi

		#Sleep
		sleep $FREQ
	done
}


#EXECUTION
main

#END
startFan
echo "End of script" # debug
