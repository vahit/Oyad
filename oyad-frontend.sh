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

function playlist() {
    playlist=$1
    command="-playlist $playlist -loop 0"
}

function playlist_generator() {
    musics_dir=$1
    for each_file in $(ls $musics_dir); do
	if [[ $(file --brief $each_file | awk '{print $1}') == "directory" ]]; then
	    playlist_generator "$musics_dir/$each_file"
	else
	    echo $musics_dir/$each_file >> /tmp/playlist.txt
	fi
    done
    playlist /tmp/playlist.txt
}

function nop() {
    echo "A problem occured. Please check inputs and options."
    exit 1
}

function source_detector() {
    source=$1
    source_type=$(file --brief $source | cut -f1 -d " ")
    case $source_type in
	Audio) single_file $source ;;
	ASCII) playlist $source ;;
	directory) playlist_generator $source ;;
	*) nop ;;
    esac
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

source_detector $2
echo "Alarmed at $alarm_time ..."
sleep $remain_sec
bash -x $oyad_path/oyad-backend.sh $command &
