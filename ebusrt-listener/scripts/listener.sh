echo "Launch srt-file-transmit in LISTENER mode"
export LD_LIBRARY_PATH=/usr/local/lib

while getopts h:p: option
do
 case $option in
 h) HOME_SRT=${OPTARG};;
 p) PORT_SRT=$OPTARG;;
 esac
done

if [[ -z $HOME_SRT ]] 
then
	HOME_SRT=/tmp
fi
if [[ -z $PORT_SRT ]] 
then
	PORT_SRT=8080
fi

echo " - Variables used for SRT"
echo "HOME_SRT: "$HOME_SRT
echo "PORT_SRT: "$PORT_SRT

echo " - Verifying/Creating folders" 
cd $HOME_SRT
if [ ! -d "$HOME_SRT/RECEIVE" ]; then
  echo "  create $HOME_SRT/RECEIVE"
  mkdir $HOME_SRT/RECEIVE
else
  echo "  $HOME_SRT/RECEIVE exists yet"
fi
if [ ! -d "$HOME_SRT/DONE" ]; then
  echo "  create $HOME_SRT/DONE"
  mkdir $HOME_SRT/DONE
else
  echo "  $HOME_SRT/DONE exists yet"
fi

chmod 777 $HOME_SRT/RECEIVE -Rf
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
		IN=${1:-0.0.0.0-20000101-000000-000000.tar}

		OIFS=$IFS
		IFS='-'
		m=$IN
		count=0
		IP="255.255.255.255"
		DATEYMD="19991231"
		TIMEHMS="235959"
		RND="999999.tar"
		for x in $m
		do
			# IP
			if [ $count -eq 0 ]; then
				IP=$x
			fi

			# date YYMMDD
			if [ $count -eq 1 ]; then
				DATEYMD=$x
			fi
			
			# date time HHMMSS
			if [ $count -eq 2 ]; then
				TIMEHMS=$x
			fi
			
			# random
			if [ $count -eq 3 ]; then
				RND=$x
			fi
			
			((count++))
		done
		IFS=$OIFS
		FILENAME="$IP-$DATEYMD-$TIMEHMS-$RND"
		echo "$DATEYMD:$TIMEHMS [$IP] successfully received file name $FILENAME"
		mv $HOME_SRT/RECEIVE/$FILENAME $HOME_SRT/DONE$FILENAME
		tar -zxvf $HOME_SRT/DONE/$FILENAME
		echo " file moved to DONE and uncompressed"
	
	else
		echo "XXXXX FAILED XXXXX"
	fi
done
