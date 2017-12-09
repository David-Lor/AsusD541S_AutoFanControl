#!/usr/bin/python3
# -*- coding: utf-8 -*-

import psutil
import subprocess
import atexit
from time import sleep

CMD_START = "sudo echo 2 | sudo tee /sys/class/hwmon/hwmon4/pwm1_enable"
CMD_STOP = "sudo echo 2 | sudo tee /sys/class/hwmon/hwmon4/pwm1"
STOP_TRIGGER = 40.0
START_TRIGGER = 50.0
FREQ = 5
DEBUG = True

@atexit.register
def atexit_f():
	start()

def start():
	subprocess.call(CMD_START, shell=True)
	if DEBUG:
		print("Fan started")

def stop():
	subprocess.call(CMD_STOP, shell=True)
	if DEBUG:
		print("Fan stopped")

fanon = False
stop()
sleep(2)

while True:
	""">>> psutil.sensors_temperatures()
	{'soc_dts0': [shwtemp(label='', current=49.0, high=None, critical=None)], 'coretemp': [shwtemp(label='Core 0', current=57.0, high=90.0, critical=90.0), shwtemp(label='Core 2', current=53.0, high=90.0, critical=90.0)], 'soc_dts1': [shwtemp(label='', current=49.0, high=None, critical=None)], 'acpitz': [shwtemp(label='', current=63.0, high=95.0, critical=95.0), shwtemp(label='', current=63.0, high=94.0, critical=94.0)], 'asus': [shwtemp(label='', current=6280.0, high=None, critical=None)]}"""
	temperatures = psutil.sensors_temperatures()
	currents = 0.0 #Sumatorio de todas las temperaturas útiles detectadas
	values = 0 #Número de temperaturas útiles detectadas y sumadas a currents
	
	for label in temperatures:
		if label == "asus":
			continue
		for shwtemp in temperatures[label]:
			currents += shwtemp.current
			values += 1
	finaltemp = currents / values
	
	if DEBUG:
		print(finaltemp)
		
	if fanon and finaltemp <= STOP_TRIGGER: #STOP THE FAN
		stop()
		fanon = False
	elif not fanon and finaltemp >= START_TRIGGER: #START THE FAN
		start()
		fanon = True

	sleep(FREQ)
