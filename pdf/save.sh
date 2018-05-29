#!/bin/bash

TimeBefore=$(date +%s)

green='\e[1;32m'
red='\e[1;31m'
default='\e[0;m'

while getopts ":r:u:p:f:d:h" OPT; do
case $OPT in
          r) remote=${OPTARG};;
          u) user=${OPTARG};;
	  p) password=${OPTARG};;
          f) file=${OPTARG};;
          d) destination=${OPTARG};;
          h) help="True";;
          *) help="True";;
esac
done

IsPythonScpInstalled()
{
	packageScp=$(dpkg -l | grep scp-python)
	if [ "$packageScp-unset" == "" ]
	#Check if the packageScp variable is set
	then
	echo "This script must be used on a server with the 'scp-python' package"
	echo "Run 'apt-get install scp-python' and launch this script again !"
	exit 1
	else
	echo -e "[${green}+${default}] Scp-python is installed."
	fi
}

IsSSHPassPresent()
{
        package=$(dpkg -l | grep sshpass)
        if [ "$package" == "" ]
        then
        echo "This script must be used on a server with the 'sshpass' package"
        echo "Run 'apt-get install sshpass' and launch this script again !"
        exit 1
        else
	echo -e "[${green}+${default}] Sshpass is installed."
	fi
}

IsRemoteHostAlive()
{
	lost=$(ping -c 3 $remote | sed -n 7p | cut -d " " -f6)
	if [ "$lost" == "0%"  ]
	then
		echo -e "[${green}+${default}] Remote host is alive."
	elif [ "$alive" == "66%" ]
	then
		echo "[${green}+${default}] Remote host seems alive."
	else
		echo -e "[${red}-${default}] Remote host seems down."
		exit 1
	fi
}

IsLocalDestinationExist()
{
	if [ -d "$destination" ]
	then
		echo -e "[${green}+${default}] Local destination folder exist."
	else
		echo -e "[${red}-${default}] Local destination folder does not exist."
		exit 1
	fi
}

IsRemoteFolderExist()
{
	FolderExist=$(sshpass -p $password ssh $user@$remote "if [ -d $file ]; then echo 'True';  exit; fi")
	FileExist=$(sshpass -p $password ssh $user@$remote "if [ -f $file ]; then echo 'True';  exit; fi")

	if [ "$FolderExist" == "True" ]
	then
		echo -e "[${green}+${default}] Remote folder exist."
	elif [ "$FileExist" == "True" ]
	then
		echo -e "[${green}+${default}] Remote file exist."
	else
		echo -e "[${red}-${default}] Remote destination does not exist."
		exit 1
	fi
}

Help()
{
	echo -e "[${red}-${default}] Usage: ./save.sh -r [remote-IP]|[Hostname] -u [user] -p [password] -f [file] -d [dest]"
	echo " "
	echo "	-r [remote-IP]		Ip or hostname of the remote host"
	echo "	-u [user]		Username of the remote account"
	echo "	-p [password]           Password of the remote account"
	echo "	-f [file]		File to copy on the locate host"
	echo "	-d [dest]		Destination folder to the remote content"
	echo ""
}

#Main()

if [ "$help" == "True" -o $# -ne 10 ]
then
        Help
        exit 1
fi

IsPythonScpInstalled
IsSSHPassPresent
IsRemoteHostAlive
IsLocalDestinationExist
IsRemoteFolderExist

LocalBefore=$(find $destination -type f | wc -l)
Count=$(sshpass -p toor ssh $user@$remote "find $file -type f | wc -l")

sshpass -p $password scp -r $user@$remote:$file $destination

LocalAfter=$(find $destination -type f | wc -l)
FinalCount=$(($LocalAfter - $LocalBefore))
Percent=$(($FinalCount * 100 / $Count))
echo -e "[${green}+${default}] $Percent% of the remote files have been saved."

if [ $Percent != "100" ]
then
	echo -e "[${red}-${default}] Somes files have been lost during the save."
	echo -e "[${red}-${default}] Check if the local destination does not contain files with the same name than the remote one."
fi

End=$(date +%s)
Elapsed=$(( $End - $TimeBefore ))
echo $Elapsed
