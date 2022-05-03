#!/bin/bash

tfile=$(mktemp /tmp/smb.XXXXXX)

sudo smbstatus > ${tfile}

unique_users=$(cat ${tfile} |  awk 'NR==1' RS="\n\n" | tail -n +5 | awk '{print $2}' | sort -u | wc -l)
unique_shares=$(cat ${tfile} |  awk 'NR==2' RS="\n\n" | tail -n +3 | awk '{print $1}' | sort -u | wc -l)
files_locked=$(cat ${tfile} |  awk 'NR==3' RS="\n\n" | tail -n +4 | wc -l)

rm -rf ${tfile}
echo smb_stats unique_users=${unique_users},unique_share=${unique_shares},files_locked=${files_locked}
