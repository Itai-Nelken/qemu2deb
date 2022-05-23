PREFIX = /usr

all:
	@echo Run \'make install\' to install qemu2deb.

install:
	@mkdir -p $(DESTDIR)$(PREFIX)/bin
	@cp -p qemu2deb $(DESTDIR)$(PREFIX)/bin/qemu2deb
	@chmod 755 $(DESTDIR)$(PREFIX)/bin/qemu2deb

uninstall:
	@rm -rf $(DESTDIR)$(PREFIX)/bin/qemu2deb