#!/bin/bash
# Credit to the chaosp project - https://github.com/caseybakey/chaosp
#   build_aosp ; ( aws s3 cp "s3://${STACK_NAME}-script/magisk.sh" ${HOME}/magisk.sh &&  . ${HOME}/magisk.sh && add_magisk ${DEVICE} ) || true

add_magisk(){
  if [ -z "${BUILD_DIR}" ]; then
    BUILD_DIR="$HOME/rattlesnake-os"
  fi
  if [ -z "${BUILD_NUMBER}" ]; then
    BUILD_NUMBER=$(cat ${BUILD_DIR}/out/build_number.txt 2>/dev/null)
  fi
  if [ -z "${DEVICE}" ]; then
    DEVICE=$1
  fi

  rm -rf $HOME/magisk-workdir
  mkdir -p $HOME/magisk-workdir
  pwd_restore="$(pwd)"
  cd $HOME/magisk-workdir

  # Download latest Magisk release
  curl -s https://api.github.com/repos/topjohnwu/Magisk/releases | grep "Magisk-v.*.zip" |grep https|head -n 1| cut -d : -f 2,3|tr -d \" | wget -O magisk-latest.zip -qi -
  
  # Extract the downloaded zip
  unzip -d magisk-latest magisk-latest.zip 

  # Move the original init binary to the place where Magisk expects it to be
  mkdir -p ${BUILD_DIR}/out/target/product/${DEVICE}/obj/PACKAGING/target_files_intermediates/aosp_${DEVICE}-target_files-${BUILD_NUMBER}/BOOT/RAMDISK/.backup
  cp -n ${BUILD_DIR}/out/target/product/${DEVICE}/obj/PACKAGING/target_files_intermediates/aosp_${DEVICE}-target_files-${BUILD_NUMBER}/BOOT/RAMDISK/{init,.backup/init}

  # Copy the downloaded magiskinit binary to the place of the original init binary
  cp magisk-latest/arm/magiskinit64 ${BUILD_DIR}/out/target/product/${DEVICE}/obj/PACKAGING/target_files_intermediates/aosp_${DEVICE}-target_files-${BUILD_NUMBER}/BOOT/RAMDISK/init

  # Create Magisk config file. We keep dm-verity and encryptiong.
  cat <<EOF > ${BUILD_DIR}/out/target/product/${DEVICE}/obj/PACKAGING/target_files_intermediates/aosp_${DEVICE}-target_files-${BUILD_NUMBER}/BOOT/RAMDISK/.backup/.magisk
KEEPFORCEENCRYPT=true
KEEPVERITY=true
RECOVERYMODE=false
EOF

  # Add our "new" files to the list of files to be packaged/compressed/embedded into the final BOOT image
  sed -i "/firmware 0 0 644/a .backup 0 0 000 selabel=u:object_r:rootfs:s0 capabilities=0x0\n.backup/init 0 2000 750 selabel=u:object_r:init_exec:s0 capabilities=0x0\n.backup/.magisk 0 2000 750 selabel=u:object_r:rootfs:s0 capabilities=0x0" ${BUILD_DIR}/out/target/product/${DEVICE}/obj/PACKAGING/target_files_intermediates/aosp_${DEVICE}-target_files*/META/boot_filesystem_config.txt

  # Retrieve extract-dtb script that will allow us to separate already compiled binary and the concatenated DTB files
  git clone https://github.com/PabloCastellano/extract-dtb.git

  # Separate kernel and separate DTB files
  cd extract-dtb
  python3 ./extract-dtb.py ${BUILD_DIR}/out/target/product/${DEVICE}/obj/PACKAGING/target_files_intermediates/aosp_${DEVICE}-target_files-${BUILD_NUMBER}/BOOT/kernel

  # Uncompress the kernel
  lz4 -d dtb/00_kernel dtb/uncompressed_kernel
  cd -

  # Hexpatch the kernel
  chmod +x ./magisk-latest/x86/magiskboot
  ./magisk-latest/x86/magiskboot hexpatch extract-dtb/dtb/uncompressed_kernel 736B69705F696E697472616D667300 77616E745F696E697472616D667300

  # Recompress kernel
  lz4 -f -9 extract-dtb/dtb/uncompressed_kernel extract-dtb/dtb/00_kernel
  rm extract-dtb/dtb/uncompressed_kernel

  # Concatenate back kernel and DTB files
  rm ${BUILD_DIR}/out/target/product/${DEVICE}/obj/PACKAGING/target_files_intermediates/aosp_${DEVICE}-target_files-${BUILD_NUMBER}/BOOT/kernel
  for file in extract-dtb/dtb/*
  do
    cat $file >> ${BUILD_DIR}/out/target/product/${DEVICE}/obj/PACKAGING/target_files_intermediates/aosp_${DEVICE}-target_files-${BUILD_NUMBER}/BOOT/kernel
  done

  # Remove target files zip
  rm -f ${BUILD_DIR}/out/target/product/${DEVICE}/obj/PACKAGING/target_files_intermediates/aosp_${DEVICE}-target_files-${BUILD_NUMBER}.zip

  # Rezip target files
  cd ${BUILD_DIR}/out/target/product/${DEVICE}/obj/PACKAGING/target_files_intermediates/aosp_${DEVICE}-target_files-${BUILD_NUMBER}
  zip --symlinks -r ../aosp_${DEVICE}-target_files-${BUILD_NUMBER}.zip *
  cd "${pwd_restore}"

}
