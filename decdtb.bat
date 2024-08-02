set dtbfile=%1
scp %dtbfile%.dtb root@192.168.20.190:/opt/dtb/%dtbfile%.dtb
ssh -t root@192.168.20.190 "cd /opt/dtb;  dtc -I dtb -O dts -o %dtbfile%.dts %dtbfile%.dtb"
scp root@192.168.20.190:/opt/dtb/%dtbfile%.dts ./
echo ok