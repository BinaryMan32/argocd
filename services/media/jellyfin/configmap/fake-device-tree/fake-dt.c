// LD_PRELOAD shim for jellyfin-ffmpeg.
//
// Rockchip MPP identifies the SoC by reading /proc/device-tree/compatible,
// which links into /sys/firmware, one of containerd's default masked paths.
// With "soc unknown", MPP refuses HEVC/VP9/AV1 decoding and HEVC encoding:
// https://github.com/nyanmisaka/mpp/blob/a9380ef333102ac318628f83b5f7a460d377749e/osal/mpp_soc.c#L1096-L1124
//
// MPP reads the file with open(), which becomes open64() when built with
// _FILE_OFFSET_BITS=64, so wrap both to redirect that one path to the host's
// file, which the deployment mounts with hostPath outside /sys/firmware.
#define _GNU_SOURCE
#include <dlfcn.h>
#include <fcntl.h>
#include <stdarg.h>
#include <string.h>

#define DT_COMPATIBLE "/proc/device-tree/compatible"
#define HOST_DT_COMPATIBLE "/host-device-tree/compatible"

typedef int (*open_fn)(const char *, int, ...);

static int redirect_open(open_fn real, const char *path, int flags,
                         va_list ap)
{
    // open() only has a mode argument when it can create a file
    mode_t mode = __OPEN_NEEDS_MODE(flags) ? va_arg(ap, mode_t) : 0;

    if (strcmp(path, DT_COMPATIBLE) == 0)
        path = HOST_DT_COMPATIBLE;

    return real(path, flags, mode);
}

int open(const char *path, int flags, ...)
{
    static open_fn real_open;
    va_list ap;
    int fd;

    if (!real_open)
        real_open = dlsym(RTLD_NEXT, "open");
    va_start(ap, flags);
    fd = redirect_open(real_open, path, flags, ap);
    va_end(ap);
    return fd;
}

int open64(const char *path, int flags, ...)
{
    static open_fn real_open64;
    va_list ap;
    int fd;

    if (!real_open64)
        real_open64 = dlsym(RTLD_NEXT, "open64");
    va_start(ap, flags);
    fd = redirect_open(real_open64, path, flags, ap);
    va_end(ap);
    return fd;
}
