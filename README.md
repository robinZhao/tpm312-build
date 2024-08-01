"# tpm312-dts-modify" 

编辑rk3399-tpm312 dts文件
resolver中的java代码是把反编译后的dts进行排序的,便于不同的dts文件进行比较
rk-kernel-android.dtb为原始的dtb
rk-kernel-android.dts为dtb反编译的dts

rk3399-tpm312.dts为最终修改的dts
rk3399-tpm312.dts为最终编译的dtb
此文件测试在ophub的6.10内核固件中运行正常，hdmi屏幕正常显示

boot.cmd为测试期间使用的boot.cmd,需要编译成boot.scr替换/boot下的原有文件,
此cmd自动从tftp加载dtb,方便测试修改
使用时需要在armbianEnv.txt中添加环境变量
```
serverip=192.168.10.31
ipaddr=192.168.10.44
```
rk3399-tpm312-bsp.dts用于rockchip内核5.10以内的版本,测试过rock-4se_ubuntu_focal_cli_b38和rock64的armbian5.9可正常运行，屏幕显示正常
