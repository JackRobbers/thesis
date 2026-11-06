# Setup

Create a python virtual environment

`python3 -m venv .venv`

`source .venv/bin/activate`

# Recording Data

## 1. Device Setup

You should only need to do this step once

Plug in all of your Tapo P110 devices in. Follow the instructions on the tapo app to pair them. Make sure to set a nickname as this is used to verify that the correct data is coming in.

## 2. Configuration

You may need to repeat this step if the network changes or you want to record different devices

Create the file `src/experiment_config.yaml` to configure the tapo account and devices example would look like this:

```yaml
tapo:
  username: email@email.com
  password: password

network_prefix: 192.168.1.

# array of host configs
# [name, plug_name, host]
# name is the full device name, a folder matching this will be used to store data collected from the device
# plug_name is the name given to the device in the tapo app
# host is the last part of the ip address for the plug, can be found in the app
# plug_name and host must match, this protects against ip address reassignment causing data from the incorrect device to be confused.
hosts:
  - [AmazonEchoShow5, A, 248]
  - [GoogleNestHub, B, 229]
  - [AppleHomePod, C, 212]
  - [EZVIZ, D, 134]
  - [Aotec, E, 214]
  - [GoogleHome, F, 133]
```

## 3. Run the recorder

`python3 get_power_data.py`

This program doesn't output anything to stdout. Information is logged to a file identified by date in to top level of data/
