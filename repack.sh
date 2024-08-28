#!/bin/bash
# requirements: sudo jq sfdisk u-boot-tools

[ "$EUID" != "0" ] && echo "please run as root" && exit 1
xzimage = "Armbian_23.11.1_Rockpi-4a_jammy_current_6.1.63_xfce_desktop.img.xz"
url = "https://mirror.yandex.ru/mirrors/armbian/archive/rockpi-4a/archive/$xzimage"
mount_point="/mnt/tmp"
tmpdir="tmp"
output="output"

origin="Rock64"
target="beikeyun"

func_umount() {
	umount $mount_point
}

func_mount() {
	local img=$1
	[ ! -f "$img" ] && echo "img file not found!" && return 1
	mkdir -p $mount_point
	start=$(sfdisk -J $img | jq .partitiontable.partitions[0].start)
	offset=$((start * 512))
	mount -o loop,offset=$offset $1 $mount_point
}

func_modify() {
	local dtb=$1
	local dtbdir=$2

	[ ! -f "$dtbdir/$dtb" ] && echo "$dtbdir/$dtb not found!" && return 1
	# patch /boot
	echo "patch /boot"
	echo "copy $dtbdir/* to $mount_point/boot/dtb/rockchip/"
	cp -rf $dtbdir/* $mount_point/boot/dtb/rockchip/
	chmod +x $mount_point/boot/dtb/rockchip/*beikeyun*
	echo "modify /boot/armbianEnv.txt"
	sed -i '/^verbosity/cverbosity=7' $mount_point/boot/armbianEnv.txt
	if [ -z "`grep fdtfile $mount_point/boot/armbianEnv.txt`" ]; then
		echo "fdtfile=rockchip/$dtb" >> $mount_point/boot/armbianEnv.txt
	fi
	echo "content:"
	cat $mount_point/boot/armbianEnv.txt
	echo "build scr"
	mkimage -C none -T script -d $mount_point/boot/boot.cmd $mount_point/boot/boot.scr

	# patch rootfs
	echo "patch rootfs"
	sed -i 's#http://ports.ubuntu.com#https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports#' $mount_point/etc/apt/sources.list
	sed -i 's#http://httpredir.debian.org#https://mirrors.tuna.tsinghua.edu.cn#' $mount_point/etc/apt/sources.list
	sed -i 's#http://security.debian.org#https://mirrors.tuna.tsinghua.edu.cn/debian-security#' $mount_point/etc/apt/sources.list
	sed -i 's#http://apt.armbian.com#https://mirrors.tuna.tsinghua.edu.cn/armbian#' $mount_point/etc/apt/sources.list.d/armbian.list

	sed -i 's/ENABLED=true/#ENABLED=true/' $mount_point/etc/default/armbian-zram-config
	sed -i 's/ENABLED=true/#ENABLED=true/' $mount_point/etc/default/armbian-ramlog
	#rm -f $mount_point/etc/systemd/system/getty.target.wants/serial-getty\@ttyS2.service
	ln -sf /usr/share/zoneinfo/Asia/Shanghai $mount_point/etc/localtime
	sync
}

func_repack() {
	mkdir input;
	cd input;
	wget url;
	echo "Extract xz...."
	[ ! -f "$xzimage" ] && echo "xzimage not found!" && return 1
	xz -dk $xzimage
	mkdir ../output
	mv *.img ../output/
	cd ../output
	imgfile="$(ls *.img)"
	echo `pwd`
	echo $imgfile
	
	local btld_home=${BOOTLOADER_IMG%/*}
	
	#copy from https://github.com/robinZhao/openwrt_packit/blob/master/public_funcs
	if [ -f "${btld_home}/idbloader.img" ] && [ -f "${btld_home}/u-boot.itb" ];then
			echo "dd if=${btld_home}/idbloader.img of=${imgfile} conv=fsync,notrunc bs=512 seek=64"
			dd if=${btld_home}/idbloader.img of=${imgfile} conv=fsync,notrunc bs=512 seek=64
			echo "dd if=${btld_home}/u-boot.itb of=${imgfile} conv=fsync,notrunc bs=512 seek=16384"
			dd if=${btld_home}/u-boot.itb of=${imgfile} conv=fsync,notrunc bs=512 seek=16384
		else
			echo "dd if=${BOOTLOADER_IMG} of=${TGT_DEV} conv=fsync,notrunc bs=512 skip=64 seek=64"
			dd if=${BOOTLOADER_IMG} of=${TGT_DEV} conv=fsync,notrunc bs=512 skip=64 seek=64
		fi
	echo "origin image file: $imgfile"
	echo "dtb file name: $dtb"
	echo "dtb dir: $dtbdir" 
	func_mount $imgfile && func_modify $dtb $dtbdir  && func_umount

	imgname_new=`basename $imgfile | sed "s/${origin}/${target}/"`
	echo "new image file: $imgname_new"
	mv ${output}/$imgfile ${output}/${imgname_new}
	xz -f -T 10 -v ${output}/${imgname_new}
}

case "$1" in
umount)
	func_umount
	;;
mount)
	func_mount "$2"
	;;
modify)
	func_mount "$2" && func_modify "$3" "$4" && func_umount
	;;
repack)
	func_repack "$2" "$3" "$4" "$5"
	;;
*)
	echo "Usage: $0 { mount | umount [img] | modify [img] [dtb] | release [7zpkg] [dtb] }"
	exit 1
	;;
esac