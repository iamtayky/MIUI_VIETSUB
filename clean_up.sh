#!/bin/bash
part=(system product system_ext vendor)
dir=$(pwd)
cd $dir
	if [[ -d "temp" ]]; then
		rm -r temp
		rm -r zip_temp
	fi
for ((i = 0 ; i < 4 ; i++)); do
	if [[ -f "${part[$i]}.img" ]]; then
	rm -rf ${part[$i]}.img
	echo "dome"
	fi
done
