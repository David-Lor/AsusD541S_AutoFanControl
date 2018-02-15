#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
debug = False
if len(sys.argv) > 1:
	if sys.argv[1] == "-h" or sys.argv[1] == "--help":
		print("""Asus D541S Auto Fan Control script

		Options:
		-d, --debug\tactivate debug info (show temperature & fan status)
		-h, --help\tshow this text
		""")
		exit()
	if any(x for x in ("-d", "--debug") if x in sys.argv):
		debug = True

import psutil
import subprocess
import atexit
from time import sleep

CMD_START = "sudo echo 2 | sudo tee /sys/class/hwmon/hwmon3/pwm1_enable"
CMD_STOP = "sudo echo 2 | sudo tee /sys/class/hwmon/hwmon3/pwm1"
STOP_TRIGGER = 40.0
START_TRIGGER = 50.0
FREQ = 5

@atexit.register
def atexit_f():
	start()

def start():
	subprocess.call(CMD_START, shell=True)
	if debug:
		print("Fan started")

def stop():
	subprocess.call(CMD_STOP, shell=True)
	if debug:
		print("Fan stopped")

fanon = False
stop()
sleep(2)

while True:
	""">>> psutil.sensors_temperatures()
	{'soc_dts0': [shwtemp(label='', current=49.0, high=None, critical=None)], 'coretemp': [shwtemp(label='Core 0', current=57.0, high=90.0, critical=90.0), shwtemp(label='Core 2', current=53.0, high=90.0, critical=90.0)], 'soc_dts1': [shwtemp(label='', current=49.0, high=None, critical=None)], 'acpitz': [shwtemp(label='', current=63.0, high=95.0, critical=95.0), shwtemp(label='', current=63.0, high=94.0, critical=94.0)], 'asus': [shwtemp(label='', current=6280.0, high=None, critical=None)]}"""
	temperatures = psutil.sensors_temperatures()
	currents = 0.0 #Sum of all the useful values detected
	values = 0 #Number of useful temperature values detected and used
	
	for label in temperatures:
		if label == "asus": #This temperature is fake
			continue
		for shwtemp in temperatures[label]:
			currents += shwtemp.current
			values += 1
	finaltemp = currents / values
	
	if debug:
		print(finaltemp)
		
	if fanon and finaltemp <= STOP_TRIGGER: #STOP THE FAN
		stop()
		fanon = False
	elif not fanon and finaltemp >= START_TRIGGER: #START THE FAN
		start()
		fanon = True

	sleep(FREQ)
