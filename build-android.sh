export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar

wget 'https://storage.googleapis.com/git-repo-downloads/repo' -P /tmp/
sudo cp /tmp/repo /usr/local/bin/repo
sudo chmod +x /usr/local/bin/repo

mkdir rockpi4-android7
cd rockpi4-android7
git config --global user.email "zhaoruibin@aliyun.com"
git config --global user.name "zhaoruibin"
repo init -u https://github.com/radxa/manifests -b rk3399-all-7.1 -m rk3399_n_all_release.xml
repo sync -d --no-tags -j4

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


ln -s RKTools/linux/Linux_Pack_Firmware/rockdev/ rockdev
./mkimage.sh

cd rockdev
ln -s Image-rk3399_all Image
./mkupdate.sh
./android-gpt.sh

