#!/bin/bash

function sleep_time(){
    alarm_time=$1
    alarm_time_sec=$(date --date=$alarm_time +"%s")
    current_time_sec=$(date +"%s")
    if [[ $alarm_time_sec -lt $current_time_sec ]]; then
	alarm_time_sec=$(date --date="tomorrow $alarm_time" +"%s")
    fi
    sleep_sec=$(($alarm_time_sec - $current_time_sec))
    echo $sleep_sec
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

sleep $(sleep_time $1)
bash -x $oyad_path/oyad-backend.sh $command

