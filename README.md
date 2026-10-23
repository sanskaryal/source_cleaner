# Lab Pi Tools

I created this for GTAs to clean the lab Pis.

## Install and run

Clone the repository on the Pi, then run the master menu as your normal user:

```bash
git clone https://github.com/sanskaryal/source_cleaner.git
cd source_cleaner
chmod +x *.sh
./pi-tools.sh
```

Choose an operation:

1. **Clean home directory** — runs `pi-clean.sh`.
2. **Install WiringPi** — runs `install-wiringpi.sh`.

Run `./pi-tools.sh` without `sudo`. The WiringPi installer asks for `sudo`
when it needs to install system packages. You can also run either script
directly.

## What the cleaner does

`pi-clean.sh` runs without confirmation. It removes visible files and
non-standard folders from the home directory, clears visible contents of the
standard folders, empties the Linux Trash, and ensures the standard folders
exist: Desktop, Documents, Downloads, Music, Pictures, Public, Templates, and
Videos.

Hidden items directly inside the home directory and standard folders are
preserved. Non-standard folders and visible subfolders inside standard folders
are removed completely, including their hidden contents. The folder containing
the scripts is preserved. The cleaner only runs on Linux and refuses home
directories outside `/home/`.

## Test in Docker

This optional test mounts only a disposable demo folder, not your real home:

```bash
docker build -t pi-home-cleaner .
mkdir -p docker-demo/Desktop
touch docker-demo/Desktop/test.txt
docker run --rm -it -v "$PWD/docker-demo:/home/cleaner" pi-home-cleaner
```

The test file is deleted by the cleaner. Do not replace the demo-folder mount
with your actual home directory.
