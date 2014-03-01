SOFTWARE_NAME = sysfunc

include config.mk

TGZ_PREFIX = $(SOFTWARE_NAME)-$(SOFTWARE_VERSION)
TGZ_FILE = $(TGZ_PREFIX).tar.gz

#=====================================

all: ppc

.PHONY: ppc clean tgz install all rpm

ppc: sysfunc.sh.ppc

sysfunc.sh.ppc:
	chmod +x build/build.sh
	build/build.sh "$(SOFTWARE_VERSION)" "$(INSTALL_DIR)"

install: sysfunc.sh.ppc
	chmod +x build/install.sh
	build/install.sh $(INSTALL_DIR)

specfile: build/specfile.in
	chmod +x build/mkspec.sh
	build/mkspec.sh "$(SOFTWARE_VERSION)" "$(INSTALL_DIR)"

tgz: $(TGZ_FILE)

$(TGZ_FILE): clean
	/bin/rm -rf /tmp/$(TGZ_PREFIX)
	mkdir /tmp/$(TGZ_PREFIX)
	tar cf - . | ( cd /tmp/$(TGZ_PREFIX) ; tar xpf - )
	( cd /tmp ; rm -rf $(TGZ_PREFIX)/.git ; tar cf - ./$(TGZ_PREFIX) ) | gzip >$(TGZ_FILE)
	/bin/rm -rf /tmp/$(TGZ_PREFIX)

rpm: tgz specfile
	rpmbuild -bb --define="_sourcedir `pwd`" specfile

clean:
	/bin/rm -rf sysfunc.sh.ppc specfile $(TGZ_FILE)


PREFIX ?= /usr/local

install: bin/deploy
	@cp -p $< $(PREFIX)/$<

uninstall:
	rm -f $(PREFIX)/bin/deploy

.PHONY: install uninstall
	

init :

test :
	@cd ./tests ; ./test_all.sh