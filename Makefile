rust_makefile=https://raw.githubusercontent.com/mozilla/rust/master/mk/main.mk
cargo_makefile=https://raw.githubusercontent.com/rust-lang/cargo/master/Makefile.in

default: rust-src-pkg cargo-src-pkg

# Upload
upload: rust-upload cargo-upload

%-upload: %-src-pkg
	burp $*-nightly-bin-*.src.tar.gz

# Binary packages
bin-pkgs: rust-bin-pkg cargo-bin-pkg

%-bin-pkg: pkgbuilds/%.pkgbuild
	makepkg -p pkgbuilds/$*.pkgbuild
	rm -rf pkg src

# Source packages
source-pkgs: rust-src-pkg cargo-src-pkg

%-src-pkg: pkgbuilds/%.pkgbuild
	mkaurball -p $< -f
	@rm -f $*.xml

# PKGBUILDs
pkgbuilds/%.pkgbuild: temp/%_makefile.mk | pkgbuilds
	./make_pkgbuild.py templates/$*.pkgbuild $< > $@
	rm $<

pkgbuilds:
	mkdir -p $@

# Version Makefiles
temp/%_makefile.mk: | temp
	curl $($*_makefile) -o $@

temp:
	mkdir -p $@

# Cleaning
clean:
	rm -rf pkg src
	rm -rf pkgbuilds
	rm -rf temp
	rm -rf rust.xml
	rm -f *.src.tar.gz
	rm -f *.pkg.tar.xz

super-clean: clean
	rm -f *.tar.gz
