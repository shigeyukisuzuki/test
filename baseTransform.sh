#!/bin/bash

# make temp file
temp=$(mktemp)

# ready
for i in $(seq 5 -1 1);do
	echo -n -e "\rready $i  "
	sleep 1
done

# print problem
echo -e "\rvvvvvvvvvvvvvv problem vvvvvvvvvvvvvvvvv"
shuf -e {1..255} | head -n 20 >> $temp
cat $temp | xargs -I@ printf "%4d = \n" @ 
for i in $(seq 100 -1 1);do
	echo -n -e "\r$i  "
	sleep 1
done

# print answer
echo -e "\rvvvvvvvvvvvvvv answer vvvvvvvvvvvvvvvvv"
cat $temp | xargs -I@ printf "%4d = 0x%X\n" @ @ 

# delete temp file
rm $temp
