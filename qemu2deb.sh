#!/bin/bash

#check that script isn't being run as root.
if [ "$EUID" = 0 ]; then
  echo "You cannot run this script as root!"
  exit 1
fi

#variables
CORES="`nproc`"
#determine if host system is 64 bit arm64 or 32 bit armhf
if [ ! -z "$(file "$(readlink -f "/sbin/init")" | grep 64)" ];then
  SARCH=64
elif [ ! -z "$(file "$(readlink -f "/sbin/init")" | grep 32)" ];then
  SARCH=32
else
  echo -e "$(tput setaf 1)$(tput bold)Can't detect OS architecture! something is very wrong!$(tput sgr 0)"
  exit
fi

#script version variable
APPVER="0.1.2"

#functions
function intro() {
    echo -e "
    ##########################################
    #  QEMU2DEB $APPVER by Itai-Nelken | 2021  #
    #----------------------------------------#
    #     compile/package/install QEMU       #
    ##########################################
    "
}

function help() {
    echo "$(tput bold)$(tput setaf 6)usage:$(tput sgr 0)"
    echo "./qemu2deb.sh [flags]"
    echo " "
    echo "$(tput setaf 6)available flags:$(tput sgr 0)"
    echo "--version  -  display version and exit."
    echo "--help  -  display this help."
}

function install-deb() {
    read -p "do you want to install the DEB (y/n)?" choice
    case "$choice" in 
        y|Y ) CONTINUE=1 ;;
        n|N ) CONTINUE=0 ;;
        * ) echo "invalid" ;;
    esac

if [[ "$CONTINUE" == 1 ]]; then
    cd $DIRECTORY
    cd ..
    cd qemu
    sudo make uninstall
    cd $DIRECTORY
    sudo dpkg -i qemu-$QVER-$ARCH.deb
elif [[ "$CONTINUE" == 0 ]]; then
    clear
fi
}

function clean-up() {
echo -e "$(tput setaf 3)$(tput bold)cleaning up...$(tput sgr 0)"
sleep 0.3
read -p "do you want to delete the qemu build folder (y/n)?" choice
case "$choice" in 
  y|Y ) CONTINUE=1 ;;
  n|N ) CONTINUE=0 ;;
  * ) echo "invalid" ;;
esac

if [[ "$CONTINUE" == 1 ]]; then
    cd $QBUILD
    cd ..
    sudo rm -r qemu
elif [[ "$CONTINUE" == 0 ]]; then
    echo "won't remove $QBUILD"
fi

read -p "do you want to delete the unpacked DEB (y/n)?" choice
case "$choice" in 
  y|Y ) CONTINUE=1 ;;
  n|N ) CONTINUE=0 ;;
  * ) echo "invalid" ;;
esac

if [[ "$CONTINUE" == 1 ]]; then
    sudo rm -r qemu-$QVER-$ARCH
elif [[ "$CONTINUE" == 0 ]]; then
    echo "won't remove unpacked DEB"
fi
}

function install-depends() {
    sudo apt install -y build-essential ninja-build libepoxy-dev libdrm-dev libgbm-dev libx11-dev libvirglrenderer-dev libpulse-dev libsdl2-dev git libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev libepoxy-dev libdrm-dev libgbm-dev libx11-dev libvirglrenderer-dev libpulse-dev libsdl2-dev
}

function compile-qemu() {
    cd $DIRECTORY
    echo "cloning QEMU git repo..."
    git clone https://git.qemu.org/git/qemu.git
    cd qemu
    git submodule init
    git submodule update --recursive
    echo "running ./configure..."
    ./configure --enable-sdl  --enable-opengl --enable-virglrenderer --enable-system --enable-modules --audio-drv-list=pa --enable-kvm
    echo "compiling QEMU..."
    make -j$CORES
    sudo make install
}

function make-deb() {
    #get QEMU version
    QVER="`qemu-system-ppc --version | grep version | cut -c23-28`"
    #get arch
    if [[ "$SARCH" == 64 ]]; then
        ARCH=arm64
    elif [[ "$SARCH" == 32 ]]; then
     ARCH=armhf
    fi
    #get all files inside a folder before building deb
    clear
    echo "copying files..."
    echo -ne '(0%)[#                         ](100%)\r'
    cd $DIRECTORY
    mkdir qemu-$QVER-$ARCH
    cd qemu-$QVER-$ARCH
    mkdir -p usr/bin/
    cd usr
    echo -ne '(0%)[###                       ](100%)\r'
    sudo cp /usr/bin/qemu* $DIRECTORY/qemu-$QVER-$ARCH/usr/bin/
    mkdir -p lib/arm-linux-gnueabihf/qemu
    sudo cp -r /usr/lib/arm-linux-gnueabihf/qemu $DIRECTORY/qemu-$QVER-$ARCH/usr/lib/arm-linux-gnueabihf/
    sudo cp -r /usr/lib/qemu/ $DIRECTORY/qemu-$QVER-$ARCH/usr/lib/
    echo -ne '(0%)[########                  ](100%)\r'
    mkdir -p local/bin/
    mkdir -p local/lib/qemu
    mkdir -p local/share/qemu
    sudo cp /usr/local/bin/qemu* $DIRECTORY/qemu-$QVER-$ARCH/usr/local/bin/
    sleep 0.1
    echo -ne '(0%)[##########                ](100%)\r'
    sudo cp -r /usr/local/lib/qemu $DIRECTORY/qemu-$QVER-$ARCH/usr/local/lib/
    sleep 0.1
    echo -ne '(0%)[#############             ](100%)\r'
    sudo cp -r /usr/local/share/qemu/ $DIRECTORY/qemu-$QVER-$ARCH/usr/local/share/
    mkdir -p share/man/man1
    sudo cp /usr/share/man/man1/qemu*.1.gz $DIRECTORY/qemu-$QVER-$ARCH/usr/share/man/man1
    sleep 0.1
    echo -ne '(0%)[#################         ](100%)\r'
    mkdir -p share/openbios
    mkdir -p share/openhackware
    mkdir -p share/ovmf
    mkdir -p share/qemu
    mkdir -p share/slof
    sudo cp -r /usr/share/openbios/ $DIRECTORY/qemu-$QVER-$ARCH/usr/share/
    sudo cp -r /usr/share/openhackware/ $DIRECTORY/qemu-$QVER-$ARCH/usr/share/
    sleep 0.1
    echo -ne '(0%)[####################     ](100%)\r'
    sudo cp -r /usr/share/ovmf/ $DIRECTORY/qemu-$QVER-$ARCH/usr/share/
    sudo cp -r /usr/share/qemu/ $DIRECTORY/qemu-$QVER-$ARCH/usr/share/
    sudo cp -r /usr/share/slof/ $DIRECTORY/qemu-$QVER-$ARCH/usr/share/
    cd ..
    sleep 0.1
    echo -ne '(0%)[#########################](100%)\r'
    sleep 1
}


##########flags##########
if  [[ $1 = "--version" ]]; then
    intro
    exit
elif [[ $1 = "--help" ]]; then
    help
    exit
fi



##########The part where things actually start to happen##########

#clear the screen
clear
#run the "intro" function
intro
#print a blank line
echo ' '
#ask for directory path, if doesn't exist ask again. if exists exit loop.
while true;
    do
            read -p "Enter full path to directory where you want to make the deb:" DIRECTORY
            if [ ! -d $DIRECTORY ]; then
                    echo "directory does not exist, please try again"

            else
                    echo "$(tput bold)qemu will be built and packaged here: $DIRECTORY$(tput sgr 0)"
                    break
            fi
done

#sleep 3 seconds and clear the screen
sleep 2
echo " "
#ask if you already compiled QEMU, if yes enter full path (same as other loop), if you press s, the loop exits.
while true;
    do
            read -p "If you already compiled and installed QEMU (with sudo make install), enter the path to its folder. otherwise press s:" QBUILD
            if [[ "$QBUILD" == s ]]; then
                echo "QEMU will be compiled..."
                QBUILDV=1
                break
            fi
            if [ ! -d $QBUILD ]; then
                    echo "directory does not exist, please try again"

            else
                    echo "$(tput bold)qemu is already built here: $QBUILD$(tput sgr 0)"
                    QBUILDV=0
                    break
            fi
done

#if QEMU needs to be compiled, do so
if [[ "$QBUILDV" == 1 ]]; then
    echo -e "$(tput setaf 6)$(tput bold)QEMU will now be compiled, this will take over a hour and consume all CPU.$(tput sgr 0)"
    echo -e "$(tput setaf 6)$(tput bold)cooling is recommended.$(tput sgr 0)"
    read -p "Press [ENTER] to continue"
    install-depends
    compile-qemu
fi

sleep 3
#clear the screen again
clear
#print the summary so far and ask to continue
printf "$(tput bold)\\e[3;4;37mSummary:\\n\\e[0m$(tput sgr 0)"
echo "the DEB will be built here: $DIRECTORY"
if [[ "$QBUILDV" == 1 ]]; then
    echo "QEMU was compiled here: $DIRECTORY"
elif [[ "$QBUILDV" == 0 ]]; then
    echo "QEMU is already compiled here: $QBUILD"
fi
read -p "Press [ENTER] to continue or [CTRL+C] to cancel"


#start making the deb folder (unpacked deb)
echo -e "$(tput setaf 6)$(tput bold)QEMU will now be packaged into a DEB, this will take a few minutes and consume all CPU.$(tput sgr 0)"
echo -e "$(tput setaf 6) $(tput bold)cooling is recommended. $(tput sgr 0)"
read -p "Press [ENTER] to continue"
#compy all files using the 'make-deb' function
make-deb
echo "creating DEBIAN folder..."
mkdir DEBIAN
cd DEBIAN
sleep 2
clear
echo "creating control file..."
#ask for maintainer info
echo -e "$(tput setaf 3)$(tput bold)enter maintainer info:$(tput sgr 0)"
read MAINTAINER
clear

#create DEBIAN/control
echo "
Maintainer: $MAINTAINER 
Summary: QEMU $QVER armhf for the raspberry pi built using qemu2deb
Name: qemu 
Description: QEMU $QVER $ARCH built using QEMU2DEB for arm devices.
Version: $QVER 
Release: 1 
License: GPL 
Architecture: $ARCH 
Provides:qemu
Conflicts:qemu-utils, qemu-system-common, qemu-system-gui, qemu-system-ppc, qemu-block-extra, qemu-guest-agent, qemu-kvm, qemu-system-arm, qemu-system-common, qemu-system-mips, qemu-system-misc, qemu-system-sparc, qemu-system-x86, qemu-system, qemu-user-binfmt, qemu-user-static, qemu-user, qemu, openbios-sparc, openbios-ppc, seabios
Package: qemu" > control
#give it the necessary permissions
sudo chmod 775 control
cd ..
cd ..
#build the DEB
sudo dpkg-deb --build qemu-$QVER-$ARCH/

echo -e "$(tput setaf 3)$(tput bold)DONE...$(tput sgr 0)"
echo "qemu deb will be in $DIRECTORY/qemu-$QVER-$ARCH.deb"
read -p "Press [ENTER] to continue"
clear

#ask to install the deb snd then clean up
install-deb
clean-up

echo -e "$(tput setaf 2)$(tput bold)DONE...$(tput sgr 0)"
echo "exiting in 10 seconds..."
sleep 10
exit
