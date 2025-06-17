#初始化juicefs
juicefs format     \
--storage minio    \
--bucket http://192.168.100.11:9000/juicefs     \
--access-key root     \
--secret-key 12345678     \
redis://:123456@192.168.100.11:6379/0    \
myjfs

#挂载
## -d 后台运行  --update-fstab 更新开机自动挂载
juicefs mount -d --update-fstab redis://:123456@192.168.100.11:6379/0 /mnt/myjfs
