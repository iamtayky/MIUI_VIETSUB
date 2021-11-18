#!/bin/bash
read -p "Press [Enter] key to start backup..."
read -p "Press any key to resume ..."
## Bash add pause prompt for 5 seconds ##
read -t 5 -p "I am going to wait for 5 seconds only ..."
part=(system product system_ext vendor)
dir=$(pwd)
cd $dir
	if [[ -d "temp" ]]; then
		rm -r temp
		rm -r zip_temp
	fi
