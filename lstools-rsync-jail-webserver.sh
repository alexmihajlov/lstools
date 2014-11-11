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
_rsync_path_to_jail="/home/jails/web"

_rsync_exclude_install="--exclude=/usr/local/www/hosting/"
_rsync_exclude_misc="--exclude=/var/ \
--exclude=/proc/ \
--exclude=/tmp/ \
--exclude=/dev/ \
--exclude=/usr/local/etc/apache22/hosting/ \
--exclude=/usr/local/etc/apache22/hosting.conf \
--exclude=/usr/local/etc/apache22/hosting_internal/ \
--exclude=/usr/local/etc/apache22/hosting_internal.conf \
--exclude=/usr/local/etc/apache22/vhosts/ \
--exclude=/usr/local/etc/apache22/Includes/10_server.conf \
--exclude=/usr/local/etc/apache22/Includes/90_local.conf \
--exclude=/usr/local/etc/nginx/hosting/ \
--exclude=/usr/local/etc/nginx/hosting.conf \
--exclude=/usr/local/etc/nginx/hosting_internal/ \
--exclude=/usr/local/etc/nginx/hosting_internal.conf \
--exclude=/usr/local/etc/nginx/vhosts/ \
--exclude=/usr/local/etc/nginx/vhosts.conf \
--exclude=/usr/local/etc/nginx/nginx_local.conf \
--exclude=/usr/local/etc/hosting_server_config/ \
--exclude=/usr/local/etc/hosting_access/ \
--exclude=/usr/home/ \
--exclude=/home/ \
--exclude=/root/ \
--exclude=/usr/local/etc/domenka/ \
--exclude=/usr/local/etc/domenka_internal/ \
--exclude=/usr/local/lib/php/LST/Connect.php \
--exclude=/etc/crontab \
--exclude=/usr/local/share/doc/ \
--exclude=/alex/ \
--exclude=/usr/local/lib/php/LS/ \
--exclude=/usr/local/lib/php/LST/ \
--exclude=/usr/local/lib/php/LSF/ \
--exclude=/usr/local/lib/php/Zend/ \
--exclude=/usr/local/lib/js/ \
--exclude=/etc/rc.conf \
--exclude=/usr/local/www/repoupdater/www/repoupdater-conf.php \
--exclude=/etc/hosts \
--exclude=/usr/local/etc/nss_ldap.conf \
--exclude=/usr/local/etc/repoupdater-conf.php \
--exclude=/usr/local/etc/php/local_config.ini \
--exclude=/etc/ssh/sshd_config \
--exclude=/usr/local/etc/zabbix/zabbix_agentd.conf \
--exclude=/usr/local/zabbix_templates/etc/ \
--exclude=/etc/ssh/sshd_config \
--exclude=/usr/local/etc/monitrc_local \
--exclude=/usr/local/etc/nginx/Include/server.conf \
--exclude=/etc/resolv.conf \
--exclude=/usr/local/www/default/www/webalizer/ \
--exclude=/usr/local/etc/rsyncd.conf \
--exclude=/usr/local/etc/rsync.secrets \
--exclude=/usr/local/etc/apache22 \
--exclude=/usr/local/etc/nginx \
--exclude=/usr/local/etc/ldap.conf \
--exclude=/usr/local/etc/bacula-fd.conf \
--exclude=/etc/nsswitch.conf \
--exclude=/etc/newsyslog.conf \
--exclude=/etc/ssh/ssh_host_dsa_key \
--exclude=/etc/ssh/ssh_host_dsa_key.pub \
--exclude=/etc/ssh/ssh_host_key \
--exclude=/etc/ssh/ssh_host_key.pub \
--exclude=/etc/ssh/ssh_host_rsa_key \
--exclude=/etc/ssh/ssh_host_rsa_key.pub \
--exclude=/usr/local/etc/ssh/ssh_host_dsa_key \
--exclude=/usr/local/etc/ssh/ssh_host_dsa_key.pub \
--exclude=/usr/local/etc/ssh/ssh_host_key \
--exclude=/usr/local/etc/ssh/ssh_host_key.pub \
--exclude=/usr/local/etc/ssh/ssh_host_rsa_key \
--exclude=/usr/local/etc/ssh/ssh_host_rsa_key.pub \
--exclude=/usr/local/etc/ssh/ssh_host_ecdsa_key \
--exclude=/usr/local/etc/ssh/ssh_host_ecdsa_key.pub \
--exclude=/usr/local/www/data/repoupdater-cgi/repoupdater_after_update.php \
--exclude=/usr/local/lib/php/Zend* \
--exclude=/usr/local/lib/php/L* \
--exclude=/usr/local/lib/php/A* \
--exclude=/usr/local/lib/php/C* \
--exclude=/usr/local/lib/php/T* \
--exclude=/usr/local/lib/php/H* \
--exclude=/usr/local/etc/ssh/sshd_config \


\
"


rsync_args="-avc"
rsync_password_file="/usr/local/etc/rsync.secret"
if [ -f /usr/local/bin/lstools-rsync-jail-webserver-config.sh ]; then
. /usr/local/bin/lstools-rsync-jail-webserver-config.sh
else
  SRC_SERV="192.168.101.12"
  DIR_SRC_JAIL="wwwbuilder"
fi
rsync_url="rsync://updater@${SRC_SERV}/${DIR_SRC_JAIL}"


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
		echo "Default config /usr/local/etc/lstools-rsync-jail-webserver-config.sh (Ldap server = [192.168.101.12], path to src jail = [wwwbuilder])"
		echo "Rsync password file: ${rsync_password_file}"
		echo

        if [ -f /usr/local/bin/lstools-rsync-jail-webserver-config.sh ]; then
            echo "Current lstools-rsync-jail-webserver-config.sh:"
            cat /usr/local/bin/lstools-rsync-jail-webserver-config.sh
            echo
        fi

        path_to_version_file="${rsync_path_to_jail}/usr/local/etc/lstools-version.txt"
        if [ -f $path_to_version_file ]; then
            echo "Current lstools version file:"
            cat $path_to_version_file
        fi


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



