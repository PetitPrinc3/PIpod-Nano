# PIpod-Nano

A DIY Ipod nano lookalike involving a raspberry pi zero. 
The hardware I am currently using is :
 - Raspberry pi zero v1.3
 - [Pirate Audio Headphone Amp](https://shop.pimoroni.com/products/pirate-audio-headphone-amp)
 - [UPS Lite v1.2](https://fr.aliexpress.com/item/32954180664.html?spm=a2g0s.9042311.0.0.40de6c37VWMT3f)
 
I would however recommand the use of a [Raspberry pi zero w](https://www.kubii.fr/les-cartes-raspberry-pi/1851-raspberry-pi-zero-w-kubii-3272496006997.html), which is a bit more expensive, but has wifi on board that will make the installation way easier.
 
:information_source: This project uses the [Pinmonori Pirate-Audio](https://github.com/pimoroni/pirate-audio) github repository. It is also based on other open source projects. If you find your work to be used in my project and want a shout out, feel free to contact me.

#### How is the software different from the one provided by Pimonory? 

```
 - Reducing the volume increase/decrease sensibility
 - Hold the A button (play/pause button) for 3 seconds to safely shutdown the pi
 - Have the pi automatically play every song in a certain folder on boot
 - Tried a few combinations to have the fastest boot possible
```

## Getting started

These instructions will get you a copy of the project up and running on your pi. 

### Prerequisites

Before following the steps below, make sure that yourn pi is connected to the internet and your Pirate Audio board is connected to your pi. At this point, it is preferable to have the pi plugged into the main, rather than having it running on the ups power supply. 

### Installing

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

## To be done

```
- Add a battery indicator on the screen
- Find a way to add a wake up function to the shutdown button
```

## Thanks

Many thanks to :
 - The pimonori and mopidy community
 - The pimonori staff
 - The open source world

## Feel like helping me ?

I have a ton of projects and if you feel like helping me out, feel free to use this [Patreon](https://www.patreon.com/g_avroche)
Many thanks !
