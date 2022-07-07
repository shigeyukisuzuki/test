#!/bin/bash

# set default parameter
numberOfProblem=30
solvingTime=150
remainingTime=150
waitingTime=5
problemFile=
problemGenerator=
hyphen=false
problemRepeatability=""

# usage description.
usage="Usage: options are -n or -l or -w or -c or -f or -r or -h."

# parse options
while getopts 'n:l:w:c:f:rh' opt ;do
	case $opt in
		n)	numberOfProblem=$OPTARG
			;;
		l)	solvingTime=$OPTARG
			;;
		w)	waitingTime=$OPTARG
			;;
		c)	problemGenerator=$OPTARG
			;;
		f)	problemFile=$OPTARG
			if [ $problemFile == "-" ]; then
		   		problemFile=$(mktemp)
				hyphen=true
				cat /dev/stdin >> $problemFile
			fi
			;;
		r)  problemRepeatability="-r"
			;;
		h)	echo $usage
			exit
			;;
		?)	echo $usage
		  	exit
			;;
	esac
done

shift $(( $OPTIND - 1 ))

# check usage error
if [ -n "$problemFile" -a -n "$problemGenerator" ]; then
	echo "Usage: use just one option with -f or -c."
	exit
fi

# make temp file
temp=$(mktemp)

# finalize
function finalize {
	# print answer
	echo -e "\rvvvvvvvvvvvvvv answer vvvvvvvvvvvvvvvvv"
	if [ -n "$problemFile" ];then
		awk '{print $1, "=", $2}' $temp | column -t | nl
	elif [ -n "$problemGenerator" ]; then
		cat $temp | xargs -I@ printf "%4d = 0x%02X\n" @ @ | nl
	fi

	# print time lapsed
	timeLapsed=$(( $solvingTime - $remainingTime ))
	echo "Result: time Lapsed = $timeLapsed second."

	# delete temp file
	if [ $hyphen == "true" ]; then
		rm $problemFile
	fi
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

if [ -n "$problemFile" ];then
	for problem in $(shuf ${problemRepeatability} -e $(awk '{print $1}' $problemFile) -n $numberOfProblem);do
		awk -v problem=$problem '$1==problem' $problemFile >> $temp
	done
	awk '{print $1, "="}' $temp | column -t | nl
elif [ -n "$problemGenerator" ];then
	shuf ${problemRepeatability} -e {0..255} -n $numberOfProblem >> $temp
	cat $temp | xargs -I@ printf "%4d = \n" @ | nl
fi

for i in $(seq $solvingTime -1 1);do
	echo -n -e "\r$i  "
	remainingTime=$i
	sleep 1
done

