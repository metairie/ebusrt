#!/bin/bash

echo "Launch srt-file-transmit in LISTENER mode"
export LD_LIBRARY_PATH=/usr/local/lib

while getopts h:p:i: option
do
 case $option in
 h) HOME_SRT=${OPTARG};;
 p) PORT_SRT=${OPTARG};;
 i) IPOP_SRT=$OPTARG;;
 esac
done

# json
# FIXME
if [ -f /tmp/ipop.json ]; then
	config="/tmp/ipop.json"
	IPOP_SRT=$(jq '. |  .IPOP_SRT' $config | tr -d '"')
fi

if [[ -z $HOME_SRT ]] 
then
	HOME_SRT=/tmp
fi
if [[ -z $PORT_SRT ]] 
then
	PORT_SRT=8080
fi
if [[ -z $IPOP_SRT ]] 
then
	IPOP_SRT=127.0.0.1
fi


echo " - Variables used for SRT"
echo "HOME_SRT: "$HOME_SRT
echo "PORT_SRT: "$PORT_SRT
echo "IPOP_SRT: "$IPOP_SRT

echo " - Verifying/Creating folders" 
cd $HOME_SRT
if [ ! -d "$HOME_SRT/RECEIVE" ]; then
  echo "  create $HOME_SRT/RECEIVE"
  mkdir $HOME_SRT/RECEIVE
else
  echo "  $HOME_SRT/RECEIVE exists yet"
fi
if [ ! -d "$HOME_SRT/LOT" ]; then
  echo "  create $HOME_SRT/LOT"
  mkdir $HOME_SRT/LOT
else
  echo "  $HOME_SRT/LOT exists yet"
fi
if [ ! -d "$HOME_SRT/DONE" ]; then
  echo "  create $HOME_SRT/DONE"
  mkdir $HOME_SRT/DONE
else
  echo "  $HOME_SRT/DONE exists yet"
fi

chmod 777 $HOME_SRT/RECEIVE -Rf
chmod 777 $HOME_SRT/LOT -Rf
chmod 777 $HOME_SRT/DONE -Rf

while true
do
	echo "----------------------------------------------------------------"
	echo " - Start: srt-file-transmit -v -loglevel=debug srt://:$PORT_SRT/ file://$HOME_SRT/RECEIVE"
	echo "   waiting file ... "
	srt-file-transmit -v -loglevel=debug srt://:$PORT_SRT/ file://$HOME_SRT/RECEIVE
	if [ $? -eq 0 ]
	then
		echo " Success "
		
		SAVEIFS=$IFS
		IFS=$(echo -en "\n\b")
		for entry in $HOME_SRT/RECEIVE/*
		do
			mv "$entry" $HOME_SRT/LOT/ -f
			echo " file $entry pushed from RECEIVE to LOT folder"
			ncftpput -u bkp -p bkp $IPOP_SRT / $HOME_SRT/LOT/*
			mv $HOME_SRT/LOT/* $HOME_SRT/DONE/ -f
			echo " file(s) moved from LOT to DONE"
		done
		IFS=$SAVEIFS

	else
		echo "XXXXX RECEIVED FILE FAILED XXXXX"
	fi
done
