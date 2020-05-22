#!/bin/bash

if [ "$1" == "" ]
then
path=/home/pi/Music
else
path=$1
fi

read -r -p "The path to your music files will be $path. Are you sure ? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    echo The path to your music files will be $path
else
    exit 0
fi

function add_to_config_text {
    CONFIG_LINE="$1"
    CONFIG="$2"
    sed -i "s/^#$CONFIG_LINE/$CONFIG_LINE/" $CONFIG
    if ! grep -q "$CONFIG_LINE" $CONFIG; then
		printf "$CONFIG_LINE\n" >> $CONFIG
    fi
}

success() {
	echo -e "$(tput setaf 2)$1$(tput sgr0)"
}

inform() {
	echo -e "$(tput setaf 6)$1$(tput sgr0)"
}

warning() {
	echo -e "$(tput setaf 1)$1$(tput sgr0)"
}

inform "Begining, downloading Pimonori Pirate Audio  Software"
git clone https://github.com/pimoroni/pirate-audio
echo

inform "Runing Pirate Audio Installation"
chmod +x pirate-audio/mopidy/install.sh
sudo pirate-audio/mopidy/install.sh
echo

inform "Now performing Gavroche's modifications"

sudo apt-get install mpc mopidy-mpd -y

if [[ ! -d /usr/share/PIpodScripts ]]
then
    mkdir -p /usr/share/PIpodScripts
fi
if [[ ! -d /tmp ]]
then
    mkdir /tmp
fi

echo '#!/bin/bash' > /usr/share/PIpodScripts/autoplay.sh
echo >> /usr/share/PIpodScripts/autoplay.sh
echo path=$path >> /usr/share/PIpodScripts/autoplay.sh
cat autoplay.sh >> /usr/share/PIpodScripts/autoplay.sh
chmod +x /usr/share/PIpodScripts/autoplay.sh
mv powerbutton.py /usr/share/PIpodScripts/powerbutton.py
mv /etc/rc.local /etc/rc.local.save
cat /etc/rc.local.save | grep -v "exit 0" > /etc/rc.local
echo 'sudo python /usr/share/PIpodScripts/powerbutton.py &' >> /etc/rc.local
echo > /etc/rc.local
echo 'exit 0'>> /etc/rc.local
rm /etc/rc.local.save
mv autoplay.service /etc/systemd/system/autoplay.service
systemctl start autoplay.service
systemctl enable autoplay.service
mv frontend.py /usr/local/lib/python3.7/dist-packages/mopidy_raspberry_gpio/frontend.py
echo

success "Done"
echo
