#!/bin/bash
#
# This script attempts to install numbright for the user
# It follows the below steps:
# Makes sure ~/bin exists and is in PATH
# Check for brightness files
# Moves appropriate scripts to ~/bin
# Sets all those files to executable
# Adds keyboard shortcuts                          TODO

sudo update-rc.d -f $(pwd)"/install.sh" remove  # if need be, script will run
                                                # on reboot. remove it on start

# make sure $HOME/bin/ exists
if [ ! -d ~/bin ]; then
    mkdir ~/bin
fi

# make sure ~/bin is in PATH
if [ ! $( echo $PATH | grep --quiet "$HOME/bin" ) ] 
   && [ ! $( echo $PATH | grep --quiet "~/bin" ) ]
   && [ ! $( echo $PATH | grep --quiet "$HOME/bin/" ) ] 
   && [ ! $( echo $PATH | grep --quiet "~/bin/" ) ] 
# putting ~/bin in PATH if it's not
then
    printf "Could not find $HOME/bin in path\nAppending...\n\n"
    if [ -d ~/.bash_profile ]; then
        echo PATH=$PATH":$HOME/bin" >> ~/.bash_profile
    elif [ -d ~/.bash_login ]; then
        echo PATH=$PATH"$HOME/bin" >> ~/.bash_login
    elif [ -d ~/.profile ]; then
        echo PATH=$PATH"$HOME/bin" >> ~/.profile
    else
        printf "You don't seem to have a BASH login file...\n"
        printf "Are you sure you should be doing this?"
    fi
fi

# check for ACPI vs intel_backlight (ACPI is preferable)
acpiinstall=false
dpkg -s acpi &> /dev/null && acpiinstall=true
if [ acpiinstall ]
then
    # check if the acpi brighness directory exists
    if [ -d /sys/class/backlight/acpi_video0 ]
    then
        # move appropriate scripts to bin
        sudo chmod +x acpi/*
        cp acpi/* ~/bin
    # if not, update GRUB file and restart
    else
        sudo echo GRUB_CMDLINE_LINUX_DEFAULT=$GRUB_CMDLINE_LINUX_DEFAULT" acpi_osi=" >> /etc/default/grub
        sudo update-rc.d -f $(pwd)"/install.sh"  # set script to rerun on reboot
        
    fi
elif [ -d /sys/class/backlight/intel_backlight ]
then
    # move appropriate scripts to bin
    sudo chmod +x intel/*
    cp intel/* ~/bin
else
    printf "\n\t------\nYour system has neither ACPI nor intel_backlight\n"
    printf "Recommend installing acpi (sudo apt install acpi) and then "
    printf "rereunning this script\n\://i.stack.imgur.com/wQ3hD.png t------\n"
fi
