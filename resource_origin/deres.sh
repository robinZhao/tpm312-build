scp ${1} root@192.168.20.190:/opt/rkbin/tools/resource.img
ssh -t root@192.168.20.190 "cd /opt/rkbin/tools/; ./resource_tool --verbose --unpack --image=resource.img"
scp -r root@192.168.20.190:/opt/rkbin/tools/out ./
echo ok
