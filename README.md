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

The menu provides three tools:

- **Clean home directory** (`pi-clean.sh`) — removes visible files and
  non-standard folders from the Pi user's home, cleans visible contents of
  standard folders, empties Trash, and recreates standard folders. Hidden items
  directly inside the home or standard folders are preserved. Non-standard
  folders are removed entirely, including their hidden contents. This runs
  without confirmation and only on Linux. Do not run it unless you intend to
  permanently delete those files.
- **Install WiringPi** (`install-wiringpi.sh`) — installs build tools, builds
  the WiringPi Debian package in a temporary directory, and installs the
  package system-wide. The temporary source checkout is removed afterward.
- **Test blinking LEDs** (`test_led.sh`) — assembles and links
  `BlinkingLED_StudentExample.s` against WiringPi, runs the program with `sudo`
  for GPIO access, then removes the temporary object and executable files.
  Connect the LEDs to the GPIO pins specified in the assembly example before
  running this test.

Run `./pi-tools.sh` without `sudo`. The WiringPi installer asks for `sudo`
for system package operations; the LED test uses `sudo` to run the GPIO program.
You can also run any of the three operation scripts directly.
