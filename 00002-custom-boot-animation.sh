#!/bin/bash

#BOOT_ANIMATION="https://github.com/RattlesnakeOS/example_patch_shellscript/raw/master/bootanimation.zip"
BOOT_ANIMATION="https://github.com/9e3fce0a/microg/raw/master/bootanimation.zip"
mkdir -p $BUILD_DIR/branding
echo "Downloading boot animation $BOOT_ANIMATION"
wget -O $BUILD_DIR/branding/bootanimation.zip $BOOT_ANIMATION
sed -i "\$aPRODUCT_COPY_FILES += branding/bootanimation.zip:system/media/bootanimation.zip" ${BUILD_DIR}/build/make/target/product/core.mk
