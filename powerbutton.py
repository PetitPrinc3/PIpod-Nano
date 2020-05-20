#!/usr/bin/env python
from gpiozero import Button
import time
import os

stopButton = Button(5)

while True:
     if stopButton.is_pressed:
        time.sleep(3)
        if stopButton.is_pressed:
            os.system("shutdown now -h")
     time.sleep(1)
