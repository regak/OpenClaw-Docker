# OpenClaw Docker image

This repository contains Docker setups for two unrelated projects that happen to share the "OpenClaw" name:

- The [OpenClaw](https://github.com/pjasicek/OpenClaw) Captain Claw game engine reimplementation (root `Dockerfile`).
- [wacli](https://github.com/openclaw/wacli), a scriptable WhatsApp CLI (`wacli/Dockerfile`).

## OpenClaw game

This part builds and runs [OpenClaw](https://github.com/pjasicek/OpenClaw).

### What this image does

- Clones OpenClaw from GitHub during `docker build`.
- Compiles it with CMake.
- Produces a smaller runtime image with SDL/OpenAL runtime deps.

### Build

```bash
docker build -t openclaw:latest .
```

You can pin a specific OpenClaw branch/tag/commit using build args:

```bash
docker build \
  --build-arg OPENCLAW_REF=master \
  -t openclaw:latest .
```

### Required game assets

OpenClaw needs original Captain Claw assets at runtime (at minimum `CLAW.REZ`, and usually `ASSETS.ZIP`) inside `Build_Release`.

Create an assets directory on your host, for example:

```bash
mkdir -p ./claw-assets/Build_Release
# copy CLAW.REZ and ASSETS.ZIP into ./claw-assets/Build_Release
```

### Run (Linux/X11)

```bash
docker run --rm -it \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  -v "$(pwd)/claw-assets/Build_Release:/opt/openclaw/Build_Release:rw" \
  openclaw:latest
```

If audio or display permissions are restricted on your system, adjust your host setup (for example `xhost +local:` for X11).

### Notes

- This environment could not validate `docker build` directly because Docker CLI is unavailable.
- The container entrypoint runs `/opt/openclaw/openclaw`.

## wacli (WhatsApp CLI)

[wacli](https://github.com/openclaw/wacli) is a scriptable WhatsApp client for the command line. It pairs as a WhatsApp Web linked device, mirrors messages into a local SQLite store, and supports offline search, sending, and chat/group/contact management. It is not affiliated with WhatsApp or Meta.

### What this image does

- Clones `wacli` from GitHub during `docker build` and compiles it with Go (CGO + `sqlite_fts5` enabled).
- Runs as a non-root user with a `/data` volume for its store, state, config, and cache directories, so pairing survives container restarts.

### Build

```bash
docker build -t wacli:latest ./wacli
```

You can pin a specific wacli branch/tag/commit using build args:

```bash
docker build \
  --build-arg WACLI_REF=main \
  -t wacli:latest ./wacli
```

### Pair with WhatsApp

wacli pairs as a linked device via QR code, so run `auth` interactively at least once, keeping the `/data` volume so the session persists:

```bash
mkdir -p ./wacli-data
docker run --rm -it \
  -v "$(pwd)/wacli-data:/data:rw" \
  wacli:latest auth
```

Scan the QR code from WhatsApp's **Linked devices** screen on your phone.

### Run

Once paired, reuse the same `/data` volume for any other `wacli` subcommand, for example:

```bash
docker run --rm -it \
  -v "$(pwd)/wacli-data:/data:rw" \
  wacli:latest sync

docker run --rm -it \
  -v "$(pwd)/wacli-data:/data:rw" \
  wacli:latest send --to "<chat-id>" --text "hello from wacli"
```

### Notes

- This environment could not validate `docker build` directly because Docker CLI is unavailable.
- The container entrypoint runs `wacli`; the default command is `--help`.
