// LD_PRELOAD shim for jellyfin-ffmpeg.
//
// Rockchip MPP identifies the SoC by reading /proc/device-tree/compatible,
// which links into /sys/firmware, one of containerd's default masked paths.
// With "soc unknown", MPP refuses HEVC/VP9/AV1 decoding and HEVC encoding:
// https://github.com/nyanmisaka/mpp/blob/a9380ef333102ac318628f83b5f7a460d377749e/osal/mpp_soc.c#L1096-L1124
//
// MPP reads the file with open(), so redirect that one path to the host's
// file, which the deployment mounts with hostPath outside /sys/firmware.
#define _GNU_SOURCE
#include <dlfcn.h>
#include <fcntl.h>
#include <stdarg.h>
#include <string.h>

#define DT_COMPATIBLE "/proc/device-tree/compatible"
#define HOST_DT_COMPATIBLE "/host-device-tree/compatible"

int open(const char *path, int flags, ...)
{
    static int (*real_open)(const char *, int, ...);
    mode_t mode = 0;

    // open() only has a mode argument when it can create a file
    if (__OPEN_NEEDS_MODE(flags)) {
        va_list ap;
        va_start(ap, flags);
        mode = va_arg(ap, mode_t);
        va_end(ap);
    }

    if (!real_open)
        real_open = dlsym(RTLD_NEXT, "open");

    if (strcmp(path, DT_COMPATIBLE) == 0)
        path = HOST_DT_COMPATIBLE;

    return real_open(path, flags, mode);
}
