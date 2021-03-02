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
the script now checks if you are on a armhf OS, else it will warn you and exit. to disable checking, use the `--no-check-arch` flag (also added).
qemu2deb is now available as a deb! (I also added a deb to some of the old releases).

### 15/2/2021
Update to 0.3.3 - The help printed when using the `--help` flag is more extensive and now includes instructions on how to use if you installed qemu2deb from the deb.

### 19/2/2021
Released 0.4.0: GIANT UPDATES!
  1) better architecture detection: now the script checks if you are on armhf or arm64, if yes it checks if you are on a 32bit or 64bit OS.
  2) replace all `clear` commands with `clear -x` - that means its way easier to debug.
  3) updated the `install-deb` and `clean-up` function, now they work way better.
  4) replaced the `install-depends` function with `apt-install` and made a variable with all the dependencies, so now I can run: `apt-install $DEPENDS` to install all dependencies.
  5) replaced `make` with `ninja` for compiling qemu, its almost twice as fast.
  6) updated the`make-deb` function to make it work again. now the files it copies make more sense and will probably allow this script to work on arm64 and x86 OS's!
and probably a bit more I forgot to document.

### 21/2/2021
control file uses the "$ARCH" variable in the descritpion field.
Replaced the `apt-install` function with `pkg-manage` function, this new function allows me to install and uninstall packages. this function brings me to the next change: the script now asks you if you wan't to uninstall the dependencies when cleaning up after itself though it isn't recommended to do it yet because it will uninstall all the packages even if you had them installed before, that brings me to a change I'm working on: making the `pkg-manage` function remember wich packages it installed, and then ask to uninstall only the ones that it installed.
added support for x86 and x86_64!, arch checking is much simpler now as well.

### 22/2/2021
added Raspberry Pi detection that is used to decide what is the summary and description of the deb.
some fixes for x86_64 including changing the output of x86_64 to amd64 because its the correct way to put in the deb control file.
give the finished deb '606' permissions.

### 27/2/2021
made the `pkg-manage` function check what packages are installed from the list provided to it, and save the ones that aren't installed to the 'TOINSTALL' variable and install those.
also added to it a 'check' option to check what packages are installed and save them to the 'TOINSTALL' variable.
improve all the places where a question is asked, fixed a few typos, some quality of life improvements.

### 28/2/2021
impelement ctrl+c trapping: if you press ctrl+c the script will clean up after itself.

### 2/3/2021
make the script not copy any bash completion files as they are in the 'bash-completion' package, and including thme will cause the deb to fail to install.
add 'bash-completion' as a recommended package to the debs control file.
a few quality of life improvements.
