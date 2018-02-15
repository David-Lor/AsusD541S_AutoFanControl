# AsusD541S_AutoFanControl

This is a Python script for fan auto-control on the Asus D541S laptop under Linux. Requires Python, the psutil Python library and running the script as root.

The objective is to save battery and reduce noise when the temperature is OK, since the fan is (most times) always ON, although temperature is low. Temperature used by the script is the average temperature of all the valid temperatures reported by psutil.

The fan will stop working when the STOP temperature is reached. It will start spinning again when the START temperature is reached.

Since it seems that fan speed on this laptop can't be managed under Linux (at least under my tries), the script will only turn on/off the fan. Fan speed is theorically managed by the laptop itself. In my case this won't fix the bug that causes the fan not working after sleeping and waking up the system.
