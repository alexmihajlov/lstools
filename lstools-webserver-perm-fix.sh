#!/bin/sh -e


for dirname in \
/usr/local/lib/php/LS* \
/usr/local/lib/php/Zend \
/usr/local/lib/js \
# /usr/local/www/hosting \
#
# do not delete this comment ;)
#
do
	chgrp -R repoupdater $dirname
	chmod -R g+wrX $dirname
	echo "fixed: ${dirname}"
done


# cache, logs
#for dirname in `ls /usr/local/www/hosting/`; do
#    chmod -R 0777 /usr/local/www/hosting/$dirname/logs
#    chmod -R 0777 /usr/local/www/hosting/$dirname/www/logs
#    chmod -R 0777 /usr/local/www/hosting/$dirname/cache
#    chmod -R 0777 /usr/local/www/hosting/$dirname/www/cache
#    echo "fixed: ${dirname}"
#done


# repoupdater
for dirname in \
/var/repoupdater \
/var/log/repoupdater \
/var/log/repoupdater.log \
#
# do not delete this comment ;)
#
do
	chown -R www $dirname
	chgrp -R repoupdater $dirname
	chmod -R g+wrX $dirname
	echo "fixed: ${dirname}"
done

chown repoupdater /usr/bin/svn-repoupdater





