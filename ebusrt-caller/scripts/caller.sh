echo "Launch srt-file-transmit in CALLER mode"
export LD_LIBRARY_PATH=/usr/local/lib

while getopts h:t:p: option
do
 case "${option}"
 in
 h) HOME_SRT=${OPTARG};;
 t) HOST_SRT=${OPTARG};;
 p) PORT_SRT=$OPTARG;;
 esac
done

SRT_POOL=10

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
echo " Variables used for SRT"
echo "HOME_SRT: "$HOME_SRT
echo "HOST_SRT targeted: "$HOST_SRT
echo "PORT_SRT: "$PORT_SRT

cd $HOME_SRT
loop=`ls $HOME_SRT/QUEUE | wc -l`
echo " Files to send in queue: "$loop
while [ ! $loop -eq 0 ]
do
	echo
	echo "Read pool of "$SRT_POOL" files MAX"
	# take pool number of files max for sending
	counter=0
	for entry in `ls $HOME_SRT/QUEUE/$search_dir`; do
		sudo mv $HOME_SRT/QUEUE/$entry $HOME_SRT/SEND/$entry
		((counter++))
		echo " file $counter $entry push to SEND"
		if [ "$counter" -eq $SRT_POOL ]; then
			break
		fi
	done
	echo
	filetosend=$HOST_SRT-`date +%Y%m%d_%H%M%S`-$RANDOM.tar
	echo "Package $counter files to compressed tar file: "$filetosend
	cd $HOME_SRT/SEND/
	tar -zcvf $HOME_SRT/$filetosend *
	cd $HOME_SRT
	mv SEND/* DONE/
	mv $filetosend SEND/
	echo "Archive "$filetosend" created"

	# launch sending
	for entry in `ls $HOME_SRT/SEND/$search_dir`; do

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
			sudo mv $HOME_SRT/SEND/$entry $HOME_SRT/DONE/$entry
			echo "File $entry sent and put in DONE folder"
		else
			echo "XXXXX FAILED XXXXX"
			sudo mv $HOME_SRT/SEND/$entry $HOME_SRT/QUEUE/$sentry
			echo "File $entry requeued in QUEUE folder"
		fi
		
		echo
		sleep 1
		
	done

	# loop again ?
	echo 
	loop=`ls $HOME_SRT/QUEUE | wc -l`
	echo " Files resting in queue: "$loop

done
