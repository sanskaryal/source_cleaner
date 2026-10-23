# Pi Home File Cleaner

I created this for GTAs to clean the lab Pis.

This project has one cleanup script: `pi-clean.sh`. It runs without asking for
confirmation. It removes files and folders directly inside the home directory
and clears the contents of the standard home folders, then ensures these folders
exist: Desktop, Documents, Downloads, Music, Pictures, Public, Templates, and
Videos. It also empties the standard Linux Trash.

Direct hidden items in the home directory and standard folders are preserved.
A non-standard visible folder is removed completely, including hidden items
nested inside it; visible subfolders inside standard folders are also removed
completely. The directory containing `pi-clean.sh` and its contents are
preserved. Trash contents are removed, including hidden items, except for the
script directory if it is inside Trash. The script only runs on Linux and
refuses targets outside `/home/`.

## Run on the Pi

```bash
chmod +x pi-clean.sh
./pi-clean.sh
```

## Test safely in Docker

Build the image and populate a dedicated demo folder inside this project. Open
it in Finder to inspect the test files before and after cleanup. Only this demo
folder is mounted into Docker; your Mac home directory is not mounted.

```bash
docker build -t pi-home-cleaner .
mkdir -p docker-demo/Desktop/subfolder docker-demo/.hidden docker-demo/OldProject/.config docker-demo/.local/share/Trash/files docker-demo/cleaner-project
cp pi-clean.sh docker-demo/cleaner-project/
touch docker-demo/Desktop/example.txt docker-demo/Desktop/.keep docker-demo/.hidden/config
touch docker-demo/OldProject/.config/settings docker-demo/.local/share/Trash/files/trashed-file
open docker-demo
docker run --rm -it -v "$PWD/docker-demo:/home/cleaner" pi-home-cleaner /home/cleaner/cleaner-project/pi-clean.sh
```

There is no confirmation prompt: the script immediately cleans the mounted
demo directory. The non-hidden `example.txt` and the entire `OldProject` folder should
disappear. Direct hidden items at the home root and inside standard folders
should remain, while Trash is emptied. The standard home folders should exist
afterward. The `cleaner-project` directory and its script should remain. The
container is removed when the command exits; `docker-demo` remains for
inspection.

**Do not mount your actual Mac or Pi home directory for this test.**

**Deletion is permanent and starts immediately.** Non-standard visible folders
and their contents are removed completely.
