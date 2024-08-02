set dtbfile=%1
scp %dtbfile%.dts root@192.168.20.190:/opt/linux-rockchip-6.1/arch/arm64/boot/dts/rockchip/%dtbfile%.dts
ssh -t root@192.168.20.190 "cd /opt/linux-rockchip-6.1/;  source /etc/profile; make CROSS_COMPILE=aarch64-none-linux-gnu- ARCH=arm64 rockchip/%dtbfile%.dtb"
scp root@192.168.20.190:/opt/linux-rockchip-6.1/arch/arm64/boot/dts/rockchip/%dtbfile%.dtb ./rk3399-tpm312.dtb
echo ok