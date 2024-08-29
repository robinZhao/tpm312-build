#使用rockpi4源码编译tpm312的android镜像

mkdir rockpi4-android7
cd rockpi4-android7
git config --global user.email "zhaoruibin@aliyun.com"
git config --global user.name "zhaoruibin"
repo init -u https://github.com/radxa/manifests -b rk3399-all-7.1 -m rk3399_n_all_release.xml
repo sync -d --no-tags -j4

#kernel
cp ../rk3399-tpm312-android7.dts kernel/arch/arm64/boot/dts/rockchip/rk3399-tpm312.dts
echo "CONFIG_RTL8821CU=m">>kernel/arch/arm64/configs/rockchip_defconfig
#增加rtl8821cu的驱动
cd kernel/drivers/net/wireless/rockchip_wlan
git clone https://github.com/axiomware/RTL8821CU_driver_v5.8.1 rtl8821cu
# 修改8821cu makefile
sed 's/CONFIG_PLATFORM_I386_PC = y/CONFIG_PLATFORM_I386_PC = n/' rtl8821cu/Makefile
sed 's/CONFIG_PLATFORM_ARM_RK3188 = n/CONFIG_PLATFORM_ARM_RK3188 = y/' rtl8821cu/Makefile
sed 's/EXTRA_CFLAGS += -DRTW_ENABLE_WIFI_CONTROL_FUNC/d' rtl8821cu/Makefile
sed 's/KSRC := \/home\/android_sdk\/Rockchip\/Rk3188\/kerne/KSRC := \/home\/dcm360\/rockpi\/kernel'  rtl8821cu/Makefile
sed 's/MODULE_NAME := wlan/MODULE_NAME := 8821cu'  rtl8821cu/Makefile

合并wifi.patch

#wifi自启
cp /home/dcm360/rockpi/device/rockchip/rk3399/init.tablet.rc  /home/dcm360/rockpi/device/rockchip/rk3399/rk3399_all/init.tablet.rc
sed -i "/ioprio rt 4/a\    insmod /system/lib/modules/8821cu.ko"  /home/dcm360/rockpi/device/rockchip/rk3399/rk3399_all/init.tablet.rc

#uboot
cp u-boot/configs/rock-pi-4b-rk3399_defconfig u-boot/configs/tpm312-rk3399_defconfig
sed 's/rk3399-evb/rk3399-tpm312/' u-boot/configs/tpm312-rk3399_defconfig
cp rk3399-tpm312.dts /home/dcm360/rockpi/u-boot/arch/arm/dts/
合并uboot.patch

cd u-boot
./make.sh tpm312-rk3399
cd ..

cd kernel
make rockchip_defconfig
make rk3399-tpm312.img -j$(nproc)
cd ..

source build/envsetup.sh
lunch rk3399_all-userdebug
make -j$(nproc)

