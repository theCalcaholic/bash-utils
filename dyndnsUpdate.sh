#!/bin/bash

if [[ " $* " =~ .*(" -h "|" --help ").* ]]
then
    echo "DESCRIPTION:
  Checks for each configured dynDNS domain if it is pointing at the current ip and otherwise calls an http endpoint for updating it."
    echo "USAGE:
  dydnsUpdate.sh
  (Configuration inside the script)"
    exit 0
fi



# dummy.your-domain.org is a dummy subdomain which musn't be registered (it's used to check if the catch all rule works). Remove it if you're not using a catch all rule
domains=( \
    "your-domain.org" \
    "dummy.your-domain.org" \
    "subdomain.your-domain.org" \
    # Add more subdomains here
)

urls=( \
    "https://dynamicdns.park-your-domain.com/update?domain=${domains[0]}&password=<your dyndns password>&host=" \          # base domain
    "https://dynamicdns.park-your-domain.com/update?domain=${domains[0]}&password=<your dyndns password>&host=*" \         # catch all
    "https://dynamicdns.park-your-domain.com/update?domain=${domains[0]}&password=<your dyndns password>&host=subdomain" \ # subdomain
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

my_ip="$(dig @resolver1.opendns.com myip.opendns.com +short)"

for i in $(seq 0 $((${#domains[@]} - 1)))
do
    echo ${domains[$i]}
    ip="$(dig @resolver1.opendns.com "${domains[$i]}" +short)"
    if [[ "$ip" != "$my_ip" ]]
    then
        echo -e "\n$timestamp:: updating IP for ${domains[$i]}" | tee $logfile
        curl ${urls[$i]} | tee $logfile
        echo "" | tee $logfile
    else
        echo -e "\n$timestamp:: skipping update of ${domains[$i]} - ip matches." | tee $logfile
    fi
done

