# Retro Nation archive

## setup

```
apt-get update # updates
apt-get install ffmpeg python3-is-python # conversion tools

# install latest youtube-dl
wget "https://github.com/ytdl-org/ytdl-nightly/releases/download/2023.12.07/youtube-dl"
chmod u+x youtube-dl

pip install --upgrade numpy opencv-python


# install insanely-fast-whisper
export PIPX_HOME=/workspace/pipx/home
export PIPX_BIN_DIR=/workspace/pipx/bin
export PIPX_MAN_DIR=/workspace/pipx/man
pip install pipx
pipx install insanely-fast-whisper
pipx runpip insanely-fast-whisper install wheel
pipx runpip insanely-fast-whisper install flash-attn --no-build-isolation
```

## scp

```bash
scp collect_offsets.sh download_audio.sh download_video_parallel.sh f-artefakt.png f-datadisk.jpg find-sections-clever.py find_offsets_parallel.sh videos.csv 
```
