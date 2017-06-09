#!/bin/bash

function time_checker() {
    alarm=$1
    alarm_sec=$(date --date="$alarm" +"%s")
    current_sec=$(date +"%s")
    if [[ $alarm_sec -gt $current_sec ]]; then
	return 0
    else
	return 1
    fi
}

function sleep_time(){
    alarm=$1
    alarm_sec=$(date --date="$alarm" +"%s")
    current_sec=$(date +"%s")
    sleep_sec=$(($alarm_sec - $current_sec))
    echo $sleep_sec
}

function tomorrow() {
    # dumbass busybox could not understand "tomorrow" and "yesterday" like phrases!!
    # So, I'm forced to implement this function manually!
    today=$(date +"%F")
    year=$(echo $today | cut -d"-" -f1)
    month=$(echo $today | cut -d"-" -f2)
    day=$(echo $today | cut -d"-" -f3)
    day=$(( 10#$day + 1 ))
    date --date="$year-$month-$day" > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
	echo "$year-$month-$day"
	return 0
    else
	day=1
	month=$(( 10#$month + 1 ))
	date --date="$year-$month-$day" > /dev/null 2>&1
	if [[ $? -eq 0 ]]; then
	    echo "$year-$month-$day"
	    return 0
	else
	    month=1
	    year=$(( 10#$year + 1 ))
	fi
    fi
    echo "$year-$month-$day"
    return 0
}

function playlist_generator() {
    local musics_dir=$1
    for each_file in $(ls $musics_dir); do
	if [[ $(ls -lhd $musics_dir/$each_file | cut -c1) == "d" ]]; then
	    playlist_generator "$musics_dir/$each_file"
	else
	    echo $musics_dir/$each_file >> /tmp/playlist.txt
	fi
    done
}

function nop() {
    echo "A problem occured. Please check inputs and options."
    exit 1
}

oyad_path=$(echo $0 | rev | cut -d"/" -f2- | rev)

if $(time_checker $1) ; then
    remain_sec=$(sleep_time $1)
    alarm_time=$(date --date="$1")
else
    correct_date=$(tomorrow)
    remain_sec=$(sleep_time "$correct_date $1")
    alarm_time="$correct_date $1"
fi

rm /tmp/playlist.txt
playlist_generator $2 &
command="-shuffle -playlist /tmp/playlist.txt -loop 0"
echo "Alarmed at $alarm_time ..."
sleep $remain_sec
bash -x $oyad_path/oyad-backend.sh $command 1>/dev/null 2>&1 &
echo "Alarming ... "

