# Script for monitoring the power usage of devices
# Requires python
# Targetted tapo devices must first be paired and connect using the mobile app. Ensure that "me > Third-Party Services > Third-Party Compatibility" is enabled. After pairing a new device you may need to toggle this setting.
# Contains credentials for my account

# TODO notify on crash?
# 9 kB in 5 minutes
# so 12*9 = 108 kB / hour
# * 6 so .6 mB / hour
# a weekend is 72 hours, 43.2 mB. Really nothing! would fit on internal storage.on
# Upload to onedrive, cronjob to backup
# https://github.com/abraunegg/onedrive
# https://github.com/abraunegg/onedrive/blob/master/docs/ubuntu-package-install.md

from tapo import ApiClient
from datetime import datetime
import csv
import asyncio
import os

client = ApiClient("j.robbers@unsw.edu.au", 'kdTk">>eJ"4|fZOAZZVx')

NETWORK_PREFIX = "192.168.1."

# key is the device the tapo is connect to
# first value element is the nickname in the tapo app of the device
# second value element is the host number on the network 
HOSTS = {
    "googlehome": ("A", "248"),
    "amazonecho": ("B", "229"),
    "amazonecho2": ("C", "212"),
    "amazonechoshow": ("D", "134"),
    "grdconnect": ("E", "214"),
    "googleguik2": ("F", "133"),
}

# Could do some kind of autodiscovery, but pretty slow.
# Run nmap externally?


# Write power at 1HZ forever
async def write_power(device_name, nickname, host):
    while True:
        try:
            directory = f"../data/{device_name}"
            if not os.path.isdir(directory):
                os.mkdir(directory)

            start = datetime.now()
            device = await client.p110(f"{NETWORK_PREFIX}{host}")
            info = await device.get_device_info()
            if nickname != info.nickname:
                raise ValueError

            filename= f"{directory}/{start.isoformat()}.csv"

            with open(filename, "w", newline="") as csvfile:
                writer = csv.writer(csvfile)
                writer.writerow(("Time","Power_mW"))
        except Exception as e:
            print(f"Failed to setup {device_name}, retrying: {e}")
            # contiue, so restart outer loop
            continue

        while True:
            try:
                with open(filename, "a", newline="") as csvfile:
                    response = await device.get_energy_usage()
                    writer = csv.writer(csvfile)
                    writer.writerow((response.local_time.isoformat(timespec="milliseconds"), response.current_power))

                await asyncio.sleep(1)

            except Exception as e:
                print(f'Failed to read from {device_name}, restarting connection {e}')
                # break, and go back to outer loop
                break
        


async def run():
    async with asyncio.TaskGroup() as tg:
        for device_name, (nickname, host) in HOSTS.items():
            tg.create_task(write_power(device_name, nickname, host))

           
        


    

if __name__ == "__main__":
    asyncio.run(run())
