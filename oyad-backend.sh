#!/bin/bash

mplayer_args=$*

mplayer=$(which mplayer)

function volume_manager() {
    # STEP ONE
    for count in {0..24}; do
	amixer sset Master 1%+ 
	sleep 3s
    done
    
    # wait 5 minutes until start step two
    sleep 5m
    
    # STEP TWO
    for count in {0..14}; do
	amixer sset Master 2%+ 
	sleep 5s
    done
    
    # wait 5 minutes until start step three
    sleep 10m
    
    # STEP THREE
    for count in {0..6}; do
	amixer sset Master 5%+ 
	sleep 10s
    done
}

# decrease the volume level to 10%
amixer sset Master 10%

$mplayer $mplayer_args
volume_manager

