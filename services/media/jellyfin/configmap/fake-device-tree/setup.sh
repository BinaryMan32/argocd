#!/bin/sh
# Builds the fake-dt.c shim into /fake-device-tree, next to the ffmpeg wrapper
# for JELLYFIN_FFMPEG.
set -eu
out=/fake-device-tree

gcc -Wall -Wextra -Werror -O2 -shared -fPIC -o "$out/fake-dt.so" /configmap/fake-dt.c

install -m 0555 /configmap/ffmpeg "$out/ffmpeg"

# ffprobe doesn't need hardware codecs, but jellyfin expects it in the same path as ffmpeg
ln -sf /usr/lib/jellyfin-ffmpeg/ffprobe "$out/ffprobe"
