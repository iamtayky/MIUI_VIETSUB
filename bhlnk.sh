part=(system product system_ext vendor)
mkdir temp

echo "Convert sparse images to raw images ...."
echo ""
./bin/simg2img super.img raw.img
echo "Unpack super parttion ...."
echo ""
./bin/lpunpack raw.img
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
clear
echo "Start mountting ...."
echo "Enter your password to use Sudo ...."
for ((i = 0 ; i < 4 ; i++)); do
	mkdir temp/"${part[$i]}" 
	sudo mount "${part[$i]}.img" temp/"${part[$i]}" 
done
echo "#############################"
echo "#     Start Modifing ....   #"
echo "#############################"
echo ""
echo "Debloating ...."
list=`cat debloat.txt`
cd temp/system
  for app in $list; do
        sudo rm -r "$app"
        echo "done"
  done
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
echo "#############################"
echo "#        Shrinking ....     #"
echo "#############################"
echo ""
cd ..
sleep 1
for ((i = 0 ; i < 4 ; i++)); do
	resize2fs -f -M ${part[$i]}.img"
	echo "Shrink "${part[$i]}" :  done"
done


