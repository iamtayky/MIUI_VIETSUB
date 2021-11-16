part=(system product system_ext vendor)
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

	mkdir zip_temp
	mkdir temp
	unzip stock/ziprom.zip -d zip_temp
	for ((i = 0 ; i < 4 ; i++)); do
		./bin/brotli --decompress zip_temp/"${part[$i]}.new.dat.br" -o zip_temp/"${part[$i]}.new.dat"
		./bin/sdat2img.py zip_temp/"${part[$i]}.transfer.list" zip_temp/"${part[$i]}.new.dat" "${part[$i]}.img"
		echo "extract "${part[$i]}.img" : done"
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
part_size[0]=$(find "system.img" -printf "%s")
part_size[1]=$(find "product.img" -printf "%s")
part_size[2]=$(find "system_ext.img" -printf "%s")
part_size[3]=$(find "vendor.img" -printf "%s")
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
echo "Start mountting ...."
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
list=`cat debloat.txt`
cd temp/system
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
cd ..
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
cd ..
sleep 1
for ((i = 0 ; i < 4 ; i++)); do
	resize2fs -f -M "${part[$i]}.img"
	echo "Shrink "${part[$i]}" :  done"
done
echo "#############################"
echo "#          DONE ....        #"
echo "#############################"
echo ""
}
cleanup()
{
	if [[ -d "temp" ]]; then
		rm -r temp
		rm -r zip_temp
		rm system.img
		rm product.img
		rm system_ext.img 
		rm vendor.img
		rm odm.img
	fi
}

cleanup
echo "#############################"
echo "#         STARTING ....     #"
echo "#############################"
echo ""
#cd stock
#if [[ -f "ziprom.zip" ]]; then
	#cd ..
	#echo "Zip rom detect"
	#zipfile
#elif [[ -f "super.img" ]]; then
	#cd ..
	#echo "Super.img detect"
#else wget -O ziprom.zip $1 && cd .. && zipfile
#fi
#mkrw
#mount
#debloat
#umount
#shrink

if [ -f "s_system.img" ]; then
		echo "- Repack vendor.img "
		./bin/img2sdat.py s_sytem.img -o $(pwd) -v 4 -p system
else echo "bug"
fi
