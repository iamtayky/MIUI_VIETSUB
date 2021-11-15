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
	echo "new "${part[$i]}.img" is : $size"
	e2fsck -f "${part[$i]}.img"
	esize2fs "${part[$i]}.img" $size
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
sudo su
for ((i = 0 ; i < 4 ; i++)); do
	mkdir temp/"${part[$i]}" 
	mount "${part[$i]}.img" 
done

