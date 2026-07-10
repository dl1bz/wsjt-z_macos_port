#!/bin/bash

set -e

rm -rf "$HOME/wsjtz-prefix/wsjtz.app"
rm -rf "$HOME/src/wsjt-z-build"

mkdir -p "$HOME/src/wsjt-z-build"
cd "$HOME/src/wsjt-z-build"

export MACOSX_DEPLOYMENT_TARGET=11.0
export PKG_CONFIG_PATH="/opt/local/hamlib47/lib/pkgconfig:/opt/homebrew/lib/pkgconfig:/opt/homebrew/opt/fftw/lib/pkgconfig:$PKG_CONFIG_PATH"

cmake "$HOME/src/wsjt-z_macos_port" -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 -DCMAKE_PREFIX_PATH="/opt/homebrew/opt/qt@5;/opt/local/hamlib47;/opt/homebrew" -DQt5_DIR="/opt/homebrew/opt/qt@5/lib/cmake/Qt5" -DCMAKE_INSTALL_PREFIX="$HOME/wsjtz-prefix" -DWSJT_SKIP_MANPAGES=ON -DWSJT_GENERATE_DOCS=OFF

cmake --build . -j"$(sysctl -n hw.ncpu)"
cmake --build . --target install

APP="$HOME/wsjtz-prefix/wsjtz.app"

sudo chown -R "$USER":staff "$APP"
chmod -R u+rwX "$APP"

xattr -dr com.apple.quarantine "$APP" 2>/dev/null || true

codesign --force --deep --timestamp=none --sign - "$APP"
codesign --verify --deep --strict --verbose=4 "$APP"

cd "$HOME/wsjtz-prefix"
rm -f wsjt-z-macos-arm64.zip
ditto -c -k --keepParent wsjtz.app wsjt-z-macos-arm64.zip
ls -lh wsjt-z-macos-arm64.zip

