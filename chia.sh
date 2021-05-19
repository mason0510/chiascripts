info "formating raid 0 ..."
echo "sudo mdadm -C /dev/md0 -l 0 -n $N --run $MD"
export MDX=md01
sudo mdadm -C /dev/$MDX -l 0 -n 10 --run /dev/sd{}
sudo parted -s -- /dev/$MDX mktable gpt
sudo parted -s -- /dev/$MDX mkpart primary 31744s 100%
sudo mkfs.ext4 -F /dev/$MDX
info "formating md0 over."
sudo mdadm -Ds
sudo sh -c "mdadm -Ds >> /etc/mdadm/mdadm.conf"
sudo update-initramfs -u
sleep 1

mkdir -p $1/data/$MDX
sudo mount /dev/$MDX $1/data/$MDX
info "mount /dev/md0 to $1/data/md0"
sudo chown nobody:nogroup $1/data/$MDX
sudo chmod 777 $1/data/$MDX
sleep 1

grep "/dev/$MDX" /etc/fstab
[ ! $? -eq 0 ] && sudo sh -c "echo \"/dev/$MDX $1/data/md0   ext4    defaults     0 0\" >> /etc/fstab"

info "exports nfs md0"
grep "$1/data/md0" /etc/exports
[ ! $? -eq 0 ] && sudo sh -c "echo \"$1/data/md0 *(rw,sync,no_root_squash,no_subtree_check)\" >> /etc/exports"
