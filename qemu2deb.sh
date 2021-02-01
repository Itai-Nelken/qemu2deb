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
APPVER="0.3.0"

#functions
function intro() {
    echo -e "
    ###########################################
    #  QEMU2DEB $APPVER by Itai-Nelken | 2021   #
    #-----------------------------------------#
    #     compile/package/install QEMU        #
    ###########################################
    "
}

function error() {
    echo -e "$(tput setaf 1)$(tput bold)$1$(tput sgr 0)"
    exit 1
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
    sudo apt -f -y install ./qemu-$QVER-$ARCH.deb || error "Failed to install the deb!"
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
    cd $QBUILD || error "Failed to change Directory!"
    cd .. || error "Failed to change Directory!"
    sudo rm -rf qemu || error "Failed to delete QEMU build folder!"
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
    sudo rm -r qemu-$QVER-$ARCH || error "Failed to delete unpacked deb!"
elif [[ "$CONTINUE" == 0 ]]; then
    echo "won't remove unpacked DEB"
fi
}

function install-depends() {
    sudo apt install -y build-essential ninja-build libepoxy-dev libdrm-dev libgbm-dev libx11-dev libvirglrenderer-dev libpulse-dev libsdl2-dev git libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev libepoxy-dev libdrm-dev libgbm-dev libx11-dev libvirglrenderer-dev libpulse-dev libsdl2-dev || error "Failed to install build dependencies!"
}

function compile-qemu() {
    cd $DIRECTORY || error "Failed to change directory!"
    echo "cloning QEMU git repo..."
    git clone https://git.qemu.org/git/qemu.git || error "Failed to clone QEMU git repo!"
    cd qemu || error "Failed to change Directory!"
    git submodule init || error "Failed to run 'git submodule init'"
    git submodule update --recursive || error "Failed to run 'git submodule update --recursive'!"
    echo "running ./configure..."
    ./configure --enable-sdl  --enable-opengl --enable-virglrenderer --enable-system --enable-modules --audio-drv-list=pa --enable-kvm || error "Failed to run './configure'!"
    echo "compiling QEMU..."
    make -j$CORES || error "Failed to run make -j$CORES!"
    sudo make install || error "Failed to run 'sudo make install'!"
}

function make-deb() {
    #get QEMU version
    QVER="`qemu-system-ppc --version | grep version | cut -c23-28`" || error "Failed to get QEMU version! is the full version installed?"
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
    cd $DIRECTORY || error "Failed to change directory to $DIRECTORY!"
    mkdir qemu-$QVER-$ARCH || error "Failed to create unpacked deb folder!"
    cd qemu-$QVER-$ARCH || error "Failed to change Directory to $DIRECTORY/qemu-$QVER-$ARCH!"
    mkdir -p usr/bin/ || error "Failed to create $DIRECTORY/qemu-$QVER-$ARCH/usr/bin!"
    cd usr || error "Failed to change Directory!"
    echo -ne '(0%)[###                       ](100%)\r'
    sudo cp /usr/bin/qemu* $DIRECTORY/qemu-$QVER-$ARCH/usr/bin/ || error "Failed to copy files! error info: line 134, /usr/bin/qemu*"
    mkdir -p lib/arm-linux-gnueabihf/qemu || error "Failed to create qemu-$QVER-$ARCH/lib/arm-linux-gnueabihf/qemu!"
    sudo cp -r /usr/lib/arm-linux-gnueabihf/qemu $DIRECTORY/qemu-$QVER-$ARCH/usr/lib/arm-linux-gnueabihf/ || error "Failed to copy files! error info: line 136, /usr/lib/arm-linux-gnueabihf/qemu"
    sudo cp -r /usr/lib/qemu/ $DIRECTORY/qemu-$QVER-$ARCH/usr/lib/ || error "Failed to copy files! error info: line 137, /usr/lib/qemu"
    echo -ne '(0%)[########                  ](100%)\r'
    mkdir -p local/bin/ || error "Failed to create qemu-$QVER-$ARCH/local/bin!"
    mkdir -p local/lib/qemu || error "Failed to create qemu-$QVER-$ARCH/local/lib/qemu!"
    mkdir -p local/share/qemu || error "Failed to create qemu-$QVER-$ARCH/local/share/qemu!"
    sudo cp /usr/local/bin/qemu* $DIRECTORY/qemu-$QVER-$ARCH/usr/local/bin/ || error "Failed to copy files! error info: line 142, /usr/local/bin/qemu*"
    sleep 0.1
    echo -ne '(0%)[##########                ](100%)\r'
    sudo cp -r /usr/local/lib/qemu $DIRECTORY/qemu-$QVER-$ARCH/usr/local/lib/ || error "Failed to copy files! error info: line 145, /usr/local/lib/qemu"
    sleep 0.1
    echo -ne '(0%)[#############             ](100%)\r'
    sudo cp -r /usr/local/share/qemu/ $DIRECTORY/qemu-$QVER-$ARCH/usr/local/share/ || error "Failed to copy files! error info: line 148, /usr/local/share/qemu"
    mkdir -p share/man/man1 || error "Failed to create qemu-$QVER-$ARCH/share/man/man1!"
    sudo cp /usr/share/man/man1/qemu*.1.gz $DIRECTORY/qemu-$QVER-$ARCH/usr/share/man/man1 || error "Failed to copy files! error info: line 150, /usr/share/man/man1/qemu*.1.gz"
    sleep 0.1
    echo -ne '(0%)[#################         ](100%)\r'
    mkdir -p share/openbios || error "Failed to create qemu-$QVER-$ARCH/share/openbios!"
    mkdir -p share/openhackware || error "Failed to create qemu-$QVER-$ARCH/share/openhackware!"
    mkdir -p share/ovmf || error "Failed to create qemu-$QVER-$ARCH/share/ovmf!"
    mkdir -p share/qemu || error "Failed to create qemu-$QVER-$ARCH/share/qemu!"
    mkdir -p share/slof || error "Failed to create qemu-$QVER-$ARCH/share/slof!"
    sudo cp -r /usr/share/openbios/ $DIRECTORY/qemu-$QVER-$ARCH/usr/share/ || error "Failed to copy files! error info: line 158, /usr/share/openbios"
    sudo cp -r /usr/share/openhackware/ $DIRECTORY/qemu-$QVER-$ARCH/usr/share/ || error "Failed to copy files! error info: line 159, /usr/share/man/man1/openhackware"
    sleep 0.1
    echo -ne '(0%)[####################     ](100%)\r'
    sudo cp -r /usr/share/ovmf/ $DIRECTORY/qemu-$QVER-$ARCH/usr/share/ || error "Failed to copy files! error info: line 162, /usr/share/ovmf"
    sudo cp -r /usr/share/qemu/ $DIRECTORY/qemu-$QVER-$ARCH/usr/share/ || error "Failed to copy files! error info: line 163, /usr/share/qemu"
    sudo cp -r /usr/share/slof/ $DIRECTORY/qemu-$QVER-$ARCH/usr/share/ || error "Failed to copy files! error info: line 164, /usr/share/slof"
    cd ..  || error "Failed to change Directory!"
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

#sleep 2 seconds and clear the screen
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

#wait 1.5 seconds and clear the screen
sleep 1.5
clear

#if QEMU needs to be compiled, do so
if [[ "$QBUILDV" == 1 ]]; then
    echo -e "$(tput setaf 6)$(tput bold)QEMU will now be compiled, this will take over a hour and consume all CPU.$(tput sgr 0)"
    echo -e "$(tput setaf 6)$(tput bold)cooling is recommended.$(tput sgr 0)"
    read -p "Press [ENTER] to continue"
    install-depends || error "Failed to run install-depends function"
    compile-qemu || error "Failed to run compile-qemu function"
elif [[ "$QBUILDV" == 0 ]]; then
    read -p "do you want to install QEMU (run 'sudo make install') (y/n)?" choice
    case "$choice" in 
      y|Y ) CONTINUE=1 ;;
      n|N ) CONTINUE=0 ;;
      * ) echo "invalid" ;;
    esac
    if [[ "$CONTINUE" == 1 ]]; then
        cd $QBUILD || error "Failed to change directory to $QBUILD"
        sudo make install || error "Failed to run 'sudo make install'"
    elif [[ "$CONTINUE" == 0 ]]; then
        if [ ! command -v qemu-img &>/dev/null ];then
            echo "$(tput setaf 1)QEMU isn't installed! can't continue$(tput bold)$(tput sgr 0)"
            exit 1
        else
            echo "assuming QEMU is installed..."
        fi
    fi
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
#copy all files using the 'make-deb' function
make-deb || error "Failed to run make-deb function!"
echo "creating DEBIAN folder..."
mkdir DEBIAN || error "Failed to create DEBIAN folder!"
cd DEBIAN || error "Failed to change to DEBIAN folder!"
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
Version: 1:$QVER 
Release: 1 
License: GPL 
Architecture: $ARCH 
Provides:qemu
Conflicts:qemu-utils, qemu-system-common, qemu-system-gui, qemu-system-ppc, qemu-block-extra, qemu-guest-agent, qemu-kvm, qemu-system-arm, qemu-system-common, qemu-system-mips, qemu-system-misc, qemu-system-sparc, qemu-system-x86, qemu-system, qemu-user-binfmt, qemu-user-static, qemu-user, qemu, openbios-sparc, openbios-ppc, openbios-sparc, seabios, openhackware, qemu-slof, ovmf
Package: qemu" > control || error "Failed to create control file!"
#give it the necessary permissions
sudo chmod 775 control || error "Failed to change control file permissions!"
cd .. || error "Failed to change Directory!"
cd .. || error "Failed to change Directory!"
#build the DEB
sudo dpkg-deb --build qemu-$QVER-$ARCH/ || error "Failed to build the deb using dpkg-deb!"

echo -e "$(tput setaf 3)$(tput bold)DONE...$(tput sgr 0)"
echo "qemu deb will be in $DIRECTORY/qemu-$QVER-$ARCH.deb"
read -p "Press [ENTER] to continue"
clear

#ask to install the deb snd then clean up
install-deb || error "Failed to run install-deb function!"
clean-up || error "Failed to run clean-up function!"

echo -e "$(tput setaf 2)$(tput bold)DONE...$(tput sgr 0)"
echo "exiting in 10 seconds..."
sleep 10
exit
