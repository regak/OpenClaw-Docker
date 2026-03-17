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

## Notes

- This environment could not validate `docker build` directly because Docker CLI is unavailable.
- The container entrypoint runs `/opt/openclaw/openclaw`.
