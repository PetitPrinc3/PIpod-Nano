mkdir -p /tmp
touch /tmp/.db$
touch /usr/share/PIpodScripts/database
for song in `ls $path`; do if [ `cat /usr/share/PIpodScripts/database |grep -c $song` -eq "0" ]; then echo $song >> /tmp/.db$;fi ; done
mv /usr/share/PIpodScripts/database /usr/share/PIpodScripts/database.save
cat /tmp/.db$ /usr/share/PIpodScripts/database.save > /usr/share/PIpodScripts/database

sleep 60
mpc volume 1

#Loading the playlist

if [ ! -s /tmp/.db$ ]
then
    lastsong=$(sed -n '1p' /usr/share/PIpodScripts/database)
    mpc add file://$path/$lastsong
    mpc play
    for song in `cat /usr/share/PIpodScripts/database`; do mpc add file://$path/$song; done
else
    if [[ ! -z /var/lib/mopidy/m3u/ ]]
    then
    lastsong=$(sed -n '1p' /usr/share/PIpodScripts/database)                                                                                                                                                           mpc add file:///$path/$lastsong
    mpc play
    for song in `cat /usr/share/PIpodScripts/database`; do mpc add file://$path/$song; done     
    else
         list=`find /var/lib/mopidy/m3u/ -printf '%T+ %p\n' | sort -r | grep "m3u8" | head -1 |grep -Eoi '/var/[^>]'`
         mpc load $list
         mpc play
    fi
fi

#Saving

filename=`date +"%Y%m%d%T" | tr -d ":"`
mpc save $filename

#Cleaning

rm /tmp/.db$

lists=`ls /var/lib/mopidy/m3u/ | grep -c ""`
if [ "$lists" -gt "3" ]
then
    last=`find /var/lib/mopidy/m3u/ -printf '%T+ %p\n' | sort -r | grep "m3u8" | head -1 |grep -Eoi '/var/[^>]+'`
    for list in find /var/lib/mopidy/m3u | grep "m3u8" | grep -v "$last"; do rm $list; done
fi
