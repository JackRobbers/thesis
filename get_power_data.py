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
import yaml
import logging
logger = logging.getLogger()
logfile = f"../data/{datetime.now().isoformat(timespec='seconds')}.log"
    
logging.basicConfig(filename=logfile, level=logging.INFO, datefmt='%Y-%m-%d %H:%M:%S',    format='%(asctime)s %(levelname)-8s %(message)s',)
# Could do some kind of autodiscovery, but pretty slow.
# Run nmap externally?


# Write power at 1HZ forever
async def write_power(client, device_name, nickname, ip):
    # running thurs - mon made a 37gb logfile, only log the first error to prevent this
    log_error = True
    while True:
        try:
            directory = f"../data/{device_name}"
            if not os.path.isdir(directory):
                os.mkdir(directory)

            start = datetime.now()
            device = await client.p110(ip)
            info = await device.get_device_info()
            if nickname != info.nickname:
                raise ValueError

            filename= f"{directory}/{start.isoformat()}.csv"

            with open(filename, "w", newline="") as csvfile:
                writer = csv.writer(csvfile)
                writer.writerow(("Time","Power_mW"))
                log_error = True
        except Exception as e:
            if log_error:
                logger.info(f"Failed to setup {device_name}, retrying: {e}")
                log_error = False
            # contiue, so restart outer loop
            continue

        while True:
            try:
                with open(filename, "a", newline="") as csvfile:
                    response = await device.get_energy_usage()
                    writer = csv.writer(csvfile)
                    writer.writerow((response.local_time.isoformat(timespec="milliseconds"), response.current_power))
                    log_error = True
                    
                await asyncio.sleep(1)

            except Exception as e:
                if log_error:
                    logger.info(f'Failed to read from {device_name}, restarting connection {e}')
                    log_error = False
                # break, and go back to outer loop
                break
        


async def run():

    with open("experiment_config.yaml") as y:
        config = yaml.safe_load(y)
    client = ApiClient(config['tapo']['username'], config['tapo']['password'])

    
    print(f"Running, check {logfile} for errors")
    logger.info(f"Starting with config: {config['hosts']}")
    async with asyncio.TaskGroup() as tg:
        for device_name, nickname, host in config['hosts']:
            tg.create_task(write_power(client, device_name, nickname, f"{config['network_prefix']}{host}"))

           
        


import atexit
atexit.register(lambda: logger.info("Program Killed"))

if __name__ == "__main__":
    asyncio.run(run())
