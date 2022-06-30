#!/bin/bash

# set default parameter
numberOfProblem=30
solvingTime=150
remainingTime=150
waitingTime=5
problemFile=
problemGenerator=

# parse options
while getopts 'n:l:w:c:f:' opt ;do
	case $opt in
		n) numberOfProblem=$OPTARG
			;;
		l) solvingTime=$OPTARG
			;;
		w) waitingTime=$OPTARG
			;;
		f) problemFile=$OPTARG
			;;
		c) problemGenerator=$OPTARG
			;;
		?) echo "Usage: option are -n or -l or -w."
		   exit
			;;
	esac
done

shift $(( $OPTIND - 1 ))

# check usage error
if [ -n "$problemFile" -a -n "$problemGenerator" ]; then
	echo "Usage: use just one option with -f or -c"
	exit
fi

# make temp file
temp=$(mktemp)

# finalize
function finalize {
	# print answer
	echo -e "\rvvvvvvvvvvvvvv answer vvvvvvvvvvvvvvvvv"
	cat $temp | xargs -I@ printf "%4d = 0x%02X\n" @ @ | nl

	# print time lapsed
	timeLapsed=$(( $solvingTime - $remainingTime ))
	echo "Result: time Lapsed = $timeLapsed second."

	# delete temp file
	rm $temp
}

trap finalize EXIT

# ready
for i in $(seq $waitingTime -1 1);do
	echo -n -e "\rready $i  "
	sleep 1
done

# print problem
echo -e "\rvvvvvvvvvvvvvv problem vvvvvvvvvvvvvvvvv"
shuf -e {0..255} | head -n $numberOfProblem >> $temp
cat $temp | xargs -I@ printf "%4d = \n" @ | nl
for i in $(seq $solvingTime -1 1);do
	echo -n -e "\r$i  "
	remainingTime=$i
	sleep 1
done

