#! /usr/bin/env python3.4
import subprocess
import time
import logging
import systemd.daemon
import utils

config = {
    "04h": lambda t: min(80, max(5, 0.025*t**2 - 0.75*t)),
    "01h": lambda t: min(80, max(5, 0.025*t**2 - 0.75*t - 5)),
    "0Eh": lambda t: min(80, max(5, 5 if t < 30 else 0.019753*t**2 - 1.1852*t + 17.778)),
    "0Fh": lambda t: min(80, max(5, 5 if t < 30 else 0.019753*t**2 - 1.1852*t + 17.778))
}

print(f"Config initialized for sensors {', '.join(config.keys())}")

def fan_update():
    result = subprocess.run(["ipmitool", "sdr", "type", "temperature"], capture_output=True, text=True).stdout

    fan_speed = round(
        max(
            config[
                measurement.split("|")[1].strip()
            ](
                int(measurement.split("|")[4][0:3].strip())
            ) for measurement in result.strip().split("\n")
        )
    )

    subprocess.run(["ipmitool", "raw", "0x30", "0x30", "0x02", "0xff", hex(fan_speed)], capture_output=True, text=True)

def main():
    print("Disabling dynamic firmware fan control")
    subprocess.run(["ipmitool", "raw", "0x30", "0x30", "0x01", "0x00"], capture_output=True, text=True)
    
    task = utils.PeriodicEvent(1, fan_update)
    systemd.daemon.notify('READY=1')
    print("Service ready, fans are now controlled manually")
    try:
        task.run()
    except Exception as e:
        print("Exception occured, reverting to dynamic fan control")
        print(e)
        subprocess.run(["ipmitool", "raw", "0x30", "0x30", "0x01", "0x01"], capture_output=True, text=True)
        return -1
    
    print("Service shutdown, reverting to dynamic fan control")
    subprocess.run(["ipmitool", "raw", "0x30", "0x30", "0x01", "0x01"], capture_output=True, text=True)
    return 0

if __name__ == "__main__":
    exit(main())