load mmc 0:3 ${kernel_addr_r} /vmlinux-{{ last_kernel_version }}
load mmc 0:4 ${fdt_addr_r} /usr/lib/linux-image-{{ last_kernel_version }}/starfive/jh7110-starfive-visionfive-2-lite.dtb
load mmc 0:3 ${ramdisk_addr_r} /initrd.img-{{ last_kernel_version }}
setenv bootargs 'root=/dev/mmcblk0p4'
booti $kernel_addr_r $ramdisk_addr_r:$filesize $fdt_addr_r
