#!/bin/bash

tmp="./tmp"
out="./out"
device="phicomm-n1" # don't modify it
image_name='$device-k$kernel-openwrt-firmware'

tag() {
    echo -e " [ \033[1;32m$1\033[0m ]"
}

process() {
    echo -e " [ \033[1;32m$kernel\033[0m ] \033[32m$1\033[0m $2"
}

error() {
    echo -e " [ \033[1;31mError\033[0m ] $1"
}

loop_setup() {
    loop=$(losetup -P -f --show "$1")
    [ $loop ] || {
        error "you used a lower version linux, 
 please update the util-linux package or upgrade your system." && exit 1
    }
}

cleanup() {
    local mounts=$(grep "$tmp/.*/mount" /proc/mounts | grep -oE "(loop[0-9]|loop[0-9][0-9])" | sort | uniq)

    for x in $mounts; do
        umount -f /dev/${x}* 2>/dev/null
        losetup -d "/dev/$x" 2>/dev/null
    done
    rm -rf $tmp
}

extract_openwrt() {
    local firmware="./openwrt/$firmware"
    local suffix="${firmware##*.}"
    mount="$tmp/$kernel/mount"
    root="$tmp/$kernel/root"

    mkdir -p $mount $root
    while true; do
        case "$suffix" in
        tar)
            tar -xf $firmware -C $root
            break
            ;;
        gz)
            if (ls $firmware | grep -q ".tar.gz$"); then
                tar -xzf $firmware -C $root
                break
            else
                tmp_firmware="$tmp/${firmware##*/}"
                tmp_firmware=${tmp_firmware%.*}
                gzip -d $firmware -c > $tmp_firmware
                firmware=$tmp_firmware
                suffix=${firmware##*.}
            fi
            ;;
        img)
            loop_setup $firmware
            if ! (mount -r ${loop}p2 $mount); then
                error "mount image faild!" && exit 1
            fi
            cp -r $mount/* $root && sync
            umount -f $mount
            losetup -d $loop
            break
            ;;
        ext4)
            if ! (mount -r -o loop $firmware $mount); then
                error "mount image faild!" && exit 1
            fi
            cp -r $mount/* $root && sync
            umount -f $mount
            break
            ;;
        *)
            error "unsupported firmware format, this script only support 
 rootfs.tar[.gz], ext4-factory.img[.gz], root.ext4[.gz] six format." && exit 1
            ;;
        esac
    done

    rm -rf $root/lib/modules/*/
}

extract_armbian() {
    kernel_dir="./armbian/$device/kernel/$kernel"
    root_dir="./armbian/$device/root"
    boot="$tmp/$kernel/boot"

    mkdir -p $boot
    tar -xzf "$kernel_dir/../../boot-common.tar.gz" -C $boot
    tar -xzf "$kernel_dir/../../firmware.tar.gz" -C $root
    tar -xzf "$kernel_dir/kernel.tar.gz" -C $boot
    tar -xzf "$kernel_dir/modules.tar.gz" -C $root
    [ `ls $root_dir | wc -w` != 0 ] && cp -r $root_dir/* $root
}

utils() {
    cd $root
    # add other operations here 👇

    echo 'pwm_meson' > etc/modules.d/pwm-meson
    sed -i '/kmodloader/i\\tulimit -n 51200\n' etc/init.d/boot
    sed -i 's/ttyAMA0/ttyAML0/' etc/inittab
    sed -i 's/ttyS0/tty0/' etc/inittab

    mkdir -p boot run opt
    chown -R 0:0 ./

    cd $work
}

make_image() {
    image="$out/$kernel/$(date "+%y.%m.%d-%H%M%S")-$(eval "echo $image_name").img"

    [ -d "$out/$kernel" ] || mkdir -p "$out/$kernel"
    fallocate -l $((16 + 128 + rootsize))M $image
}

format_image() {
    parted -s $image mklabel msdos
    parted -s $image mkpart primary ext4 17M 151M
    parted -s $image mkpart primary ext4 151M 100%

    loop_setup $image
    mkfs.vfat -n "BOOT" ${loop}p1 >/dev/null 2>&1
    mke2fs -F -q -t ext4 -L "ROOTFS" -m 0 ${loop}p2 >/dev/null 2>&1
}

copy2image() {
    local bootfs="$mount/bootfs"
    local rootfs="$mount/rootfs"

    mkdir -p $bootfs $rootfs
    if ! (mount ${loop}p1 $bootfs); then
        error "mount image faild!" && exit 1
    fi
    if ! (mount ${loop}p2 $rootfs); then
        error "mount image faild!" && exit 1
    fi

    cp -r $boot/* $bootfs
    cp -r $root/* $rootfs
    sync

    umount -f $bootfs $rootfs
    losetup -d $loop
}

get_firmwares() {
    firmwares=()
    i=0
    IFS_old=$IFS
    IFS=$'\n'

    [ -d "./openwrt" ] && {
        for x in $(ls ./openwrt); do
            firmwares[i++]=$x
        done
    }
    IFS=$IFS_old
}

get_kernels() {
    kernels=()
    i=0
    IFS_old=$IFS
    IFS=$'\n'

    local kernel_root="./armbian/$device/kernel"
    [ -d $kernel_root ] && {
        cd $kernel_root
        for x in $(ls ./); do
            [[ -f "$x/kernel.tar.gz" && -f "$x/modules.tar.gz" ]] && kernels[i++]=$x
        done
        cd $work
    }
    IFS=$IFS_old
}

show_kernels() {
    if ((${#kernels[*]} == 0)); then
        error "no file in kernel folder!" && exit 1
    else
        show_list "${kernels[*]}"
    fi
}

show_list() {
    i=0
    for x in $1; do
        echo " ($((++i))) $x"
    done
}

choose_firmware() {
    echo " firmware: "
    show_list "${firmwares[*]}"
    choose_files ${#firmwares[*]} "firmware"
    firmware=${firmwares[opt]}
    tag $firmware && echo 
}

choose_kernel() {
    echo " kernel: "
    show_kernels
    choose_files ${#kernels[*]} "kernel"
    kernel=${kernels[opt]}
    tag $kernel && echo 
}

choose_files() {
    local len=$1
    local type=$2
    opt=

    if ((len == 1)); then
        opt=0
    else
        i=0
        while true; do
            echo && read -p " select the $type above and press Enter to select the first one: " opt
            [ $opt ] || opt=1
            if ((opt >= 1 && opt <= len)) 2>/dev/null; then
                let opt--
                break
            else
                ((i++ >= 2)) && exit 1
                error "wrong type, try again!"
                sleep 1s
            fi
        done
    fi
}

set_rootsize() {
    i=0
    rootsize=

    while true; do
        read -p " input the the rootfs partition size, defaults to 512m, do not less than 256m
 if you don't know what this means, press Enter to keep default: " rootsize
        [ $rootsize ] || rootsize=512
        if ((rootsize >= 256)) 2>/dev/null; then
            tag $rootsize && echo 
            break
        else
            ((i++ >= 2)) && exit 1
            error "wrong type, try again!\n"
            sleep 1s
        fi
    done
}

usage() {
    cat <<EOF

Usage:
  make [option]

Options:
  -c, --clean           clean up the output and temporary directories
  -d, --default         use the default configuration, which means that use the first firmware in the "openwrt" directory, the kernel version is "all", and the rootfs partition size is 512m
  -k=VERSION            set the kernel version, which must be in the "kernel" directory, set to "all" will build all the kernel version
  --kernel              show all kernel version in "kernel" directory
  -s, --size=SIZE       set the rootfs partition size, do not less than 256m
  -h, --help            display this help

EOF
}

##
if ((UID != 0)); then
    error "please run this script as root!" && exit 1
fi

work=$(pwd)
echo " Welcome to phicomm-n1 openwrt image tools!"

cleanup
get_firmwares
get_kernels

while [ "$1" ]; do
    case "$1" in
    -h | --help)
        usage && exit
        ;;
    -c | --clean)
        cleanup
        rm -rf $out
        echo -e " \033[32mclean up\033[0m 👌"
        exit
        ;;
    -d | --default)
        : ${rootsize:=512}
        : ${firmware:="${firmwares[0]}"}
        : ${kernel:="all"}
        ;;
    -k)
        kernel=$2
        kernel_dir="./armbian/$device/kernel/$kernel"
        if [ $kernel = "all" ] 2>/dev/null || [ -f "$kernel_dir/kernel.tar.gz" ]; then
            shift
        else
            error "invalid kernel \"$2\" 🙄" && exit 1
        fi
        ;;
    --kernel)
        show_kernels && exit
        ;;
    -s | --size)
        rootsize=$2
        if ((rootsize >= 256)) 2>/dev/null; then
            shift
        else
            error "invalid size \"$2\" 🙄" && exit 1
        fi
        ;;
    *)
        error "invalid option \"$1\" 🙄" && exit 1
        ;;
    esac
    shift
done

if ((${#firmwares[*]} == 0)); then
    error "no file in openwrt folder!" && exit 1
fi
if ((${#kernels[*]} == 0)); then
    error "no file in kernel folder!" && exit 1
fi

[ $firmware ] && echo " firmware   ==>   $firmware"
[ $kernel ] && echo " kernel     ==>   $kernel"
[ $rootsize ] && echo " rootsize   ==>   $rootsize"
[ $firmware ] || [ $kernel ] || [ $rootsize ] && echo 

[ $firmware ] || choose_firmware
[ $kernel ] || choose_kernel
[ $rootsize ] || set_rootsize

[ $kernel != "all" ] && kernels=("$kernel")
for x in ${kernels[*]}; do
{
    kernel=$x
    process "extract openwrt files "
    extract_openwrt
    process "extract armbian files "
    extract_armbian
    utils
    process "make openwrt image "
    make_image
    process "format openwrt image "
    format_image
    process "copy files to image "
    copy2image
    process "generate success" 😘
} &
done

wait

cleanup
chmod -R 777 $out
