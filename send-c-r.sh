#!/bin/bash

xdotool windowactivate "$(xdotool search --class "$1" | tail -1)" \
	key ctrl+r windowactivate "$(xdotool getactivewindow)"
