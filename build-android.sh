wget 'https://storage.googleapis.com/git-repo-downloads/repo' -P /tmp/
sudo cp /tmp/repo /usr/local/bin/repo
sudo chmod +x /usr/local/bin/repo

sudo dpkg --add-architecture i386
sudo apt-get update
apt-get install libncurses5:i386 
apt-get install libncurses5-dev  libncurses5
apt-get remove libfdt-dev

apt-get update -y && apt-get install -y openjdk-8-jdk python git-core gnupg flex bison gperf build-essential \
          zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 \
          x11proto-core-dev libx11-dev lib32z-dev ccache \
          libgl1-mesa-dev libxml2-utils xsltproc unzip mtools u-boot-tools \
          htop iotop sysstat iftop pigz bc device-tree-compiler lunzip \
          dosfstools vim-common parted udev

export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar

mkdir rockpi4-android7
cd rockpi4-android7
repo init -u https://github.com/radxa/manifests -b rk3399-all-7.1 -m rk3399_n_all_release.xml
repo sync -d --no-tags -j4

cd u-boot
./make.sh rock-pi-4b-rk3399
cd ..

cd kernel
make rockchip_defconfig
make rk3399-rockpi-4b-hdmi.img -j$(nproc)
cd ..

source build/envsetup.sh
lunch rk3399_all-userdebug
make -j$(nproc)


ln -s RKTools/linux/Linux_Pack_Firmware/rockdev/ rockdev
./mkimage.sh

cd rockdev
ln -s Image-rk3399_all Image
./mkupdate.sh
./android-gpt.sh

