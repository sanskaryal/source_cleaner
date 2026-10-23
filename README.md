# Pi Home File Cleaner

I created this for GTAs to clean the lab Pis.

This project has two scripts:

- **`project-clean.sh` — unsafe, no confirmation:** immediately deletes `.s`
  and `.o` files plus executable files with no dot in their names, recursively
  under `$HOME`. Use only with a dedicated test folder or when you are certain
  you want those files deleted.
- **`pi-clean.sh` — cautious, interactive cleanup:** offers file-pattern
  choices, shows the matching files first, and only deletes them after you type
  `DELETE`. It can search recursively under `$HOME`.

Both scripts operate on the home directory provided to them. When testing with
Docker, mount a dedicated demo folder rather than your actual home directory.

## Run on the Pi

```bash
chmod +x pi-clean.sh
./pi-clean.sh
```

## Try it safely in Docker

```bash
docker build -t pi-home-cleaner .
docker run --rm -it pi-home-cleaner
```

The container searches its own disposable `/home/cleaner` directory. Do not
mount your Mac or Pi home directory into the container when testing.

## Run the no-confirmation project cleaner in Docker

Build the image and create a dedicated demo folder inside this project. Open it
in Finder so you can watch the files disappear. Only this demo folder is mounted
into Docker; your Mac home directory is not mounted.

```bash
docker build -t pi-home-cleaner .
mkdir -p docker-demo/Desktop/subfolder
touch docker-demo/Desktop/example.s docker-demo/Desktop/object.o docker-demo/Desktop/keep.txt
printf '#!/bin/sh\n' > docker-demo/Desktop/subfolder/runner
chmod +x docker-demo/Desktop/subfolder/runner
open docker-demo
docker run --rm -it -v "$PWD/docker-demo:/home/cleaner" pi-home-cleaner /usr/local/bin/project-clean
```

The output should show `example.s`, `object.o`, and `runner` deleted, with
`keep.txt` remaining in Finder. The container is removed when the command exits;
the `docker-demo` folder remains so you can inspect it or recreate the test files.

## Options

Choose a search pattern from the menu:

1. `*.*` — files whose names contain a dot.
2. `*.s` — assembly source files.
3. `*.o` and `*.s`.
4. `*.o`, `*.s`, and executable files whose names contain no dot.
5. Custom space-separated filename patterns, such as `*.s *.pdf`.

The search includes hidden subfolders. Patterns match file names (not paths).
The script only considers regular files; it does not remove directories. It
displays all matches before asking for the exact confirmation `DELETE`. Anything
else cancels the operation.

**Deletion is permanent.** Check the displayed list carefully before confirming.
