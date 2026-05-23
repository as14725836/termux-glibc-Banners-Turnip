#!/bin/bash -e

green='\033[0;32m'
red='\033[0;31m'
nocolor='\033[0m'
deps="git meson ninja patchelf unzip curl pip flex bison zip glslang glslangValidator"
workdir="$(pwd)/turnip_workdir"
mesasrc="https://gitlab.freedesktop.org/mesa/mesa"
srcfolder="mesa"

run_all(){
	echo -e "${green}====== Begin building TU Perf V${BUILD_VERSION}! ======${nocolor}"
	check_deps
	prepare_workdir
	build_lib_for_linux main
}

check_deps(){
	echo "Checking system for required Dependencies ..."
	for deps_chk in $deps; do
		if command -v "$deps_chk" >/dev/null 2>&1 ; then
			echo -e "$green - $deps_chk found $nocolor"
		else
			echo -e "$red - $deps_chk not found, can't continue. $nocolor"
			deps_missing=1
		fi
	done

	if [ "$deps_missing" == "1" ]; then
		echo "Please install missing dependencies" && exit 1
	fi

	echo "Installing python Mako dependency..."
	pip install mako &> /dev/null || true
}

prepare_workdir(){
	echo "Preparing work directory..."
	mkdir -p "$workdir" && cd "$_"

	if [ "${SKIP_SOURCE_DOWNLOAD}" = "1" ]; then
		echo "Skipping Mesa download (reusing existing source)..."
		if [ -d "$srcfolder/.git" ]; then
			echo "Resetting Mesa source tree..."
			git -C "$srcfolder" checkout .
		fi
		return
	fi

	echo "Downloading mesa source..."
	git clone $mesasrc --depth=1 -b main $srcfolder
}

build_lib_for_linux(){
	cd "$workdir/$srcfolder"
	echo "==== Building Mesa on $1 branch (performance build — A6xx/A7xx) ===="

	# Apply optional patch series if EXTRA_PATCH is set
	if [ -n "$EXTRA_PATCH" ] && [ -f "../../$EXTRA_PATCH" ]; then
		echo "Applying patch series: $EXTRA_PATCH"
		patch -p1 -N --fuzz=4 < "../../$EXTRA_PATCH" || echo -e "${red}Warning: partial patch failures, continuing...${nocolor}"
	fi

	# Apply optional Python scripts if EXTRA_SCRIPT is set (colon-separated list)
	if [ -n "$EXTRA_SCRIPT" ]; then
		IFS=':' read -ra SCRIPTS <<< "$EXTRA_SCRIPT"
		for SCRIPT in "${SCRIPTS[@]}"; do
			if [ -f "../../$SCRIPT" ]; then
				echo "Running script: $SCRIPT"
				python3 "../../$SCRIPT" || { echo -e "${red}Script $SCRIPT failed, aborting!${nocolor}"; exit 1; }
			fi
		done
	fi

	GITHASH=$(git rev-parse --short HEAD)

	echo "Generating build files..."
	
	# Performance build with O3 and ThinLTO
	export CFLAGS="-O3 -fno-plt -flto=thin -Wno-error -Wno-deprecated-declarations"
	export CXXFLAGS="-O3 -fno-plt -flto=thin -Wno-error -Wno-deprecated-declarations"
	export LDFLAGS="-flto=thin"
	
	meson setup build \
		--prefix /usr/local \
		-Dbuildtype=release \
		-Db_ndebug=true \
		-Dstrip=true \
		-Dplatforms=x11,wayland \
		-Dvulkan-drivers=freedreno \
		-Dvulkan-beta=true \
		-Dfreedreno-kmds=kgsl \
		-Dgallium-drivers= \
		-Degl=disabled \
		-Dtools=freedreno \
		--reconfigure

	echo "Compiling build files..."
	ninja -C build

	if [ ! -f "build/src/freedreno/vulkan/libvulkan_freedreno.so" ]; then
		echo -e "${red}Build failed!${nocolor}" && exit 1
	fi

	echo "Installing to system..."
	sudo ninja -C build install

	echo -e "${green}Build completed successfully!${nocolor}"
	echo -e "${green}Git hash: ${GITHASH}${nocolor}"
	
	# Optional: create archive
	if [ "${CREATE_ARCHIVE}" = "1" ]; then
		echo "Creating archive..."
		_zip_name="mesa-turnip-perf-linux-V${BUILD_VERSION}-${GITHASH}.tar.gz"
		cd build/src/freedreno/vulkan/
		tar -czf "/tmp/${_zip_name}" libvulkan_freedreno.so
		cp "/tmp/${_zip_name}" "$workdir/"
		echo -e "${green}Archive created: ${workdir}/${_zip_name}${nocolor}"
		cd - > /dev/null
	fi
}

run_all
