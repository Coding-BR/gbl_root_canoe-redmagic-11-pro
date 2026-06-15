clean:
	rm -rf build || true
submodule_uefi:
	cd ../../submodules/uefi && make build_generic GENERIC_PATCHER_DEFINES="$(GENERIC_PATCHER_DEFINES)"
	mkdir -p ./build
	cp ../../submodules/uefi/build/generic_superfastboot.efi ./build/generic_superfastboot.efi
build: submodule_uefi
	# do nothing, just build the submodules
