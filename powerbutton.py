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

        time.sleep(1)
