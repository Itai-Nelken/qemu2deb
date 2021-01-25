# qemu2deb-RPi
Compile/package/install QEMU easier than ever on the Raspberry Pi.

## Usage:
1) Download the script.
2) give it executable permissions: `sudo chmod +x qemu2deb.sh`
3) run the script: `./qemu2dev.sh`<br>
**For more detailed instructions, read [USAGE.md](USAGE.md)**

## How it works
First the script asks you where is your working directory, then if you tell it QEMU isn't compiled and installed yet, it will compile and install it.
after it has the QEMU directory and your working directory and QEMU is installed on your system, it will copy all the QEMU files to a temporary folder, create the DEBIAN/control file and package the temporary folder to a deb using `dpkg-deb`.
after packaging is complete, the script will clean up.

## [Changelog](CHANGELOG.md)
