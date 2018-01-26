#!/bin/bash

echo "Launch srt-file-transmit in CALLER mode"
export LD_LIBRARY_PATH=/usr/local/lib

# args
while getopts h:t:p: option
do
 case "${option}"
 in
 h) HOME_SRT=${OPTARG};;
 t) HOST_SRT=${OPTARG};;
 p) PORT_SRT=$OPTARG;;
 esac
done

# json
if [ -f /tmp/srt.json ]; then
	config="/tmp/srt.json"
	HOME_SRT=$(jq '. |  .HOME_SRT' $config | tr -d '"')
	HOST_SRT=$(jq '. |  .HOST_SRT' $config | tr -d '"')
	PORT_SRT=$(jq '. |  .PORT_SRT' $config | tr -d '"')
fi

# default
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

POOL_SRT=10
echo " Variables used for SRT"
echo "POOL_SRT: "$POOL_SRT
echo "HOME_SRT: "$HOME_SRT
echo "HOST_SRT targeted: "$HOST_SRT
echo "PORT_SRT: "$PORT_SRT

echo " - Verifying/Creating folders" 
cd $HOME_SRT
if [ ! -d "$HOME_SRT/QUEUE" ]; then
  echo "  create $HOME_SRT/QUEUE"
  mkdir $HOME_SRT/QUEUE
else
  echo "  $HOME_SRT/QUEUE exists yet"
fi
if [ ! -d "$HOME_SRT/BATCH" ]; then
  echo "  create $HOME_SRT/BATCH"
  mkdir $HOME_SRT/BATCH
else
  echo "  $HOME_SRT/BATCH exists yet"
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
chmod 777 $HOME_SRT/BATCH -Rf
chmod 777 $HOME_SRT/TREATED -Rf
chmod 777 $HOME_SRT/SEND -Rf

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
		echo " read file no:$counter"
		mv "$HOME_SRT/QUEUE/$entry" $HOME_SRT/SEND/ -f
		((counter++))
		echo " file $counter $entry push to SEND folder"
		if [ "$counter" -eq $POOL_SRT ]; then
			break
		fi	  
	done
	IFS=$SAVEIFS

	echo
	filetosend=$HOST_SRT-`date +%Y%m%d_%H%M%S`-$RANDOM.tar
	echo "Package $counter files to a slighty compressed tar file: "$filetosend
	cd $HOME_SRT/SEND/
	tar -zcvf "$HOME_SRT/$filetosend" *
	cd $HOME_SRT
	# move all source files in the batch into this temp folder
	mv SEND/* BATCH/ -f
	# tar file is pushed to SEND
	mv "$filetosend" SEND/ -f
	echo "Archive SEND/"$filetosend" created"

	# launch sending
	SAVEIFS=$IFS
	IFS=$(echo -en "\n\b")
	for entry in $HOME_SRT/SEND/*
	do
		echo "----------------------------------------------------------------"
		echo "Send file "$entry
		result=0

		echo "srt-file-transmit -v -loglevel=debug file://$HOME_SRT/SEND/$entry srt://$HOST_SRT:$PORT_SRT/"	
		if [ -f $HOME_SRT/SEND/$entry ]
		then
			srt-file-transmit -v -loglevel=debug file://$HOME_SRT/SEND/$entry srt://$HOST_SRT:$PORT_SRT/
			if [ $? -eq 0 ]
			then
				result=0
			else
				result=1
			fi
		fi
		
		if [ $result -eq 0 ]
		then
			echo "Success"
			mv "$HOME_SRT/SEND/$entry" $HOME_SRT/TREATED/ -f
			echo "File $entry correctly sent and put in TREATED folder"
			rm $HOME_SRT/BATCH/* -f
			echo "Corresponding files in BATCH folder are removed"
		else
			echo "XXXXX FAILED XXXXX"
			rm "$HOME_SRT/SEND/$entry" -f
			echo "File $entry removed"
			mv $HOME_SRT/BATCH/* $HOME_SRT/QUEUE/ -f
			echo "Files from BATCH requeued in QUEUE folder"
		fi
		
		echo
		sleep 1

	done
	IFS=$SAVEIFS
	

	# loop again ?
	echo 
	loop=`ls $HOME_SRT/QUEUE | wc -l`
	echo " Files resting in queue: "$loop

done
