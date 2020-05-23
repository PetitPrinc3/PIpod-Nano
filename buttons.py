#!/usr/bin/env python
from gpiozero import Button
import time
import os

stopButton = Button(5)

while True:
        if stopButton.is_pressed:
                tmp, duration = time.time(), 0
                while stopButton.is_pressed:
                        duration = time.time() - tmp
                        if duration > 3:
                                os.system("shutdown now -h")
        if volumeUp.is_pressed:
                time.sleep(.25)
                while volumeUp.is_pressed:
                        os.system("mpc volume +1")
                        time.sleep(.25)

        if volumeDown.is_pressed:
                time.sleep(.25)
                while volumeDown.is_pressed:
                        os.system("mpc volume -1")
                        time.sleep(.25)

        time.sleep(1)
