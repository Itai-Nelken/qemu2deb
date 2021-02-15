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

### 31/1/2021
update release to 0.2! - fixed apt thinking its downgrading.
slight update to the `install-deb` function. releases are not marked as pre-releases anymore!
opened 'Dev' branch for testing without breaking what is already working.
added 'error' function to report errors in a easy to understand format and exit.
getting ready to merge the Dev branch to main and bump version to 0.3.0!

### 1/2/2021
Update release to 0.3.0!

### 9/2/2021
update release to 0.3.1 - added `priority` and `section` to control file.

### 14/2/2021
update release to 0.3.2 - add shorter versions of flags (`-h` = `--help`, `-v` = `--version`).
the script now checks if you are on a armhf OS, else t will warn you and exit. to disable checking, use the `--no-check-arch` flag (also added).
qemu2deb is now available as a deb! (I also added a deb to all the old releases).

### 15/2/2021
Update to 0.3.3 - The help printed when using the `--help` flag is more extensive and now includes instructions on how to use if you installed qemu2deb from the deb.
