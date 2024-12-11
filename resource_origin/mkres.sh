dtbfile=${1}
#scp ${dtbfile}.dts root@192.168.20.190:/opt/kernel-rk3399-box-7.1/arch/arm64/boot/dts/rockchip/${dtbfile}.dts
#ssh -t root@192.168.20.190 "cd /opt/kernel-rk3399-box-7.1/;  source /etc/profile; make CROSS_COMPILE=aarch64-none-linux-gnu- ARCH=arm64 rockchip/${dtbfile}.dtb"
#ssh -t root@192.168.20.190 "rm -rf /opt/rkbin/tools/resource.img; cp /opt/kernel-rk3399-box-7.1/arch/arm64/boot/dts/rockchip/${dtbfile}.dtb /opt/rkbin/tools/out/rk-kernel.dtb;"
scp ${dtbfile} root@192.168.20.190:/opt/rkbin/tools/out/rk-kernel.dtb;
scp out/*.bmp root@192.168.20.190:/opt/rkbin/tools/out/
ssh -t root@192.168.20.190 "cd /opt/rkbin/tools/out; /opt/rkbin/tools/resource_tool --pack --image=resource.img  logo.bmp  logo_kernel.bmp rk-kernel.dtb"
scp root@192.168.20.190:/opt/rkbin/tools/out/resource.img ./resource.img
echo ok