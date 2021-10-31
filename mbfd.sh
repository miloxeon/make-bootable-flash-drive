#!/bin/bash

if [[ "$1" == '--help' ]]; then
   echo "Usage: mbfd [options]"
	echo "       mbfd <./path/to/disk/image.iso>"
	echo ""
	echo "Options:"
	echo "  --help:	display this message"
	echo "  --restore:	restore a flash drive so it can be used like before"
	echo ""
	echo "'sudo mbfd ./image.iso' will start the interactive ISO flashing process. Note the sudo!"
   exit 1
fi

if [[ "$1" == '--restore' ]]; then
	echo "Select flash drive to restore:"
	echo ""
	# display a list of external devices (flash drives)
	diskutil list external
	echo ""

	# ask for flash drive name
	echo ""
	read -p 'Your flash drive device name (something like "/dev/disk4" without quotes): ' flashDriveName

	echo ""
	read -p "The device you entered will be erased. Is that ok? (yes/no): " confirmation
	if [ "$confirmation" != 'yes' ] 
	then
		exit 0
	fi

	# make a GPT partition
	diskutil partitionDisk $flashDriveName GPT FAT32 UNTITLED 0b

	echo ""
	echo "Success!"

   exit 1
fi

# check if not root
if [[ $EUID -ne 0 ]]; then
   echo "This program must be run as root" 
   exit 1
fi

echo "This program will help you to make a bootable USB drive from the ISO disk image."
echo "This program will do the following:"
echo ""
echo "1. Display the list of your devices"
echo "2. Ask you for the name of your flash drive. Make sure you enter the correct name, otherwise the data loss will be catastrophic."
echo "3. Erase your flash drive and make it a GPT disk"
echo "4. Flash your ISO image to your flash drive"
echo "5. Eject your flash drive"
echo ""
echo "After that, you can boot up from your flash drive."
echo ""
echo "[Press Any Key]"

read

# display a list of external devices (flash drives)
diskutil list external

# ask for flash drive name
echo ""
read -p 'Your flash drive device name (something like "/dev/disk4" without quotes): ' flashDriveName

echo ""
read -p "The device you entered will be erased. Is that ok? (yes/no): " confirmation
if [ "$confirmation" != 'yes' ] 
then
	exit 0
fi

# make a GPT partition
diskutil partitionDisk $flashDriveName GPT JHFS+ liveusb 0b

# convert disk image for etching
hdiutil convert -format UDRW -o ./temp $1

# unmount drive
diskutil unmountDisk $flashDriveName

# flash
echo ""
echo "Writing image data. This might take several minutes..."
dd if=temp.dmg of=$flashDriveName bs=1m

# remove temp image
rm temp.dmg

# eject
diskutil eject $flashDriveName

echo ""
echo "Success!"
