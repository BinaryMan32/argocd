# generic-device-plugin-rk3588

See <https://github.com/squat/generic-device-plugin>

Advertises Rockchip RK3588 devices on the arm64 nodes as extended resources, so
pods can use them without hostPath device mounts or privileged mode.
Request a resource in the container's `limits`:

```yaml
resources:
  limits:
    devic.es/rkmpp: 1
```

Each resource has a count of 1, so at most one pod per node can use it.

## devic.es/rkmpp

Rockchip MPP (Media Process Platform) video decode/encode with RGA (Raster
Graphic Acceleration), as used by jellyfin-ffmpeg. See
[Jellyfin's Rockchip docs](https://jellyfin.org/docs/general/post-install/transcoding/hardware-acceleration/rockchip/),
which require the Rockchip BSP kernel.

| Device | Hardware |
| --- | --- |
| `/dev/mpp_service` | VPU, single entry point for the codec blocks (rkvdec2, rkvenc2, vdpu/vepu, jpeg, av1, iep2) |
| `/dev/rga` | RGA 2D accelerator for scaling, format conversion, and subtitle burn-in |
| `/dev/dri/renderD128` | rockchip-drm display subsystem, for sharing frame buffers |
| `/dev/dma_heap/*` | Buffer allocators used by MPP and RGA |

`/dev/dri/renderD129` is the NPU, and is excluded.

## devic.es/mali

Mali-G610 GPU (`/dev/mali0`). Jellyfin only needs it for OpenCL HDR
tone-mapping.

## Checking

Each arm64 node should advertise 1 of each resource:

```sh
kubectl get nodes -o custom-columns='NODE:.metadata.name,RKMPP:.status.allocatable.devic\.es/rkmpp,MALI:.status.allocatable.devic\.es/mali'
```

Every path in a group is required, so a node missing any of them advertises `0`.

## Differences from upstream

The DaemonSet and PodMonitor are adapted from the upstream
[manifests](https://github.com/squat/generic-device-plugin/tree/main/manifests)
on `main`, which include the unprivileged security context from
[#245](https://github.com/squat/generic-device-plugin/pull/245). That change is
newer than the `0.2.0` release, but only touched manifests, so it applies to the
`0.2.0` image. The `0.2.0` manifests and Helm chart still run privileged.

DaemonSet:

- Image pinned to `0.2.0` with kustomize `images`, upstream is untagged
- Devices are `rkmpp` and `mali` instead of the serial, video, fuse, audio and
  capture examples
- `nodeSelector` limits it to the arm64 nodes
- `readinessProbe` on `/health` and `minReadySeconds: 10`, so a rollout of an
  image which crashes after starting stops after one node
