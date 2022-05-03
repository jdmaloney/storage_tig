#!/bin/bash

tfile=$(mktemp /tmp/nfs.XXXXX)

nfs_clients=$(showmount -a | tail -n +2 | wc -l)
nfsstat -snl > ${tfile}
nfs_v3=$(cat ${tfile} | grep "nfs v3 server" | awk '{print $4" "$5}' | sed 's/:\ /=/g' | xargs | sed 's/\ /,/g')
nfs_v4=$(cat ${tfile} | grep "nfs v4 servop" | awk '{print $4" "$5}' | sed 's/:\ /=/g' | xargs | sed 's/\ /,/g')
rm -rf ${tfile}


echo nfs_client_stats client_count=${nfs_clients}
if [ -n "${nfs_v3}" ]; then
	echo nfs_perf_stats,nfsvers=3 ${nfs_v3}
fi
if [ -n "${nfs_v4}" ]; then
	echo nfs_perf_stats,nfsvers=4 ${nfs_v4}
fi
