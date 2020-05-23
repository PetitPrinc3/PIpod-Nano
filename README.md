![](image/PIPOD1.png)
# 

A DIY Ipod nano lookalike involving a raspberry pi zero. 
The hardware I am currently using is :
 - Raspberry pi zero v1.3
 - [Pirate Audio Headphone Amp](https://shop.pimoroni.com/products/pirate-audio-headphone-amp)
 - [UPS Lite v1.2](https://fr.aliexpress.com/item/32954180664.html?spm=a2g0s.9042311.0.0.40de6c37VWMT3f)
 
I would however recommand the use of a [Raspberry pi zero w](https://www.kubii.fr/les-cartes-raspberry-pi/1851-raspberry-pi-zero-w-kubii-3272496006997.html), which is a bit more expensive, but has wifi on board that will make the installation way easier.
 
:information_source: This project uses the [Pinmonori Pirate-Audio](https://github.com/pimoroni/pirate-audio) github repository. This couldn't have been done without the huge work of [Mopidy](https://mopidy.com/) either ! It is also based on other open source projects. If you find your work to be used in my project and want a shout out, feel free to contact me.

Remember that those steps worked for me, they may not work for you. If you encounter any issue, please check the last paragraph.

#### How is the software different from the one provided by Pimonori? 

```
 - Reducing the volume increase/decrease sensibility
 - Hold the A button (play/pause button) for 3 seconds to safely shutdown the pi
 - Have the pi automatically play every song in a certain folder on boot
 - Tried a few combinations to have the fastest boot possible
```

## Getting started

These instructions will get you a copy of the project up and running on your pi. 

### Prerequisites

You'll need a fresh install of [Raspbian](https://www.raspberrypi.org/downloads/raspbian/) Buster.
Before following the steps below, make sure that your pi is connected to the internet and your Pirate Audio board is connected to your pi. At this point, it is preferable to have the pi plugged into the main, rather than having it running on the ups power supply. 

### Automatic Setup

A step by step series of examples that tell you how to get the project to work on your pi.

First you need to clone the repository :

```
git clone https://github.com/G-a-v-r-o-c-h-e/PIpod-Nano
```

Then go to the Pipod-Nano folder and give install.sh the right permissions :

```
cd PIpod-Nano
sudo chmod +x install.sh
```

You are now ready to run the installation. Run install.sh with root privileges and specify the path to the folder you want the pi to play music from :

:warning: Your path must not end with a slash (for example use /home/pi/Music rather than /home/pi/Music/)

```
sudo ./install.sh /home/pi/Music
```

Default folder will be /home/pi/Music if you don't mention any.

Reboot and you should be done !

### Manual Setup

First, follow the steps provided by [Pimonori](https://github.com/pimoroni/pirate-audio) to get the pirate audio software up and running on your pi.

Then you'll need to install mpd for mopidy and mpc, in order to have control over the the webclient through commands.

```
sudo apt-get install mpd-mopidy mpc -y
```

#### Play music on boot

Now, you'll want to create a bash script, that will allow you to have the pi play songs on boot automaticaly. You can either do something pretty simple such as :
 ```
 #!/bin/bash
 sleep 60 
 for song in `ls /home/pi/Music`; do mpc add 'file:///home/pi/Music/$song'; done
 mpc play
 ```
Or you can also do something a bit more complex, but that should be faster on boot, such as my autoplay.sh file.
If you decide that you want use this script, make sure that you add the following lines at the begining of the document :
```
#!/bin/bash
path=/home/pi/Music
```
Don't forget to create every folder and file that is mentioned into the script either.

You need to make this script executable so run :

```
sudo chmod +x autoplay.sh
```

Great, so now we want this script to be run on boot, so we will create a systemd service.
Create a file in /etc/systemd/system, that you'll name "something.service". Edit it whith whatever text editor you love and write :
```
[Unit]
Description= Some text
After=pulseaudio.service
After=remote-fs.target
After=sound.target
After=mopidy.service

[Service]
Type=simple
RemainAfterExit=no
ExecStart=/path/to/your/autoplay.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Now, to have it ran on boot :

```
sudo systemctl start something.service
sudo systemctl enable something.service
```

#### Edit the volume button's sensibility

To do this, navigate to /usr/local/lib/python3.7/dist-packages/mopidy_raspberry_gpio/ and edit the frontend.py file.

You're looking for this part of the document :

```
    def handle_volume_up(self):
        volume = self.core.mixer.get_volume().get()
        volume += 5
        volume = min(volume, 100)
        self.core.mixer.set_volume(volume)

    def handle_volume_down(self):
        volume = self.core.mixer.get_volume().get()
        volume -= 5
        volume = max(volume, 0)
        self.core.mixer.set_volume(volume)
```

Simply edit the volume +=/-= value from 5% to whatever you want (obviously a value between 0 and 100)

#### Poweroff button

First things first, we need to create a python file that will shutdown the pi if we hold the play button for a few secs. You can do this with whatever button you want, simply modify the GPIO value. My script will be the following :

```
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
```

Now to have this script run on boot, we will edit /etc/rc.local and add the following line before "exit 0" :

```
sudo python /path/to/your/pythonscript.py

exit 0
```

#### Allow Mopidy to load metadata

It is possible that Mopidy won't load your files properly (the artcover, title and author, etc.). To correct that, we need to increase the value of metadata_timeout in the mopidy.conf file. it is located at /etc/mopidy/mopidy.conf and you should edit the following :

```
[file]
enabled = true
media_dirs = /home/pi/Music
show_dotfiles = false
excluded_file_extensions =
  .directory
  .html
  .jpeg
  .jpg
  .log
  .nfo
  .pdf
  .png
  .txt
  .zip
follow_symlinks = false
metadata_timeout = 5000
```


And you're done ! You've succesfully (hopefully) performed every modification that the automated installation would have done ! Reboot the pi and here you go !

## Having an issue ?

### Common issues 

- The autoplay.sh seems not to be run on boot : no song is loaded to my playlist.
 ```
 Answer : did you give your script the authorization to be run ? (chmod +x) 
 If so, check 'systemctl status autoplay'. 
 If an mpd error appears, you need to make sure that mpc is working correctly. (simply type mpc)  
 if mpc is not working, try to reinstall mpd-mopidy.
 Otherwise, you may need to increase the sleeping time in your autoplay.sh file.
 ```
 - The power button is not working.
 ```
 Answer : check wether the /etc/rc.local file is executable or not. 
 make sure you did not forget the "&". 
 Check your python syntax.
 ```
 
 - Some of my files are not loading.
 ```
 Answer : Are you using a .mp3 / .wav / .flac file ?
 If you are not, please make sure your file is mopidy compatible and add your extension to the autoplay.sh as follows :
 sudo nano /usr/share/PIpodScripts/autoplay.sh
 Edit this line :
 for song in `ls $path | grep ".mp3\|.wav\|.flac\|.yourextension"`; do if [ `cat /usr/share/PIpodScripts/database |grep -c $song` -eq "0" ]; then echo $song >> /tmp/.db$;fi ; done
 ```
 
 For any other questions, feel free to contact me !

## To be done

```
- Allow the loading of files that contain spaces in their name
- Add a battery indicator on the screen
- Find a way to add a wake up function to the shutdown button
- Create a 3D model for a nice looking shell
```

## Thanks

Many thanks to :
 - The pimonori and mopidy community
 - The pimonori staff
 - The open source world

## Feel like helping me ?

I have a ton of projects and if you feel like helping me out, feel free to use this [Patreon](https://www.patreon.com/g_avroche).
Many thanks !
