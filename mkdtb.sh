#!/bin/bash
build_dtb(){
	local linuxdir=$1;
	local dtbfile=$2;
	scp $dtbfile.dts root@192.168.20.190:/opt/$linuxdir/arch/arm64/boot/dts/rockchip/$dtbfile.dts
	ssh -t root@192.168.20.190 "cd /opt/$linuxdir/;  source /etc/profile; make rockchip/$dtbfile.dtb"
	scp root@192.168.20.190:/opt/$linuxdir/arch/arm64/boot/dts/rockchip/$dtbfile.dtb ./$3.dtb
}

build_dtb $1 $2 $3
# ./mkdtb linux-6.6 ophub-tpm312 rk3399-tpm312