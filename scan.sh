#!/bin/bash
set -eu
TIMESTAMP=$(date +%Y%m%d%H%M%S)
if [ $# -eq 0 ]; then
  read -p "premi ENTER per iniziare la scansione" pausa
fi
#bianco e nero
scanimage --progress --buffer-size=256 --mode Gray --format=tiff --resolution 150 > /tmp/$TIMESTAMP.tiff
#colori
#scanimage --progress --buffer-size=256 --mode color --format=tiff --resolution 300 > /tmp/$TIMESTAMP.tiff
#
#scommentare prossima riga per normalizzare colori
mogrify -normalize -level 10%,90% -sharpen 0x1 /tmp/$TIMESTAMP.tiff
#####################
#crea pdf
convert /tmp/$TIMESTAMP.tiff -density 300x300 -quality 90 -compress jpeg /home/andrea/scansioni/$TIMESTAMP.pdf
#scommentare la prossima riga per produrre anche jpg
#convert /tmp/$TIMESTAMP.tiff -density 300x300 -quality 90 -compress jpeg /home/andrea/scansioni/$TIMESTAMP.jpg
if [ $# -ne 0 ]; then
  echo "Sending mail to $1 ..."
  echo $TIMESTAMP.pdf | mail -A /home/andrea/scansioni/$TIMESTAMP.pdf -s $TIMESTAMP.pdf $1
fi

echo File salvato come /home/andrea/scansioni/$TIMESTAMP.pdf / jpg
rm /tmp/$TIMESTAMP.tiff
# remove old files
find /home/andrea/scansioni -type f -mtime +15 -delete
