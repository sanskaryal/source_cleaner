# Pi Home File Cleaner

I created this for GTAs to clean the lab Pis.

This project has one cleanup script: `pi-clean.sh`. It offers two cleanup
options, skips hidden directories, shows the matching files, asks before
deleting, and separately asks whether to empty the standard Linux Trash.

## Run on the Pi

```bash
chmod +x pi-clean.sh
./pi-clean.sh
```

## Test safely in Docker

Build the image and create a dedicated demo folder inside this project. Open it
in Finder to watch the test files. Only this demo folder is mounted into Docker;
your Mac home directory is not mounted.

```bash
docker build -t pi-home-cleaner .
mkdir -p docker-demo/Desktop/subfolder
touch docker-demo/Desktop/example.s docker-demo/Desktop/object.o docker-demo/Desktop/keep.txt
printf '#!/bin/sh\n' > docker-demo/Desktop/subfolder/runner
chmod +x docker-demo/Desktop/subfolder/runner
open docker-demo
docker run --rm -it -v "$PWD/docker-demo:/home/cleaner" pi-home-cleaner
```

Choose option `1`, confirm the listed deletions with `y`, then answer `n` to
leave the demo Trash alone (or `y` to test emptying it). `example.s`,
`object.o`, and `runner` should be deleted; `keep.txt` should remain in Finder.
The container is removed when the command exits; the `docker-demo` folder
remains so you can inspect it or recreate the test files.

## Cleanup options

1. `*.s`, `*.o`, and executable files with no extension.
2. `*.*` files and all executable files.

Both choices skip hidden directories and separately ask whether to empty the
standard Linux Trash. The file deletion prompt defaults to no. Cleanup only
removes regular files; it does not remove directories.

**Deletion is permanent.** Check the displayed list carefully before confirming.
