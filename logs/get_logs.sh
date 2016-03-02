#!/bin/bash -e
# bash -e should quit on first error, to prevent unexpected state
# This script will run on any Linux
# This script will fail on many Solaris, AIX, or UNIX systems w/o bash installed
# 
# $1 arguement can be an alternate e-mail to send to

PERSON="cgseller@gmail.com"


if [[ $1 =~ .*-h.* ]]
then
   printf "\n USAGE: \n\n\t $0 [email@address.tld]\n"
   printf "\n\tdefault address = $PERSON  if omitted\n\n"
   exit;
fi

if [[ $1 =~ "\@" ]]
then
   PERSON=$1
   echo "Sending output to $PERSON..."
fi

# find all possible files matching the criteria below
# ideally there is no more than 1 file but just in case...
SULOG=$(find -L /var -name su.log 2>/dev/null)
SUDOLOG=$(find -L /var -name sudo.log 2>/dev/null)
ROOTHIST=$(find -L ~root/*history* 2>/dev/null)

TODATE=$(date +%m%d%y.%H%M)
HOSTNAME=$(hostname)

#====================================================


for items in SULOG SUDOLOG ROOTHIST
do
    echo " >> Gathering $items contents...."
    # ${!items} will expand the value of items as a variable
    for file in ${!items}
    do
        TEMPFILE=$(basename $file)
        echo "  >> Searching for $file to copy to $TEMPFILE.$TODATE..."
        cat $file | tee -a /var/log/$TEMPFILE.$TODATE 2>&1 > /dev/null
        if [[ ! $file =~ "history" ]]
        then
            > $file   # zero out file for new month
        fi
    done
    echo " >> Sending gathered content of $items to $PERSON..."
    cat /var/log/$TEMPFILE.$TODATE | mailx -s "$items info from $HOSTNAME" $PERSON

    # be a good linuxzen and clean up garbage older than 30days matching our
    # pattern
    find /var/log/ -name $TEMPFILE.* -mtime +366 -print0 | xargs -r -0 rm | logger
done
