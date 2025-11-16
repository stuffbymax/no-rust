#!/usr/bin/env bash
set -euo pipefail

# 1. Sync portage
emerge --sync

# 2. Mask newer versions of librsvg you *don't* want
#    (so Portage doesn't upgrade them)
cat <<EOF >> /etc/portage/package.mask/librsvg
# Mask all versions > 2.40.21 of librsvg
>gnome-base/librsvg-2.40.21
<gnome-base/librsvg-2.40.21
EOF

# 3. Unmask (accept) 2.40.21 if needed
cat <<EOF >> /etc/portage/package.accept_keywords/librsvg
=gnome-base/librsvg-2.40.21 **  # or appropriate keyword (~amd64, ~x86, etc)
EOF

# 4. Optionally, disable USE flags you don't want (e.g. introspection / vala)
cat <<EOF >> /etc/portage/package.use/librsvg
=gnome-base/librsvg-2.40.21 -vala -introspection
EOF

# 5. Emerge that specific version
emerge --ask =gnome-base/librsvg-2.40.21

# 6. Optionally, rebuild other packages that depend on librsvg
emerge --ask --deep --with-bdeps=y @world
