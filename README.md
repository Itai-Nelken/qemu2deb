# qemu2deb-RPi
Compile/package/install QEMU easier than ever on the Raspberry Pi.
### This script was only tested on a Raspberry Pi 4 4gb running TwisterOS, the script should work on any armhf OS though.<br>the script will be tested on arm64 as well in the very near future.
## **THIS SCRIPT WILL NOT WORK ON A X86 COMPUTER!**
to package QEMU for x86 use checkinstall.

## Usage:
1) Download the script.
2) give it executable permissions: `sudo chmod +x qemu2deb.sh`
3) run the script: `./qemu2deb.sh`<br>
**For a full walkthrough, read [USAGE.md](USAGE.md)**

## How it works
First the script asks you where is your working directory, then if you tell it QEMU isn't compiled and installed yet, it will compile and install it.
after it has the QEMU directory and your working directory and QEMU is installed on your system, it will copy all the QEMU files to a temporary folder, create the DEBIAN/control file and package the temporary folder to a deb using `dpkg-deb`.
after packaging is complete, the script will clean up after itself.

## [Changelog](CHANGELOG.md)

## compatibility list:

| OS | ARCHITECTURE | SHOULD WORK | TESTED AND WORKS | TESTED AND NOT WORKING |
| :---: | :---:        |     :---:      |         :---: |         :---:       |
| TwisterOS | armhf | yes   | works perfectly fine | N/A |
| RPiOS | armhf | yes | N/A | N/A |
| RPiOS 64bit beta | arm64 | maybe | N/A | N/A |
| Ubuntu 64bit (stock, MATE, etc.) | arm64 | maybe | N/A | N/A |

### Tested on another OS and have problems? feel free to open a issue [here](https://github.com/Itai-Nelken/qemu2deb-RPi/issues/new)!
### Used on one of the OS's on the table above but the script isn't working? feel free to open a issue [here](https://github.com/Itai-Nelken/qemu2deb-RPi/issues/new)!
### have a fix, suggestion or a bug to report? feel free to open a issue or a Pull request!
