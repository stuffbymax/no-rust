#!/usr/bin/env bash
set -euo pipefail

TARGET="powerpc64-unknown-linux-gnu"  # or appropriate cross-triplet for PS3
SYSROOT="/usr/${TARGET}/sysroot"     # adjust to your crossdev sysroot
JOBS=4                                # parallel make jobs

# 1. Ensure crossdev toolchain
emerge --ask crossdev
crossdev --target $TARGET --stable

# 2. Install build-time dependencies for target in cross‑sysroot
#    (You may need to emerge glib, cairo, libxml2, gdk-pixbuf for the target)
#    Example (very rough, depends on cross overlay / setup):
emerge --ask --target $TARGET sys-libs/glib dev-libs/libxml2 x11-libs/cairo gnome-base/gdk-pixbuf

# 3. Download librsvg 2.40.21 source
cd /tmp
wget https://download.gnome.org/sources/librsvg/2.40/librsvg-2.40.21.tar.xz
tar xf librsvg-2.40.21.tar.xz
cd librsvg-2.40.21

# 4. Set up environment variables for cross‑compile
export PKG_CONFIG_SYSROOT_DIR="$SYSROOT"
export PKG_CONFIG_PATH="$SYSROOT/usr/lib/pkgconfig:$SYSROOT/usr/share/pkgconfig"
export CC="${TARGET}-gcc"
export CFLAGS="--sysroot=$SYSROOT"
export LDFLAGS="--sysroot=$SYSROOT"

# 5. Configure for cross‑build
./configure --host="$TARGET" --prefix=/usr --disable-introspection --without-vala

# 6. Build & install into sysroot
make -j${JOBS}
make DESTDIR="$SYSROOT" install

# 7. (Optional) Copy / deploy the built library into your PS3 rootfs or image
#    e.g. rsync, or package up into a tarball, etc.
rsync -av "$SYSROOT"/usr/lib/rsvg-2.0 "$SYSROOT"/usr/lib/

echo "Built and installed librsvg 2.40.21 for target $TARGET into $SYSROOT"
