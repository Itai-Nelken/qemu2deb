#!/bin/bash

                         ######LICENSE######
#           qemu2deb.sh - compile and package QEMU into a .deb
#         =======================================================
#          Copyright (C) 2021  Itai-Nelken <itainelken@gmail.com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.
#


#######TO DO#######
# 1) cp-files: add error handling
# 2) latest release (5.2 (or 6.0-rc2??? (5.2.92))) or latest from git (compile-qemu function).
# 3) qemu2deb, not ./qemu2deb.sh in help function ($0 doesn't work).
# 4) https://github.com/Itai-Nelken/qemu2deb/projects/2

######DONE######
# 1) install-deb depracated and removed. clean-up does the work now. done.
# 2) clean-up. done.
# 3) compile-qemu: cd to where??: QBUILD. done.
# 4) make sure new error function is being used, (warning function depracated and removed). done.
# 5) rename make-deb to cp-files. done.
# 6) color variables. done.
# 2) finish ctrl_c function. done.

######VARIABLES######
# DIRECTORY - where to package deb
# QBUILD - where to build QEMU/where qemu was built
# QBUILDV - 1 or 0, compile qemu or not?
# PROG - (progress) 1,2,3,4,5,6,7,8,9,10,11 in what stage the script is? used for the ctrl_c function.

#####PROG variable values######
# 0 - before flags.
# 1 - after asking for DIRECTORY.
# 2 - after asking if QEMU is compiled or no (QBUILD, QBUILDV).
# 3 - after asking for directory to compile QEMU.
# 4 - after installing QEMU build dependencies.
# 5 - after running the compile-qemu function.
# 6 - after running 'sudo ninja install -C build' and QEMU wasn't compiled by the script (probably isn't run).
# 7 - after running 'cp-files' function.
# 8 - after creating the DEBIAN folder and entering it.
# 9 - after asking for maintainer or using pre-given one (using the flag).
# 10 - after creating the control file and giving it 775 permissions.
###11 - after building the deb.###
# 11 - after running the 'clean-up' function.


function ctrl_c() {
    echo -e "\e[1m[CTRL+C detected!\e[0m"
    exit 1
    # test script here, it doesn't run currently as it isn't finished. comment out the 'exit 1' command aboce to test it.
    case $PROG in
        1|2|3|11)
            echo -e "\e[1m\e[31m[CTRL+C] detected! exiting...\e[0m"
            exit 1
        ;;
        4)
            echo -e "\e[1m\e[31m[CTRL+C] detected! cleaning up...\e[0m"
            pkg-manage uninstall "$TOINSTALL"
            exit 1
        ;;
        5)
            echo -e "\e[1m\e[31m[CTRL+C] detected! cleaning up...\e[0m"
            while true; do
                echo -ne "\e[1mdo you want to uninstall QEMU (run 'sudo ninja uninstall -C build') [y/n]?"
                read answer
                case answer in
                    y|Y|yes|YES|Yes|yEs|yeS)
                        cd "$QBUILD/qemu"
                        sudo ninja uninstall -C builds
                        break
                        ;;
                    n|N|no|No|nO)
                        echo "OK"
                        sleep 0.3
                        break
                    ;;
                    *)
                    echo -e "\e[1m\e[33minvalid answer '$answer'! please try again\e[0m"
                    ;;
                esac
            done
            while true; do
                echo -ne "\e[1mdo you want to delete the QEMU build folder [y/n]?"
                read answer
                case answer in
                    y|Y|yes|YES|Yes|yEs|yeS)
                        cd "$QBUILD/"
                        rm -rf qemu/ || sudo rm -rf qemu/
                        break
                        ;;
                    n|N|no|No|nO)
                        echo "OK"
                        sleep 0.3
                        break
                    ;;
                    *)
                    echo -e "\e[1m\e[33minvalid answer '$answer'! please try again\e[0m"
                    ;;
                esac
            done
            while true; do
                echo -ne "\e[1mdo you want to uninstall the QEMU build dependencies [y/n]?"
                read answer
                case answer in
                    y|Y|yes|YES|Yes|yEs|yeS)
                        pkg-manage uninstall "$TOINSTALL"
                        break
                        ;;
                    n|N|no|No|nO)
                        echo "OK"
                        sleep 0.3
                        break
                    ;;
                    *)
                    echo -e "\e[1m\e[33minvalid answer '$answer'! please try again\e[0m"
                    ;;
                esac
            done
            exit 1
        ;;
        6)
            echo -e "\e[1m\e[31m[CTRL+C] detected!\e[0m"
            echo "won't delete anything."
            exit 1
        ;;
        7|8|9|10)
            echo -e "\e[1m\e[31m[CTRL+C] detected!\e[0m"
            sleep 0.2
            while true; do
                echo -ne "\e[1mdo you want to uninstall QEMU (run 'sudo ninja uninstall -C build') [y/n]?"
                read answer
                case answer in
                    y|Y|yes|YES|Yes|yEs|yeS)
                        cd "$QBUILD/qemu"
                        sudo ninja uninstall -C builds
                        break
                        ;;
                    n|N|no|No|nO)
                        echo "OK"
                        sleep 0.3
                        break
                    ;;
                    *)
                    echo -e "\e[1m\e[33minvalid answer '$answer'! please try again\e[0m"
                    ;;
                esac
            done
            while true; do
                echo -ne "\e[1mdo you want to delete the QEMU build folder [y/n]?"
                read answer
                case answer in
                    y|Y|yes|YES|Yes|yEs|yeS)
                        cd "$QBUILD/"
                        rm -rf qemu/ || sudo rm -rf qemu/
                        break
                        ;;
                    n|N|no|No|nO)
                        echo "OK"
                        sleep 0.3
                        break
                    ;;
                    *)
                    echo -e "\e[1m\e[33minvalid answer '$answer'! please try again\e[0m"
                    ;;
                esac
            done
            while true; do
                echo -ne "\e[1mdo you want to uninstall the QEMU build dependencies [y/n]?"
                read answer
                case answer in
                    y|Y|yes|YES|Yes|yEs|yeS)
                        pkg-manage uninstall "$TOINSTALL"
                        break
                        ;;
                    n|N|no|No|nO)
                        echo "OK"
                        sleep 0.3
                        break
                    ;;
                    *)
                    echo -e "\e[1m\e[33minvalid answer '$answer'! please try again\e[0m"
                    ;;
                esac
            done
            while true; do
                echo -ne "\e[1mdo you want to delete the unpacked deb [y/n]?"
                read answer
                case answer in
                    y|Y|yes|YES|Yes|yEs|yeS)
                        cd $DIRECTORY
                        sudo rm -rf qemu-$QVER-$ARCH/
                        break
                        ;;
                    n|N|no|No|nO)
                        echo "OK"
                        sleep 0.3
                        break
                    ;;
                    *)
                    echo -e "\e[1m\e[33minvalid answer '$answer'! please try again\e[0m"
                    ;;
                esac
            done
            exit 1
        ;;
    esac 
}
#make the ctr_c function run if ctrl+c is pressed
trap "ctrl_c" 2

#check that script isn't being run as root.
if [ "$EUID" = 0 ]; then
  echo "You cannot run this script as root!"
  exit 1
fi

#variables
#CORES="$(nproc)"
#script version
APPVER="0.7.0"
#QEMU build dependencies
DEPENDS="build-essential ninja-build libepoxy-dev libdrm-dev libgbm-dev libx11-dev libvirglrenderer-dev libpulse-dev libsdl2-dev git libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev libepoxy-dev libdrm-dev libgbm-dev libx11-dev libvirglrenderer-dev libpulse-dev libsdl2-dev"
#text formatting
bold="\e[1m"
red="\e[31m"
green="\e[32m"
yellow="\e[33m"
light_cyan="\e[96m"
normal="\e[0m"

#check that OS arch is armhf
ARCH="$(uname -m)"
if [[ "$ARCH" == "x86_64" ]] || [[ "$ARCH" == "amd64" ]] || [[ "$ARCH" == "x86" ]] || [[ "$ARCH" == "i386" ]]; then
    if [ ! -z "$(file "$(readlink -f "/sbin/init")" | grep 64)" ];then
        ARCH="amd64"
    elif [ ! -z "$(file "$(readlink -f "/sbin/init")" | grep 32)" ];then
        ARCH="i386"
    else
        echo -e "${red}${bold}Can't detect OS architecture! something is very wrong!${normal}"
        exit 1
    fi
elif [[ "$ARCH" == "aarch64" ]] || [[ "$ARCH" == "arm64" ]] || [[ "$ARCH" == "armv7l" ]] || [[ "$ARCH" == "armhf" ]]; then
    if [ ! -z "$(file "$(readlink -f "/sbin/init")" | grep 64)" ];then
        ARCH="arm64"
    elif [ ! -z "$(file "$(readlink -f "/sbin/init")" | grep 32)" ];then
        ARCH="armhf"
    else
        echo -e "${red}${bold}Can't detect OS architecture! something is very wrong!${normal}"
        exit 1
    fi
else
    echo -e "${red}${bold}ERROR: '$ARCH' isn't a supported architecture!${normal}"
    exit 1
fi

#get machine name (aka Raspberry Pi detection)
RPI=$(grep ^Model /proc/cpuinfo  | cut -d':' -f2- | sed 's/ R/R/')
if [[ "$RPI" == *"Raspberry Pi"* ]]; then
    DEVICE="the Raspberry Pi and other $ARCH devices"
else
    DEVICE="Linux $ARCH devices."
fi

#functions
function intro() {
    #added extra 5 "spaces" for '-beta'
    echo -e "
    ################################################
    #  QEMU2DEB $APPVER-beta by Itai-Nelken | 2021   #
    #----------------------------------------------#
    #      compile/package/install QEMU            #
    ################################################
    "
}

function error() {
    ######USAGE:######
    # 1) error "text" - will print the text in red and bold and exit.
    # 2) error exit "text" - same as above.
    # 3) error sleep "text" 2 - will print the text in red and bold and sleep for the amount of seconds in $3, '2' in this example.
    # 4) error sleep-exit "text" 2 - same as above but will exit.
    # 5) error warn "text" 2 - print the text in yellow and bold and sleep for the amount of time passed to it in $3 (2 in this example).
    if [[ "$1" == "exit" ]]; then
        >&2 echo -e "${red}${bold}$2${normal}"
        exit 1
    elif [[ "$1" == "sleep" ]]; then
        >&2 echo -e "${red}${bold}$2${normal}"
        sleep $3
    elif [[ "$1" == "sleep-exit" ]]; then
        >&2 echo -e "${red}${bold}$2${normal}"
        sleep $3
        exit 1
    elif [[ "$1" == "warn" ]]; then
        >&2 echo -e "${yellow}${bold}$2${normal}"
        sleep $3 2>/dev/null
    else
        >&2 echo -e "${red}${bold}$1${normal}"
        exit 1
    fi
}

function help() {
    #usage
    echo -e "${light_cyan}${bold}usage:${normal}"
    echo "./qemu2deb.sh [flags]"
    #new line
    echo " "
    #available flags
    echo -e "${light_cyan}available flags:${normal}"
    echo "--version  -  display version and exit."
    echo "--help  -  display this help."
    echo "--maintainer=<string> - enter maintainer name. ${bold}EXAMPLE USAGE:${normal} --maintainer=\"maintainer name <email@example.com>\""
    #short flags
    echo -e "${bold}You can also use shorter versions of the flags:${normal}"
    echo "-h = --help"
    echo "-v = --version"
    #about architectures
    echo -e "${bold}Compatibility:${normal}"
    echo -e "this script only works on ${bold}armhf (arm32), arm64 (aarch64), x86 (i386), x86_64 (amd64)${normal} OS's,"
}

function clean-up() {
    echo -e "${yellow}${bold}cleaning up...${normal}"
    sleep 0.1
    #error warn "The clean-up function isn't finished yet!" 5
    #answer = empty string so if something happens and no user input comes, it will give the error that its incorrect answer.
    answer=''
    #uninstall QEMU
    while true; do
        echo -ne "Do you want to uninstall QEMU ${bold}(recommended)${normal} [y/n]?"
        read -r answer
        if [[ "$answer" =~ [yY] ]]; then
            if [[ "$QBUILDV" == "1" ]]; then
                cd "$QBUILD/qemu"
                sudo ninja uninstall -C build
            else
                cd "$QBUILD"
                sudo ninja uninstall -C build
            fi
            break
        elif [[ "$answer" =~ [nn] ]]; then
            echo "OK"
            sleep 0.2
            break
        else
            echo -e "${bold}invalid answer '$answer', please try again.${normal}"
        fi
    done
    #answer = empty string so if something happens and no user input comes, it will give the error that its incorrect answer.
    answer=''
    #install QEMU from the deb
    while true; do
        echo -ne "Do you want to install QEMU from the deb? [y/n]?"
        read -r answer
        if [[ "$answer" =~ [yY] ]]; then
            cd "$DIRECTORY" || error "Failed to change directory to \"$DIRECTORY\""
            sudo apt -fy install ./qemu-$QVER-$ARCH.deb || error "Failed to install QEMU from the deb!"
            break
        elif [[ "$answer" =~ [nn] ]]; then
            echo "OK"
            sleep 0.2
            break
        else
            echo -e "${bold}invalid answer '$answer', please try again.${normal}"
        fi
    done
    #answer = empty string so if something happens and no user input comes, it will give the error that its incorrect answer.
    answer=''
    #remove QEMU build folder
    while true; do
        echo -ne "Do you want to delete the QEMU build folder [y/n]?"
        read -r answer
        if [[ "$answer" =~ [yY] ]]; then
            if [[ "$QBUILDV" == "1" ]]; then
                cd "$QBUILD"
                rm -r qemu/ || sudo rm -rf qemu/
            else
                cd "$QBUILD"
                cd ../
                rm -r qemu || sudo rm -rf qemu/
            fi
            break
        elif [[ "$answer" =~ [nn] ]]; then
            echo "OK"
            sleep 0.2
            break
        else
            echo -e "${bold}invalid answer '$answer', please try again.${normal}"
        fi
    done
    #answer = empty string so if something happens and no user input comes, it will give the error that its incorrect answer.
    answer=''
    #remove unpacked deb folder
    while true; do
        echo -ne "Do you want to delete the unpacked deb folder [y/n]?"
        read -r answer
        if [[ "$answer" =~ [yY] ]]; then
            cd "$DIRECTORY"
            rm -r qemu-$QVER-$ARCH/ || rm -rf qemu-$QVER-$ARCH/ || sudo rm -rf qemu-$QVER-$ARCH/
            break
        elif [[ "$answer" =~ [nn] ]]; then
            echo "OK"
            sleep 0.2
            break
        else
            echo -e "${bold}invalid answer '$answer', please try again.${normal}"
        fi
    done
    #answer = empty string so if something happens and no user input comes, it will give the error that its incorrect answer.
    answer=''
    #remove QEMU build dependencies
    if [[ "$QBUILD" == "1" ]]; then
        while true; do
        eho -e "\e[1mThe following dependencies where installed to compile QEMU: \"\e[34m$TOINSTALL\e[0m\e[1m\"\e[0m"
            echo -ne "Do you want to uninstall them [y/n]?"
            read -r answer
            if [[ "$answer" =~ [yY] ]]; then
                pkg-manage remove "$TOINSTALL"
                break
            elif [[ "$answer" =~ [nn] ]]; then
                echo "OK"
                sleep 0.2
                break
            else
                echo -e "${bold}invalid answer '$answer', please try again.${normal}"
            fi
        done
    fi
}

function pkg-manage() {
    #usage: pkg-manage install "package1 package2 package3"
    #pkg-manage uninstall "package1 package2 package3" OR pkg-manage remove "package1 package2 package3"
    #pkg-manage check "packag1 package2 package3"
    #pkg-manage clean
    #
    #$1 is the operation: install or uninstall
    #$2 is the packages to operate on.
    if [[ "$1" == "install" ]]; then
        TOINSTALL="$(dpkg -l $2 2>&1 | awk '{if (/^D|^\||^\+/) {next} else if(/^dpkg-query:/) { print $6} else if(!/^[hi]i/) {print $2}}' | tr '\n' ' ')"
        sudo apt -f -y install $TOINSTALL || sudo apt -f -y install "$TOINSTALL"
    elif [[ "$1" == "uninstall" ]] || [[ "$1" == "remove" ]]; then
        sudo apt purge $2 -y
    elif [[ "$1" == "check" ]]; then
        TOINSTALL="$(dpkg -l $2 2>&1 | awk '{if (/^D|^\||^\+/) {next} else if(/^dpkg-query:/) { print $6} else if(!/^[hi]i/) {print $2}}' | tr '\n' ' ')"  
    elif [[ "$1" == "clean" ]]; then
        sudo apt clean
        sudo apt autoremove -y
        sudo apt autoclean
    else
        error sleep "operation not specified!" 1
    fi
}

function compile-qemu() {
    cd "$QBUILD" || error "Failed to change directory!"
    while true; do
        break
    done

    echo -e "$(tput setaf 6)cloning QEMU git repo...$(tput sgr 0)"
    git clone https://git.qemu.org/git/qemu.git || error "Failed to clone QEMU git repo!"
    cd qemu || error "Failed to change Directory!"
    git submodule init || error "Failed to run 'git submodule init'"
    git submodule update --recursive || error "Failed to run 'git submodule update --recursive'!"
    echo "$(tput setaf 6)running ./configure...$(tput sgr 0)"
    ./configure --enable-sdl  --enable-opengl --enable-virglrenderer --enable-system --enable-modules --audio-drv-list=pa --enable-kvm || error "Failed to run './configure'!"
    echo "$(tput setaf 6)compiling QEMU...$(tput sgr 0)"
    #make -j$CORES || error "Failed to run make -j$CORES!"
    #sudo make install || error "Failed to run 'sudo make install'!"
    ninja -C build  || error "Failed to run ninja -C build'!"
    echo -e "$(tput setaf 6)nstalling QEMU...$(tput sgr 0)"
    sudo ninja install -C build || error "Failed to install QEMU with 'sudo ninja install -C build'!"
}


function cp-files() {
    #get QEMU version
    QVER="$(qemu-system-ppc --version | grep version | cut -c23-28)" || QVER="$(qemu-system-i386 --version | grep version | cut -c23-28)" || QVER="$(qemu-system-arm --version | grep version | cut -c23-28)" || error "Failed to get QEMU version! is the full version installed?"
    #get all files inside a folder before building deb
    clear -x
    echo "copying files..."
    echo -ne '(0%)[#                         ](100%)\r'
    sleep 0.1
    cd $DIRECTORY || error "Failed to change directory to $DIRECTORY!"
    mkdir qemu-$QVER-$ARCH || error "Failed to create unpacked deb folder!"
    echo -ne '(0%)[##                        ](100%)\r'
    sleep 0.1
    cd qemu-$QVER-$ARCH || error "Failed to change Directory to $DIRECTORY/qemu-$QVER-$ARCH!"
    #mkdir -p usr/include/linux/ || error "Failed to create $DIRECTORY/qemu-$QVER-$ARCH/usr/include/linux/!"
    #cp /usr/include/linux/qemu_fw_cfg.h qemu-$QVER-$ARCH/usr/include/linux/
    sleep 0.1
    echo -ne '(0%)[###                       ](100%)\r'
    mkdir -p usr/bin
    cp /usr/local/bin/qemu* $DIRECTORY/qemu-$QVER-$ARCH/usr/bin
    mkdir -p usr/lib/
    sudo cp -r /usr/local/lib/qemu/ $DIRECTORY/qemu-$QVER-$ARCH/usr/lib
    mkdir -p usr/libexec
    cp /usr/local/libexec/qemu-bridge-helper $DIRECTORY/qemu-$QVER-$ARCH/usr/libexec
    sleep 0.1
    echo -ne '(0%)[########                  ](100%)\r'
    mkdir -p usr/share/
    cp -r /usr/local/share/qemu/ $DIRECTORY/qemu-$QVER-$ARCH/usr/share
    mkdir -p usr/share/applications
    cp /usr/local/share/applications/qemu.desktop $DIRECTORY/qemu-$QVER-$ARCH/usr/share/applications/
    sleep 0.1
    echo -ne '(0%)[##########                ](100%)\r'
    mkdir -p usr/share/icons/hicolor/16x16/apps
    mkdir -p usr/share/icons/hicolor/24x24/apps
    sleep 0.05
    echo -ne '(0%)[#############             ](100%)\r'
    sleep 0.1
    mkdir -p usr/share/icons/hicolor/32x32/apps
    mkdir -p usr/share/icons/hicolor/48x48/apps
    sleep 0.01
    echo -ne '(0%)[##############            ](100%)\r'
    mkdir -p usr/share/icons/hicolor/64x64/apps
    mkdir -p usr/share/icons/hicolor/128x128/apps
    echo -ne '(0%)[###############           ](100%)\r'
    mkdir -p usr/share/icons/hicolor/256x256/apps
    mkdir -p usr/share/icons/hicolor/512x512/apps
    sleep 0.1
    echo -ne '(0%)[################          ](100%)\r'
    mkdir -p usr/share/icons/hicolor/scalable/apps
    cp /usr/local/share/icons/hicolor/16x16/apps/qemu.png $DIRECTORY/qemu-$QVER-$ARCH/usr/share/icons/hicolor/16x16/apps
    cp /usr/local/share/icons/hicolor/24x24/apps/qemu.png $DIRECTORY/qemu-$QVER-$ARCH/usr/share/icons/hicolor/24x24/apps
    echo -ne '(0%)[###################       ](100%)\r'
    cp /usr/local/share/icons/hicolor/32x32/apps/qemu.bmp $DIRECTORY/qemu-$QVER-$ARCH/usr/share/icons/hicolor/32x32/apps
    cp /usr/local/share/icons/hicolor/32x32/apps/qemu.png $DIRECTORY/qemu-$QVER-$ARCH/usr/share/icons/hicolor/32x32/apps
    cp /usr/local/share/icons/hicolor/48x48/apps/qemu.png $DIRECTORY/qemu-$QVER-$ARCH/usr/share/icons/hicolor/48x48/apps
    cp /usr/local/share/icons/hicolor/64x64/apps/qemu.png $DIRECTORY/qemu-$QVER-$ARCH/usr/share/icons/hicolor/64x64/apps
    sleep 0.2
    echo -ne '(0%)[#####################     ](100%)\r'
    cp /usr/local/share/icons/hicolor/128x128/apps/qemu.png $DIRECTORY/qemu-$QVER-$ARCH/usr/share/icons/hicolor/128x128/apps
    cp /usr/local/share/icons/hicolor/256x256/apps/qemu.png $DIRECTORY/qemu-$QVER-$ARCH/usr/share/icons/hicolor/256x256/apps
    sleep 0.001
    echo -ne '(0%)[########################  ](100%)\r'
    cp /usr/local/share/icons/hicolor/512x512/apps/qemu.png $DIRECTORY/qemu-$QVER-$ARCH/usr/share/icons/hicolor/512x512/apps
    sleep 0.1
    echo -ne '(0%)[######################### ](100%)\r'
    cp /usr/local/share/icons/hicolor/scalable/apps/qemu.svg $DIRECTORY/qemu-$QVER-$ARCH/usr/share/icons/hicolor/scalable/apps
    sleep 0.1
    echo -ne '(0%)[##########################](100%)\r'
    sleep 0.5
}

##################################################################
##################################################################
##########The part where things actually start to happen##########
##################################################################
##################################################################

#set the progress variable to 0
PROG=0
##########flags##########
while [[ $# != 0 ]]; do
  case "$1" in
    -h|--help)
        help
        exit 0
        ;;
    --maintainer*)
        export MAINTAINER=$(echo $1 | sed -e 's/^[^=]*=//g')
        shift
        ;;
    --version | -v)
        intro
        exit 0
        ;;
    *)
      error "invalid option '$1'!"
      ;;
  esac
done

#clear -x the screen
clear -x
#run the "intro" function
intro
#print a blank line
echo ' '
#ask for directory path, if doesn't exist ask again. if exists exit loop.
while true; do
    read -rp "Enter full path to directory where you want to make the deb:" DIRECTORY
    if [ ! -d "$DIRECTORY" ]; then
        echo -e "\e[1mdirectory does not exist, please try again\e[0m"
    else
        echo -e "\e[1mqemu will be built and packaged here: $DIRECTORY\e[0m"
        break
    fi
done
PROG=1
echo " "
#ask if you already compiled QEMU, if yes enter full path (same as other loop), if you press s, the loop exits.
while true; do
    read -rp "If you already compiled and installed QEMU (with sudo ninja install -C build), enter the path to its folder. otherwise press s:" QBUILD
    if [[ "$QBUILD" == s ]]; then
        echo "QEMU will be compiled..."
        QBUILDV=1
        break
    fi
    if [[ ! -d $QBUILD ]]; then
        echo -e "\e[1mdirectory does not exist, please try again\e[0m"
    else
        echo -e "\e[1mqemu is already built here: $QBUILD\e[0m"
        QBUILDV=0
        break
    fi
done
PROG=2
if [[ "$QBUILDV" == "1" ]] && [[ "$QBUILD" == "s" ]]; then
    while true; do
        read -rp "Enter full path directory where you want to compile QEMU, you can use the same one as before: " QBUILD
        if [[ ! -d $QBUILD ]]; then
            echo -e "\e[1mdirectory does not exist, please try again\e[0m"
        else
            echo -e "\e[1mQEMU will be compiled here: $QBUILD\e[0m"
            break
        fi
    done
    PROG=3
    #check what dependencies aren't installed and install them
    pkg-manage install "$DEPENDS" || error "Failed to install dependencies"
    echo ' '
    PROG=4
    #compile qemu
    compile-qemu || error "Failed to run compile-qemu function"
    PROG=5
elif [[ "$QBUILDV" == 0 ]]; then
    read -rp "do you want to install QEMU (run 'sudo ninja install -C build') (y/n)?" choice
    case "$choice" in 
      y|Y ) CONTINUE=1 ;;
      n|N ) CONTINUE=0 ;;
      * ) echo "invalid" ;;
    esac
    if [[ "$CONTINUE" == 1 ]]; then
        cd $QBUILD || error "Failed to change directory to \"$QBUILD\""
        sudo ninja install -C build || error "Failed to run 'sudo ninja install -C build'"
    elif [[ "$CONTINUE" == 0 ]]; then
        if ! command -v qemu-img >/dev/null || ! command -v qemu-system-ppc >/dev/null || ! command -v qemu-system-i386 >/dev/null ;then
            error "QEMU isn't installed! can't continue!"
        else
            echo "assuming QEMU is installed..."
        fi
    fi
fi
PROG=6
sleep 0.5
#clear the screen again
clear -x
#print the summary so far and ask to continue
printf "\e[1m\\e[3;4;37mSummary:\\n\\e[0m"
echo "the DEB will be built here: $DIRECTORY"
if [[ "$QBUILDV" == 1 ]]; then
    echo "QEMU was compiled here: $QBUILD/qemu"
elif [[ "$QBUILDV" == 0 ]]; then
    echo "QEMU is already compiled here: $QBUILD"
fi
read -p "Press [ENTER] to continue or [CTRL+C] to cancel"

#start making the deb folder (unpacked deb)
echo -e "\e[96m\e[1mQEMU will now be packaged into a DEB, this will take a few minutes and consume all CPU.\e[0m"
echo -e "\e[96m\e[1mcooling is recommended.\e[0m"
read -p "Press [ENTER] to continue"
#copy all files using the 'cp-files' function
cp-files || error "Failed to run cp-files function!"
PROG=7
echo -e "\ncreating DEBIAN folder..."
mkdir DEBIAN || error "Failed to create DEBIAN folder!"
cd DEBIAN || error "Failed to change to DEBIAN folder!"
sleep 0.5
clear -x
PROG=8
echo -e "${light_cyan}creating control file...${normal}"
#ask for maintainer info only if the variable 'MAINTAINER' does not exist.
if [[ -z $MAINTAINER ]]; then
    echo -e "$(tput setaf 3)$(tput bold)enter maintainer info:$(tput sgr 0)"
    read -r MAINTAINER
    clear -x
else
    echo "maintainer is already set to '$MAINTAINER'..."
fi
PROG=9
#create DEBIAN/control
cd "$DIRECTORY/qemu-$QVER-$ARCH/DEBIAN"  || error "Failed to change directory to \"$DIRECTORY/qemu-$QVER-$ARCH/DEBIAN\""
echo "Maintainer: $MAINTAINER 
Summary: QEMU $QVER $ARCH for $DEVICE built using qemu2deb.
Name: qemu 
Description: QEMU $QVER $ARCH built using QEMU2DEB for $DEVICE.
Version: 1:$QVER 
Release: 1 
License: GPL 
Architecture: $ARCH 
Provides: qemu
Priority: optional
Section: custom
Recommends: bash-completion
Conflicts: qemu-utils, qemu-system-common, qemu-system-gui, qemu-system-ppc, qemu-block-extra, qemu-guest-agent, qemu-kvm, qemu-system-arm, qemu-system-common, qemu-system-mips, qemu-system-misc, qemu-system-sparc, qemu-system-x86, qemu-system, qemu-user-binfmt, qemu-user-static, qemu-user, qemu, openbios-sparc, openbios-ppc, openbios-sparc, seabios, openhackware, qemu-slof, ovmf
Package: qemu" > control || error "Failed to create control file!"
#give it the necessary permissions
sudo chmod 775 control || error "Failed to change control file permissions!"
PROG=10
cd "../.." || error "Failed to go 2 directories up!"
#build the DEB
sudo dpkg-deb --build qemu-$QVER-$ARCH/ || error "Failed to build the deb using dpkg-deb!"
sudo chmod 606 qemu-$QVER-$ARCH.deb || error warn "WARNING: Failed to give the deb '606' permissions!"

echo -e "${light_cyan}${bold}DONE...${normal}"
echo "The QEMU deb will be in $DIRECTORY/qemu-$QVER-$ARCH.deb"
read -rp "Press [ENTER] to continue"
clear -x

#clean up
clean-up || error "Failed to run clean-up function!"
PROG=11

echo -e "${green}${bold}DONE!${normal}"
sleep 0.5
exit 0
