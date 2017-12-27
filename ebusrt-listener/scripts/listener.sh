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
		for entry in `ls $HOME_SRT/RECEIVE/`; do
			mv $HOME_SRT/RECEIVE/$entry $HOME_SRT/LOT/ -f
			echo " file $entry pushed to LOT folder"
			if [ ${entry: -4} == ".txt" ]; then
				cd $HOME_SRT/LOT
				tar -zxvf $entry
				cd $HOME_SRT
				rm $entry
			else
				mv $entry LOT/ -f
			fi
			mv $HOME_SRT/LOT/$entry DONE/ -f
			echo " file moved to DONE and uncompressed"
		done

	else
		echo "XXXXX FAILED XXXXX"
	fi
done
