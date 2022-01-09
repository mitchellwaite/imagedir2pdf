#!/bin/bash

#set -x

# This script will download a sequence of images from a specific URL, starting from 1.jpg and continuing to the specified endpoint.
# It will then convert the individual images to OCR PDFs.
#
# This script requires the following packages to be installed: img2pdf, ocrmypdf, wget. awk is required too, usually that's included with the linux distro
#
# Installation (Ubuntu): sudo apt install img2pdf ocrmypdf wget
#

echo "Checking for dependencies:"
echo "=========================="

if [ $# -ne 2 ]
then
   echo "Usage: $0 <directory w/o trailing slash> <page count>"
   exit
fi

#Check path for needed executables

type -P img2pdf

if [ $? -ne 0 ]
then
   echo "This utility requires img2pdf, unable to continue."
   exit
fi

type -P ocrmypdf

if [ $? -ne 0 ]
then
   echo "This utility requires ocrmypdf, unable to continue."
   exit
fi

type -P wget

if [ $? -ne 0 ]
then
   echo "This utility requires wget, unable to continue."
   exit
fi

type -P awk

if [ $? -ne 0 ]
then
   echo "This utility requires awk, unable to continue."
   exit
fi

echo ""



# Parse the document ID from the URL 
directoryStr=`echo $1 | awk 'BEGIN { FS = "/" }; { print $6 }'`

read -p "The document identifier was detected as $directoryStr, does this look correct? (y/n): " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then 
   directoryStr=""
fi

echo ""

if [ -z "$directoryStr"]
then
   read -p "Unable to determine document ID, please input an identifier (no spaces!) and press enter: "

   if [ -z "$REPLY" ]
   then 
      echo "Can't have a blank identifier. Exiting."
      exit
   fi

   directoryStr="$REPLY"
   echo ""
fi

echo "Detected document ID:"
echo "====================="
echo $directoryStr
echo ""

imageDir=`echo $1 | sed 's![^/]*$!!'`

echo "Detected Image Directory:"
echo "========================="
echo $imageDir
echo ""

refererStr="https://$(echo $1 | awk 'BEGIN { FS = "/" }; { print $3 }')/"

echo "Detected Referer:"
echo "================="
echo $refererStr
echo ""

if [ -d $directoryStr ]
then
   read -p "Directory $directoryStr already exists. Would you like to overwrite the files on disk (y/n): " -n 1 -r
   if [[ ! $REPLY =~ ^[Yy]$ ]]
   then 
      exit
   fi
fi 

echo ""
echo ""

mkdir -p $directoryStr
mkdir -p $directoryStr/src


echo "Downloading images..."
echo "====================="

for (( i=1; i<=$2; i++ ))
do
#   wget --header="Referer:$refererStr" $1$i.jpg -O $directoryStr/src/$i.jpg
   echo $imageDir$i.jpg
done

exit

echo ""
echo "Creating full size PDF"
echo "======================"
img2pdf $(ls -v  $directoryStr/src/*.jpg) -o $directoryStr/$directoryStr.pdf && echo "Success!" || "Error, unable to create PDF."


echo ""
echo "Creating full size OCR PDF"
echo "=========================="
ocrmypdf $directoryStr/$directoryStr.pdf $directoryStr/$directoryStr\_ocr.pdf


echo ""
echo "Creating full size OCR+optimized PDF"
echo "===================================="
ocrmypdf --optimize 3 $directoryStr/$directoryStr.pdf $directoryStr/$directoryStr\_ocr_optimize.pdf

echo ""
echo "Checking for ImageMagick"
echo "========================"
type -P convert

if [ $? -ne 0 ]
then
   echo "ImageMagick is not installed, unable to create resized PDFs"
else
   mkdir -p $directoryStr/src_shrink

   for file in $(ls -v $directoryStr/src)
   do
      convert  $directoryStr/src/$file -density 70 -set colorspace Gray $directoryStr/src_shrink/$file
   done

   echo ""
   echo "Creating half size PDF"
   echo "======================"
   img2pdf $(ls -v $directoryStr/src_shrink/*.jpg) -o $directoryStr/$directoryStr\_shrink.pdf && echo "Success!" || "Error, unable to create PDF." 

   echo ""
   echo "Creating half size OCR PDF"
   echo "===================================="
   ocrmypdf $directoryStr/$directoryStr\_shrink.pdf $directoryStr/$directoryStr\_shrink_ocr.pdf

   echo ""
   echo "Creating half size OCR+optimized PDF"
   echo "===================================="
   ocrmypdf --optimize 3 $directoryStr/$directoryStr\_shrink.pdf $directoryStr/$directoryStr\_shrink_ocr_optimize.pdf
fi

echo ""
echo "Done!"
