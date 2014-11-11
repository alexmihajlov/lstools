BINS = lstools-rsync-jail-webserver.sh lstools-rsync-jail-webserver-config.sh.sample lstools-rsync-jail-mysql.sh lstools-php-session-dir-gen.sh lstools-webserver-perm-fix.sh lstools-updater.sh lstools-svnup-lib.sh lstools-NOARCHIVE_TAG.sh
PREFIX = /usr/local

INSTALL = install
INSOPTS = -s -m 755 -o 0 -g 0
.PHONY = install installup

    	
install:
	for file in $(BINS); do \
		if [ -f $(PREFIX)/bin/"$$file" ]; then \
			rm $(PREFIX)/bin/"$$file"; \
		fi; \
	done
	for file in $(BINS); do \
		cp "$$file" $(PREFIX)/bin/ && chmod +x $(PREFIX)/bin/"$$file";  \
	done

#
#
