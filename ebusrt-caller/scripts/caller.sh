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

for entry in `ls $HOME_SRT/SEND/$search_dir`; do

	echo "--------------------------------"
	echo "Send file "$entry
	result=0

	echo "srt-file-transmit -v -loglevel=debug file://$HOME_SRT/SEND/$entry srt://$HOST_SRT:$PORT_SRT/"	
	if [ -f $HOME_SRT/SEND/$entry ]
	then
		srt-file-transmit -v -loglevel=debug file://$HOME_SRT/SEND/$entry srt://$HOST_SRT:$PORT_SRT/
		if [ $? -eq 0 ]
		then
			result=1
		else
			result=0
		fi
	fi
	
	if [ $result -eq 1 ]
	then
		echo "Success"
		sudo mv $HOME_SRT/SEND/$entry $HOME_SRT/DONE/$entry
		echo "File $entry sent and put in DONE folder"
	else
		echo " ++++ FAILED ++++ "
		sudo mv $HOME_SRT/SEND/$entry $HOME_SRT/QUEUE/$sentry
		echo "File $entry requeued in QUEUE folder"
	fi
	
	echo
	sleep 1

done
