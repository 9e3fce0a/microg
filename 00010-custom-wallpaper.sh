#!/bin/bash

WALLPAPER="https://github.com/9e3fce0a/microg/raw/master/default_wallpaper.png"
mkdir -p $BUILD_DIR/branding
echo "Downloading wallpaper $WALLPAPER"
wget -O $BUILD_DIR/branding/default_wallpaper.png $WALLPAPER
cp -rp $BUILD_DIR/branding/default_wallpaper.png $BUILD_DIR/frameworks/base/core/res/res/drawable-nodpi/default_wallpaper.png
