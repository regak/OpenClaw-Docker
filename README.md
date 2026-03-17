# OpenClaw Docker image

This repository contains a Docker setup that builds and runs [OpenClaw](https://github.com/pjasicek/OpenClaw).

## What this image does

- Clones OpenClaw from GitHub during `docker build`.
- Compiles it with CMake.
- Produces a smaller runtime image with SDL/OpenAL runtime deps.

## Build

```bash
docker build -t openclaw:latest .
```

You can pin a specific OpenClaw branch/tag/commit using build args:

```bash
docker build \
  --build-arg OPENCLAW_REF=master \
  -t openclaw:latest .
```

## Required game assets

OpenClaw needs original Captain Claw assets at runtime (at minimum `CLAW.REZ`, and usually `ASSETS.ZIP`) inside `Build_Release`.

Create an assets directory on your host, for example:

```bash
mkdir -p ./claw-assets/Build_Release
# copy CLAW.REZ and ASSETS.ZIP into ./claw-assets/Build_Release
```

## Run (Linux/X11)

```bash
docker run --rm -it \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  -v "$(pwd)/claw-assets/Build_Release:/opt/openclaw/Build_Release:rw" \
  openclaw:latest
```

If audio or display permissions are restricted on your system, adjust your host setup (for example `xhost +local:` for X11).

## Smoke test without a display

You can validate the binary starts in headless mode (it should then fail only if `CLAW.REZ` is not present):

```bash
SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy SDL_RENDER_DRIVER=software ./openclaw
```

Expected failure without assets:

```text
ERROR: [VOpen] Could not load Rez archive: CLAW.REZ
```

## Notes

- Docker CLI is not available in this execution environment, so `docker build` was not run here.
- OpenClaw was compiled and executed directly in this environment using SDL dummy drivers; startup succeeds until asset loading.
- The container entrypoint runs `/opt/openclaw/openclaw`.
