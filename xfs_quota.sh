#!/bin/bash

tfile=$(mktemp /tmp/xfs.XXXXXXX)
path=""

sudo /usr/sbin/xfs_quota -x -c 'report' ${path}  > "${tfile}.block"
sudo /usr/sbin/xfs_quota -x -c 'report -i' ${path}  > "${tfile}.inode"

users=($(sed -n '/Group\ quota\ on/q;p' "${tfile}.block" | awk '{print $1}' | tail -n +5 | xargs))
sed -n '/Group\ quota\ on/q;p' "${tfile}.block" | tail -n +5 | awk '{print $1" "$2" "$3" "$4}' > "${tfile}.user_block"
sed -n '/Group\ quota\ on/q;p' "${tfile}.inode" | tail -n +5 | awk '{print $1" "$2" "$3" "$4}' > "${tfile}.user_inode"

for u in ${users[@]}
do
        IFS=" " read -r kb_used kb_soft kb_hard <<< $(awk -v user=$u '$1 == user {print $2" "$3" "$4}' "${tfile}.user_block")
        IFS=" " read -r inode_used inode_soft inode_hard <<< $(awk -v user=$u '$1 == user {print $2" "$3" "$4}' "${tfile}.user_inode")
        echo "xfs_quota,path=${path},user=${u} kb_used=${kb_used},kb_soft=${kb_soft},kb_hard=${kb_hard},inode_used=${inode_used},inode_soft=${inode_soft},inode_hard=${inode_hard}"
done

groups=($(sed -n '/Group\ quota\ on/,$p' "${tfile}.block" | awk '{print $1}' | tail -n +5 | xargs))
sed -n '/Group\ quota\ on/,$p' "${tfile}.block" | tail -n +5 | awk '{print $1" "$2" "$3" "$4}' > "${tfile}.group_block"
sed -n '/Group\ quota\ on/,$p' "${tfile}.inode" | tail -n +5 | awk '{print $1" "$2" "$3" "$4}' > "${tfile}.group_inode"
for g in ${groups[@]}
do
        IFS=" " read -r kb_used kb_soft kb_hard <<< $(awk -v group=$g '$1 == group {print $2" "$3" "$4}' "${tfile}.group_block")
        IFS=" " read -r inode_used inode_soft inode_hard <<< $(awk -v group=$g '$1 == group {print $2" "$3" "$4}' "${tfile}.group_inode")
        echo "xfs_quota,path=${path},group=${g} kb_used=${kb_used},kb_soft=${kb_soft},kb_hard=${kb_hard},inode_used=${inode_used},inode_soft=${inode_soft},inode_hard=${inode_hard}"
done

rm -rf "${tfile}"*
