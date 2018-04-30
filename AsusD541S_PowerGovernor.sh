#!/bin/bash

GOVERNOR_AC=performance # CPU governor when charging
GOVERNOR_DC=powersave # CPU governor when not charging
LOOP_FREQ=5 # Delay on AC status checking

function getAC { # Returns AC status (1=charging, 0=discharging)
	echo $(cat /sys/class/power_supply/AC0/online)
}

function setGovernor { # Set CPU governor to $1
	echo "$1" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
	echo "CPU Governor set to $1"
}

function setGovernorCharge { # Set governor for charging
	setGovernor $GOVERNOR_AC
}

function setGovernorDischarge { # Set governor for discharging
	setGovernor $GOVERNOR_DC
}

function main { # Main loop
	prev=100
	while true; do
		ac="$(getAC)"
		if [ ! $ac -eq $prev ]; # AC state changed
			then
				if [ $ac -eq 1 ];
					then # Charging
						setGovernorCharge
				elif [ $ac -eq 0 ];
					then # Discharging
						setGovernorDischarge
				fi
				prev=$ac
		fi
		sleep $LOOP_FREQ
	done
}

main # Run the loop
