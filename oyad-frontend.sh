#!/bin/bash

function sleep_time(){
    alarm=$1
    alarm_sec=$(date --date=$alarm +"%s")
    current_sec=$(date +"%s")
    if [[ $alarm_sec -lt $current_sec ]]; then
	# alarm_time_sec=$(date --date="tomorrow $alarm_time" +"%s")
	current_time=$(date +"%T")
	current_date=$(date +"%F")
	alarm_date=$(tomorrow $current_date)
	alarm_sec=$(date --date="$alarm_date $alarm" +"%s")
    fi
    sleep_sec=$(($alarm_sec - $current_sec))
    echo $sleep_sec
}

function tomorrow() {
    # dumbass busybox could not understand "tomorrow" and "yesterday" like phrases!!
    # So, I'm forced to implement this function manually!
    today=$1
    year=$(echo $today | cut -d"-" -f1)
    month=$(echo $today | cut -d"-" -f2)
    day=$(echo $today | cut -d"-" -f3)
    day=$(($day + 1))
    date --date="$year-$month-$day" > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
	echo "$year-$month-$day"
	return 0
    else
	day=1
	month=$(( $month + 1 ))
	date --date="$year-$month-$day" > /dev/null 2>&1
	if [[ $? -eq 0 ]]; then
	    echo "$year-$month-$day"
	    return 0
	else
	    month=1
	    year=$(( $year + 1 ))
	fi
    fi
    echo "$year-$month-$day"
    return 0
}

function single_file() {
    song_file=$1
    command="-loop 0 $song_file"
}

function dir_files() {
    song_files=$()
}

oyad_path=$(echo $0 | rev | cut -d"/" -f2- | rev)

case $2 in
    single) single_file $3;;
    playlist) ;;
    random) ;;
    *) ;;
esac

remain_sec=$(sleep_time $1)
echo "wait for $remain_sec secs ..."
sleep $remain_sec
bash -x $oyad_path/oyad-backend.sh $command &
echo $remain_sec
