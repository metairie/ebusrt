#!/bin/bash

echo "Launch srt-file-transmit in CALLER mode"
export LD_LIBRARY_PATH=/usr/local/lib

# args
while getopts h:t:s:p: option
do
 case "${option}"
 in
 h) HOME_SRT=${OPTARG};;
 t) HOST_SRT=${OPTARG};;
 s) PORT_SRT=${OPTARG};;
 p) POOL_SRT=$OPTARG;;
 esac
done

# json
# FIXME
if [ -f /tmp/srt.json ]; then
	config="/tmp/srt.json"
	waitfileinsec=$(jq '. |  .waitfileinsec' $config | tr -d '"')
	HOME_SRT=$(jq '. |  .HOME_SRT' $config | tr -d '"')
	HOST_SRT=$(jq '. |  .HOST_SRT' $config | tr -d '"')
	PORT_SRT=$(jq '. |  .PORT_SRT' $config | tr -d '"')
	POOL_SRT=$(jq '. |  .POOL_SRT' $config | tr -d '"')
fi

# default
if [[ -z $waitfileinsec ]] 
then
	waitfileinsec=5
fi
if [[ -z $HOME_SRT ]] 
then
	HOME_SRT=/tmp
fi
if [[ -z $HOST_SRT ]] 
then
	HOST_SRT=127.0.0.1
fi
if [[ -z $PORT_SRT ]] 
then
	PORT_SRT=8080
fi
if [[ -z $POOL_SRT ]] 
then
	POOL_SRT=1
fi

echo " ::::::: Variables used for SRT ::::::: "
if [ "$waitfileinsec" -lt 5 ]; then
	waitfileinsec=5
fi
echo "waitfileinsec: "$waitfileinsec
echo "HOME_SRT: "$HOME_SRT
echo "HOST_SRT targeted: "$HOST_SRT
echo "PORT_SRT: "$PORT_SRT
echo "POOL_SRT: "$POOL_SRT

echo " - Verifying/Creating folders" 
cd $HOME_SRT
if [ ! -d "$HOME_SRT/QUEUE" ]; then
  echo "  create $HOME_SRT/QUEUE"
  mkdir $HOME_SRT/QUEUE
else
  echo "  $HOME_SRT/QUEUE exists yet"
fi
if [ ! -d "$HOME_SRT/TREATED" ]; then
  echo "  create $HOME_SRT/TREATED"
  mkdir $HOME_SRT/TREATED
else
  echo "  $HOME_SRT/TREATED exists yet"
fi
if [ ! -d "$HOME_SRT/SEND" ]; then
  echo "  create $HOME_SRT/SEND"
  mkdir $HOME_SRT/SEND
else
  echo "  $HOME_SRT/SEND exists yet"
fi

chmod 777 $HOME_SRT/QUEUE -Rf
chmod 777 $HOME_SRT/TREATED -Rf
chmod 777 $HOME_SRT/SEND -Rf

while :
do
	cd $HOME_SRT
	loop=`ls $HOME_SRT/QUEUE | wc -l`
	echo " Files to send in queue: "$loop
	while [ ! $loop -eq 0 ]
	do
		echo
		echo "Read pool of "$POOL_SRT" files MAX"
		# take pool number of files max for sending
		counter=0
		SAVEIFS=$IFS
		IFS=$(echo -en "\n\b")
		for entry in $HOME_SRT/QUEUE/*
		do
			mv "$entry" $HOME_SRT/SEND/ -f
			((counter++))
			echo " file $counter $entry push to SEND folder"
			if [ "$counter" -eq $POOL_SRT ]; then
				break
			fi	  
		done
		IFS=$SAVEIFS

		# launch sending
		SAVEIFS=$IFS
		IFS=$(echo -en "\n\b")
		for entry in $HOME_SRT/SEND/*
		do
			echo "----------------------------------------------------------------"
			echo "Send file "$entry
			result=0

			# ADD this for verbose and debug 
			# -v -loglevel=debug
			echo "srt-file-transmit file://$entry srt://$HOST_SRT:$PORT_SRT/"

			if [ -f $entry ]
			then
				echo "$c"
				ret=0
				command=$(srt-file-transmit file://$entry srt://$HOST_SRT:$PORT_SRT/)
				ret=$?
				error=$(echo "$command" | grep -i 'error' | wc -l)
				if [ $error -gt 0 ] || [ $r -gt 0 ]
				then
					result=0
				else
					result=1
				fi
			fi

			if [ $result -eq 0 ]
			then
				echo "Success"
				mv "$entry" $HOME_SRT/TREATED/ -f
				echo "File $entry correctly sent and put in TREATED folder"
			else
				echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXX"
				echo "XXXXX SEND FILE FAILED XXXXX"
				echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXX"
				mv "$entry" $HOME_SRT/QUEUE/ -f
				echo "File $entry moved to QUEUE folder"
			fi

		done
		IFS=$SAVEIFS

		# loop again ?
		echo 
		loop=`ls $HOME_SRT/QUEUE | wc -l`
		echo " Number of files resting in queue: "$loop

	done
	
	sleep $waitfileinsec
done
