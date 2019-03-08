#!/bin/bash

# dummy.your-domain.org is a dummy subdomain which musn't be registered (it's used to check if the catch all rule works). Remove it if you're not using a catch all rule
domains=( \
    "your-domain.org" \
    "dummy.your-domain.org" \
    "subdomain.your-domain.org" \
    # Add more subdomains here
)

urls=( \
    "https://dynamicdns.park-your-domain.com/update?domain=your-domain.org&password=<your dyndns password>&host=" \          # base domain
    "https://dynamicdns.park-your-domain.com/update?domain=your-domain.org&password=<your dyndns password>&host=*" \         # catch all
    "https://dynamicdns.park-your-domain.com/update?domain=your-domain.org&password=<your dyndns password>&host=subdomain" \ # subdomain
    # Add more subdomains here
)


logfile="/var/log/dyndns/`date '+%d.%m.%Y'`.log"
timestamp="`date +%H:%M:%S`"


echo deleting old logs...
echo "rm /var/log/dyndns/*.`date --date='-1 month' '+%m.%Y'`.log"
rm /var/log/dyndns/*.`date --date='-1 month' '+%m.%Y'`.log
echo done.
echo 

echo logfile is $logfile
echo timestamp is $timestamp


for i in $(seq 0 $((${#domains[@]} - 1)))
do
    echo ${domains[$i]}
    #echo "request is: " ${urls[$i]}
    ip=$(host ${domains[i]} \
        | grep 'has address' \
        | sed "s/.* has address //g")
    if [ -z "$ip" ] \
        || [ -z "$(curl --head $ip --connect-timeout 5)" ]
    then
        echo -e "\n$timestamp:: updating IP for ${domains[$i]}" >> $logfile
        echo -e "\n$timestamp:: updating IP for ${domains[$i]}"
        curl ${urls[$i]} >> $logfile
        echo  >> $logfile
    else
        echo -e "\n$timestamp:: skipping update of ${domains[$i]} - is accessible." >> $logfile
        echo -e "\n$timestamp:: skipping update of ${domains[$i]} - is accessible."
    fi
done

