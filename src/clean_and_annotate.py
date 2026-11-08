# move the longest datasets to data/device/idle.csv
from util import *
from pathlib import Path
import os
import pandas as pd
import shutil

c = Context("Raw Data")

device_to_files = {device: os.listdir(c.path / device.dir_name) for device in c.devices}

# find a homepod trace longer than 40 minutes
length = 0
# for device in c.devices:
apple = c.device_from_name("AppleHomePod")
for device in c.devices:
    file_len = (
        lambda file: len(pd.read_csv(c.path / device.dir_name / file).index) / 60 / 60
    )
    longest = sorted(device_to_files[device], key=file_len, reverse=True)[:3]

    print(device, longest, list(map(file_len, longest)))

# We have two almost day long traces, select the one from a Saturday
# all at 4:58 am on saturday morning
# millis don't match
# copy them
for device in c.devices:
    device_path = Path(__file__).parent.parent / "data" / device.dir_name
    if not path.isdir(device_path):
        os.mkdir(device_path)
    shutil.copy2(
        list((c.path / device.dir_name).rglob("2026-10-24T00:04:58.*.csv"))[0],
        device_path / "idle.csv",
    )
