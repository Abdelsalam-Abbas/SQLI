#!/bin/bash
lo=1 


while getopts ":t:s:hl" opt; do
  case $opt in
    t)
      echo -e "Target is: $OPTARG" >&2
      target=$OPTARG
      ;;
    \?)
      echo -e "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    h)
	echo "help:-
	     -t  [target] example: "www.site.com/login.php"
	     -s  [string] exmaple: "success""
      exit 1
      ;;
    s)
	echo "String is: $OPTARG" >&2
	login_key=$OPTARG
	;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [[ -z $target || -z $login_key ]] 
then 
	echo "
Required Arguments:
	-t, <url>          Link of the target page. 
	-s, <string>       String to find if success of login.

Try '-h' for more information."
else
	. ./intro.sh
	. ./login_script.sh $target $login_key
fi
#### by Abdelsalam Abbas
### ITI_SA_37
