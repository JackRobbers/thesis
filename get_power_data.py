from tapo import ApiClient
from datetime import datetime, timedelta
import csv
import sched
import time
import asyncio


async def get():
    client = ApiClient("j.robbers@unsw.edu.au", 'kdTk">>eJ"4|fZOAZZVx')
    device = await client.p110("192.168.1.119")

    # power is only updated at 1 Hz, but can poll arbitrarily fast


    async def get_power_and_time():
        response = await device.get_energy_usage()
        return (response.current_power, response.local_time)


    # TODO mock get_power_and_time funciton

    end = datetime.now() + timedelta(minutes=30)
    with open(f"../data/{end}_measure.csv", "w", newline="") as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(("Power (mW)", "Time", "Active"))

    last = (None, None, None)
    while (time := datetime.now()) < end:
        mins_left = int((end - time) / timedelta(minutes=1)) + 1

        current = (*await get_power_and_time(), True if mins_left % 5 == 0 else False)
        # write value if power is different
        if last:
            if current[0] != last[0]:
                with open(f"{end}_measure.csv", "a+", newline="") as csvfile:
                    writer = csv.writer(csvfile)
                    writer.writerow(current)

            if current[2] != last[2]:
                print(f"{"on" if current[2] else "off"} {mins_left}")
            last = current

            # stream this out to a file

            # get previous entry

if __name__ == "__main__":
    asyncio.run(get())