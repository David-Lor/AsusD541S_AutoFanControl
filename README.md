# AsusD541S_AutoFanControl

This is a Python script for fan auto-control on the Asus D541S laptop under Linux. Requieres Python, the psutil Python library and running the script as root.

The fan will stop working when the STOP temperature is reached. It will start spinning again when the START temperature is reached.

Since it seems that fan speed on this laptop can't be managed yet under Linux, the script will only turn on/off the fan. Fan speed is managed by the laptop itself. Probably this won't work after sleeping and waking up.
