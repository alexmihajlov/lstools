#!/bin/sh -e


# DEBUG=1
DEBUG=0



echo_debug() 
{
    if [ "$1" = 1 ]; then
        echo "DEBUG: $2"
    fi
}


yesno() {
    read -p "$1 ([y]/n)" verbose
    if test -z "$verbose" || test "$verbose" = "y"; then
        return 1
    else 
        return 2
    fi
}


noyes() {
    read -p "$1 (y/[n])" verbose
    if test -z "$verbose" || test "$verbose" = "n"; then
        return 2
    else 
        return 1
    fi
}


_rsync_bin1="/usr/local/bin/rsync"
_rsync_bin2="/usr/bin/rsync"
_rsync_path_to_jail="/home/jails/mysql"

_rsync_exclude_install="--exclude=/usr/local/mysql/"
_rsync_exclude_misc="--exclude=/var/ \
--exclude=/proc/ \
--exclude=/tmp/ \
--exclude=/dev/ \
--exclude=/usr/home/ \
--exclude=/home/ \
--exclude=/root/ \
--exclude=/etc/crontab \
--exclude=/usr/local/share/doc/ \
--exclude=/alex/ \
--exclude=/etc/rc.conf \
--exclude=/etc/hosts \
--exclude=/usr/local/etc/nss_ldap.conf \
--exclude=/etc/ssh/sshd_config \
--exclude=/usr/local/etc/zabbix/zabbix_agentd.conf \
--exclude=/usr/local/zabbix_templates/etc/ \

\
"


rsync_args="-avc"
rsync_password_file="/usr/local/etc/rsync.secret"
rsync_url="rsync://updater@192.168.101.12/mysql"


# if not help do some checking
if [ "$1" != "help" ]; then
	# rsync path to binary
	if [ -f "${_rsync_bin1}" ]; then
		rsync_bin="$_rsync_bin1"
	elif [ -f "${_rsync_bin2}" ]; then
		rsync_bin="${_rsync_bin2}"
	else
		echo "rsync not found"
		exit 1
	fi


	echo_debug $DEBUG "rsync found at ${rsync_bin}"


	# check for rsync_password_file presense
	if [ ! -f $rsync_password_file ]; then
		echo "rsync password file not found at ${rsync_password_file}"
		exit 1
	fi


	# set new rsync_path_to_jail
	if [ ! -z "$2" ]; then
		rsync_path_to_jail=$2
	else
		rsync_path_to_jail=$_rsync_path_to_jail
	fi

	echo_debug $DEBUG "path to jail set to ${rsync_path_to_jail}"

	# directory creation
	if [ ! -d "$rsync_path_to_jail" ]; then
		echo "Path to jail not found ${rsync_path_to_jail}"
	 
		read -p "Do you want to create it? ([y]/n)" verbose
		if test -z "$verbose" || test "$verbose" = "y"; then
		    mkdir -p ${rsync_path_to_jail}

			if [ "$?" -ne "0" ]; then
			    exit 1
			fi
		else 
		    exit 1
		fi
	fi


	# path to var/log for cleanlog mode
	rsync_path_to_jail_var_log="${rsync_path_to_jail}/var/log"


	# --del parameter
	if [ "$3" = "--del" ]; then
		rsync_args="${rsync_args} --del"
	fi
fi



case $1 in
    installfull)
        echo "========================================="
        echo "== You are choose [installfull] option =="
        echo "========================================="
        echo "In this mode !!ALL SYSTEM!! will be synced from source"
        echo
        echo "It's mean that [/var /tmp /home] directory will be replaced"
        echo


        read -p "Do you want to continue? (y/[n])" verbose
        if test -z "$verbose" || test "$verbose" = "n"; then
            exit 0
        else 
            rsync_exclude=$_rsync_exclude_install;
            echo
            echo
        fi


        break
        ;;

    update)
        echo_debug $DEBUG "Update mode"
        rsync_exclude="${_rsync_exclude_install} ${_rsync_exclude_misc}";
        break
        ;;


    cleanlog)
        echo_debug $DEBUG "Clean log mode"

		cmd_run="find ${rsync_path_to_jail_var_log} -type f -delete"
		echo
		echo 
		echo "Run command will be"
		echo "${cmd_run}"
		echo
		read -p "Do you want to run it? ([y]/n)" verbose
		if test -z "$verbose" || test "$verbose" = "y"; then
			eval ${cmd_run}
		fi

        exit 0
        ;;

    *)
        echo "============================"
        echo "==  LS Tools Rsync Jail  =="  
		echo "============================"
		echo
		echo "Usage:"
		echo "${0} [installfull | update]"
		echo "${0} [installfull | update] [path_to_jail]"
		echo "${0} [installfull | update] [path_to_jail] [--del]"
		echo
		echo "Extra futures:"
		echo "Clean jail var/log directory from files"
		echo "${0} cleanlog"
		echo
		echo "Default jail path: ${_rsync_path_to_jail}"
		echo "Rsync password file: ${rsync_password_file}"
		echo


        exit 0
        ;;
esac


echo_debug $DEBUG "Exclude options: ${rsync_exclude}"




cmd_run="${rsync_bin} ${rsync_args} --password-file=${rsync_password_file} ${rsync_url} ${rsync_path_to_jail} ${rsync_exclude}"
echo
echo 
echo "Run command will be"
echo "${cmd_run}"
echo
read -p "Do you want to run it? ([y]/n)" verbose
if test -z "$verbose" || test "$verbose" = "y"; then
    eval ${cmd_run}
fi



