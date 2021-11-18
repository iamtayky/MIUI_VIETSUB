#!/bin/bash
part=(system product system_ext vendor)
dir=$(pwd)
bin="$dir/bin/linux"
bro="$dir/zip_temp"
getszie()
{
	part_size[0]=$(find "system.img" -printf "%s")
	part_size[1]=$(find "product.img" -printf "%s")
	part_size[2]=$(find "system_ext.img" -printf "%s")
	part_size[3]=$(find "vendor.img" -printf "%s")
}
super()
{
echo "#############################"
echo "#     Unpack Super.img .... #"
echo "#############################"
echo ""
echo "Convert sparse images to raw images ...."
echo ""
./bin/simg2img super.img raw.img
echo "Unpack super parttion ...."
echo ""
./bin/lpunpack raw.img
}
zipfile()
{
echo "#############################"
echo "#     Unpack Zip rom .... #"
echo "#############################"
	mkdir zip_temp
	mkdir temp
	unzip -t ziprom.zip
	unzip ziprom.zip -d zip_temp
	for ((i = 0 ; i < 4 ; i++)); do
		./bin/brotli --decompress zip_temp/"${part[$i]}.new.dat.br" -o zip_temp/"${part[$i]}.new.dat"
		./bin/sdat2img.py zip_temp/"${part[$i]}.transfer.list" zip_temp/"${part[$i]}.new.dat" "${part[$i]}.img"
		echo "extract "${part[$i]}.img" : done"
	done
	getszie
	for ((i = 0 ; i < 4 ; i++)); do
	sed -i "s/${part_size[$i]}/"${part[$i]}_size"/g" "$bro/dynamic_partitions_op_list"
	done
}
######################
mkrw()
{
echo "#############################"
echo "#       READ-WRITE ....     #"
echo "#############################"
echo ""
echo "Get Parttion size ...."
echo ""
getszie
echo "Resize Parttion ...."
for ((i = 0 ; i < 4 ; i++)); do
	size=$(echo "${part_size[$i]} + 50000000" | bc)
	size1=$(echo "$size / 1024" | bc)
	echo "new "${part[$i]}.img" is : $size"
	e2fsck -f "${part[$i]}.img"
	resize2fs "${part[$i]}.img" $size1
done
echo ""
echo "Start remove Read-Only ...."
for ((i = 0 ; i < 4 ; i++)); do
	e2fsck -E unshare_blocks "${part[$i]}.img"
	echo ""${part[$i]}.img" : done"
done
}
##########
mount()
{
clear
echo "#############################"
echo "#        Mounting ....     #"
echo "#############################"
echo ""
echo "Enter your password to use Sudo ...."
for ((i = 0 ; i < 4 ; i++)); do
	mkdir temp/"${part[$i]}" 
	sudo mount "${part[$i]}.img" temp/"${part[$i]}" 
done
}
########
debloat()
{
echo "#############################"
echo "#       Debloating ....     #"
echo "#############################"
echo ""
echo "Debloating ...."
list=`cat $dir/bin/debloat.txt`
cd $dir/temp/system
  for app in $list; do
        sudo rm -r "$app"
        echo "done"
  done
}
#########
#########
umount()
{
echo "#############################"
echo "#        Unmounting ....    #"
echo "#############################"
echo ""
cd $dir/temp
sleep 3
for ((i = 0 ; i < 4 ; i++)); do
	sudo umount "${part[$i]}"
	echo "Umount "${part[$i]}" :  done"
	sleep 3
done
}
##########
shrink () 
{
echo "#############################"
echo "#        Shrinking ....     #"
echo "#############################"
echo ""
cd $dir
sleep 1
for ((i = 0 ; i < 4 ; i++)); do
	resize2fs -f -M "${part[$i]}.img"
	echo "Shrink "${part[$i]}" :  done"
done
getszie
	for ((i = 0 ; i < 4 ; i++)); do
	sed -i "s/"${part[$i]}_size"/"${part_size[$i]}"/g" "$bro/dynamic_partitions_op_list"
	done
}
cleanup()
{
	cd $dir
	if [[ -d "temp" ]]; then
		rm -r temp
		rm -r zip_temp
	fi
}
remove_source()
{
echo "#############################"
echo "#  remove source file ....   #"
echo "#############################"
echo ""
cd $dir/zip_temp
	for ((i = 0 ; i < 4 ; i++)); do
		if [[ -f "${part[$i]}.new.dat.br" ]]; then
			rm "${part[$i]}.new.dat.br"
			rm "${part[$i]}.new.dat"
			rm "${part[$i]}.patch.dat" 
			rm "${part[$i]}.transfer.list"
		fi
	done
cd ..
}
vietsub()
{
echo "#############################"
echo "#       VIETSUB-ING ....    #"
echo "#############################"
echo ""
	cd $dir
	echo "copy bhlnk's overlay and stuff"
	sudo cp -a vietsub/. $dir/temp/
	echo "give permisstion ...."
	per=$(cat $dir/bin/permiss.txt)
	for p in $per; do
		if [[ -d "$dir/temp/$p" ]]; then
			sudo chmod 755 $dir/temp/$p
		else sudo chmod 644 $dir/temp/$p
		fi
	done
	echo "done"
}
repackz()
{
clear
echo "#############################"
echo "#         Compress          #"
echo "#############################"
echo ""
echo "Compress to sparse img .... "
for ((i = 0 ; i < 4 ; i++)); do
	./bin/img2simg "${part[$i]}.img" "s_${part[$i]}.img"
done
echo "Compress to new.dat .... "
for ((i = 0 ; i < 4 ; i++)); do
	echo "- Repack ${part[$i]}.img"
 	python3 ./bin/linux/img2sdat.py "s_${part[$i]}.img" -o $bro -v 4 -p "${part[$i]}"
done

#level brotli
echo "Compress to brotli .... "
#
for ((i = 0 ; i < 4 ; i++)); do
   	echo "- Repack ${part[$i]}.new.dat"
	$bin/brotli -1 -j -w 24 "$bro/${part[$i]}.new.dat" -o "$bro/${part[$i]}.new.dat.br"
	rm -rf "${part[$i]}.img"
	rm -rf "s_${part[$i]}.img"
	rm -rf "$bro/${part[$i]}.new.dat"
done

if [ -d $bro/META-INF ]; then
	echo "- Zipping"
	[ -f ./new_rom.zip ] && rm -rf ./new_rom.zip
	$bin/7za a -tzip "$dir/MIUI_VIETSUB.zip" $bro/*  
fi


if [ -f "$dir/new_rom.zip" ]; then
      echo "- Repack done"
else
      echo "- Repack error"
fi
}
cleanup
echo "#############################"
echo "#         STARTING ....     #"
echo "#############################"
echo ""
read -p "Press [Enter] key to start modify..."
if [[ -f "ziprom.zip" ]]; then
	echo "Zip rom detect"
	zipfile
elif [[ -f "super.img" ]]; then
	echo "Super.img detect"
else wget -O ziprom.zip $1 && cd .. && zipfile
fi
mkrw
mount
###############
printf "Do you want remove most unuse app ...\n"
printf "press y to debloat or n to skip\n"
#read x
#if [[ $x == "y" ]]; then
	#debloat
#fi
#vietsub
debloat
umount
shrink
read -p "Press any key to resume ..."
remove_source
echo "#############################"
echo "#         Compress          #"
echo "#############################"
echo ""
repackz