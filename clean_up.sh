#!/bin/bash
part=(system vendor)
dir=$(pwd)
cd $dir
	if [[ -d "temp" ]]; then
		rm -r temp
		rm -r zip_temp
		rm -r module/vietsub_f
		rm -r module/fonts_f
	fi
for ((i = 0 ; i < 2 ; i++)); do
	if [[ -f "${part[$i]}.img" ]]; then
	rm -rf ${part[$i]}.img
	echo "dome"
	fi
done
