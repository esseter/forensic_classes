#!/bin/bash
file=$1
IFS="\n"
while read line ; do
	echo '------------------------------------------------- '
	echo ''

	# take the values of the line
	reg_line=$(echo $line | grep "^34")
	timestamp=$(echo $reg_line | awk -F"\t" '{print $10}')
	time_dur=$(echo $reg_line | awk -F"\t" '{print $12}')
	timestamp_sec=$(date -d "$timestamp" +%s)
	
	# 1st ouptput: check overlap and airgap with previous line
	# trick: call the value of $time_end_sec calculated previously and 
	# not updated yet
	# output in the following format: "%M:%S"


	if (("$timestamp_sec" < "$time_end_sec"))
	then
		overlap_sec=$(expr $time_end_sec - $timestamp_sec)
		overlap=$(date -d @$overlap_sec +':%M:%S')
		echo "OVERLAP with previous connection: " $overlap
	else
		overlap_sec=$(expr $timestamp_sec - $time_end_sec)
		overlap=$(date -d @$overlap_sec +':%M:%S')
		echo "AIRGAP with previous connection: " $overlap

	fi

	# get the number of seconds elapsed during the duration of the connection
	time_dur_seconds=$(echo $time_dur | awk -F':' '{print $1 * 60 * 60 + $2 * 60 + $3}')
	
	# We convert start date in seconds, add the duration time and convert back in correct date format for time_end
	time_end_sec=$(expr $timestamp_sec + $time_dur_seconds)
	time_end=$(date -d @$time_end_sec +'%d/%m/%Y %H:%M:%S')

	#2nd Output of our script within the terminal
	echo "START TIME: "  $timestamp
	echo "END TIME: " $time_end
	echo ''

done < $file

