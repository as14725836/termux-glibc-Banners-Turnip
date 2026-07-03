#!/bin/bash -e

green='\033[0;32m'
red='\033[0;31m'
nocolor='\033[0m'
deps="git meson ninja patchelf unzip curl pip flex bison zip glslang glslangValidator"
workdir="$(pwd)/turnip_workdir"
mesasrc="https://gitlab.freedesktop.org/mesa/mesa"
srcfolder="mesa"

run_all(){
	echo -e "${green}====== Begin building TU V${BUILD_VERSION}! ======${nocolor}"
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
	pip3 install --user mako &> /dev/null || pip install --user mako &> /dev/null || true
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
	echo "==== Building Mesa on $1 branch ===="

	# 创建 Termux 目录结构
	echo "Creating Termux directory structure..."
	sudo mkdir -p /data/data/com.termux/files/usr/glibc
	sudo chmod 777 -R /data

	if [ -n "$EXTRA_PATCH" ] && [ -f "../../$EXTRA_PATCH" ]; then
		echo "Applying patch series: $EXTRA_PATCH"
		patch -p1 -N --fuzz=4 < "../../$EXTRA_PATCH" || echo -e "${red}Warning: partial patch failures, continuing...${nocolor}"
	fi

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
	export CC=clang
    export CXX=clang++
	export CFLAGS="-O3 -fno-plt -flto=thin -Wno-error -Wno-deprecated-declarations"
	export CXXFLAGS="-O3 -fno-plt -flto=thin -Wno-error -Wno-deprecated-declarations"
	export LDFLAGS="-flto=thin"
	
	# 使用系统 meson
	 meson setup builddir \
            --libdir=lib \
            -Dprefix=/data/data/com.termux/files/usr/glibc \
            -Dbuildtype=release \
            -Dplatforms=x11 \
            -Degl-native-platform=x11 \
            -Dglx=dri \
            -Dglx-direct=true \
            -Dopengl=true \
            -Dgles1=enabled \
            -Dgles2=enabled \
            -Dglvnd=disabled \
            -Degl=enabled \
            -Dllvm=disabled \
            -Dshared-llvm=enabled \
            -Dshader-cache=enabled \
            -Dshared-glapi=enabled \
            -Dxlib-lease=enabled \
            -Dvulkan-beta=true \
            -Dlibunwind=disabled \
            -Dvalgrind=disabled \
            -Dmicrosoft-clc=disabled \
            -Dgallium-rusticl=false \
            -Dgallium-extra-hud=true \
            -Dgallium-drivers=zink,freedreno,virgl,softpipe \
            -Dgallium-rusticl-enable-drivers=freedreno \
            -Dshader-cache-default=true \
            -Dvulkan-drivers=freedreno,swrast,virtio \
            -Dfreedreno-kmds=kgsl \
            -Dvulkan-layers=anti-lag \
            -Dvideo-codecs=all \
            -Dgbm=enabled \
            -Db_ndebug=true \
            -Dstrip=true \
		    --reconfigure

	echo "Compiling build files..."
	ninja -C build

	if [ ! -f "build/src/freedreno/vulkan/libvulkan_freedreno.so" ]; then
		echo -e "${red}Build failed!${nocolor}" && exit 1
	fi

	echo "Installing to Termux directory..."
	# 使用系统 meson 安装
	 ninja -C build install

	echo "Getting driver version info..."
	_mesa_vk_header="include/vulkan/vulkan_core.h"
	_vk_patch=$(grep '^#define VK_HEADER_VERSION ' "$_mesa_vk_header" | awk '{print $3}')
	_vk_minor=$(grep 'define TU_API_VERSION' "src/freedreno/vulkan/tu_device.cc" | grep -oP 'VK_MAKE_VERSION\(\s*[0-9]+,\s*\K[0-9]+')
	_driver_version="Vulkan 1.${_vk_minor}.${_vk_patch}"

	echo -e "${green}Build completed successfully!${nocolor}"
	echo -e "${green}Driver version: ${_driver_version}${nocolor}"
	
	# 查找安装的 .so 文件
	SO_FILE=$(find /data/data/com.termux/files/usr/glibc -name "libvulkan_freedreno.so" 2>/dev/null | head -1)
	if [ -n "$SO_FILE" ] && [ -f "$SO_FILE" ]; then
		echo -e "${green}Driver installed to: ${SO_FILE}${nocolor}"
		echo -e "${green}Git hash: ${GITHASH}${nocolor}"
		
		# 创建压缩包
		echo "Creating archive..."
		_archive_name="mesa-turnip-linux-V${BUILD_VERSION}-${GITHASH}.tar.gz"
		SO_DIR=$(dirname "$SO_FILE")
		cd "$SO_DIR"
		sudo tar -czf "$workdir/${_archive_name}" libvulkan_freedreno.so
		echo -e "${green}Archive created: ${workdir}/${_archive_name}${nocolor}"
		cd - > /dev/null
	else
		echo -e "${red}Error: libvulkan_freedreno.so not found!${nocolor}"
		echo "Contents of install directory:"
		find /data/data/com.termux/files/usr/glibc -type f 2>/dev/null || echo "No files found"
		exit 1
	fi
}

run_all
