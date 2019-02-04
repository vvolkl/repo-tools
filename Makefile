.PHONY: all


ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
sourcedir:=$(subst package,package-build,$(ROOT_DIR))
sources:=$(sort $(wildcard $(sourcedir)/*))
targets:=$(subst package-build,package,$(addsuffix .deb,$(sources)))

%.deb : $(sourcedir)/%
	echo $@ $<
	dpkg-deb --build $< $@ && export GPG_TTY=/dev/pts/0 && dpkg-sig --sign builder $@

#$(foreach element,$$(packages),$(eval$(call make-package-target,$(element))))

#$(call make-package-target,sdlfjll)

build: $(notdir $(targets))
release:
	apt-ftparchive packages --db package_cache_db . > Packages
	apt-ftparchive release . > Release
	rm InRelease
	gpg --clearsign -o InRelease Release
	rm Release.gpg
	gpg  -abs -o Release.gpg Release
publish:
	rsync --recursive --delete --verbose -e "ssh -o StrictHostKeyChecking=no -o GSSAPIAuthentication=yes -o GSSAPITrustDNS=yes -o GSSAPIDelegateCredentials=yes" ./ vavolkl@lxplus.cern.ch:/eos/user/v/vavolkl/www/pileup/sw/latest/x86_64-ubuntu1804-gcc8-opt
all: build release publish



