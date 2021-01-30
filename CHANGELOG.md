# QEMU2DEB Changelog

**DD/MM/YY**

### 23/01/2021
I was struggling to package QEMU to a deb using all the tools I knew of.

### 24/01/2021
I found a easy way to package QEMU to a deb, and wrote this script.

### 25/01/2021
Initial upload, lots of bug fixes and quality of life improvements, first 2 releases (0.1.0, 0.1.1)!
at this point the script is fully functional but lacking some features I would like to add to it (like more control over the DEBIAN/control file).

### 30/1/2021
update release to 0.1.2: lots of minor changes and bug fixes.
added a lot of the conflicting packages to the deb's control file, understood why [`apt` thinks its downgrading](https://unix.stackexchange.com/questions/631805/how-to-hold-package-from-updating-with-posttest-script-in-deb) and getting ready to add a fix for the next major release.
added root detection - that means that the script won't let you run it as root.
