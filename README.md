# imagedir2pdf

This script will download a sequence of images from a specific URL, starting from 1.jpg and continuing to the specified endpoint.

It will then convert the individual images to OCR PDFs.

## Usage

`./imgdir2pdf.sh <URL> <number of images>`

- URL: The full URL to an image contained in a directory with other images, numbered numerically.
- number of images: The number of images to download. The script will start at 1.jpg and end at X.jpg, where X is the number specified

## Outputs

This script will attempt to determine a document ID from the URL. If not, the user will be prompted to enter an ID. This ID is used to name the output directory, which will contain the following:

- `src`: directory containing all source images
- `src_shrink`: directory containing shrunken images (if imageMagick installed)
- `<id>.pdf`: full size PDF created from the source images
- `<id>_ocr.pdf`: full size PDF + OCR text layer
- `<id>_ocr_optimize.pdf`: full size PDF + OCR text layer + ocrmypdf optimization level 3
- `<id>_shrink.pdf`: PDF created from shrunken versions of the source images
- `<id>_shrink_ocr.pdf`: shrunken PDF + OCR text layer
- `<id>_shrink_ocr_optimize.pdf`: shrunken PDF + OCR text layer + ocrmypdf optimization level 3

## Requirements

This script requires the following packages to be installed:
- img2pdf
- ocrmypdf
- wget
- awk is required too, usually that's included with the linux distro

Optionally, install imageMagick if you wish to create reduced density PDFs.

## Installation (Ubuntu)

Run the followung 

`sudo apt install img2pdf ocrmypdf wget`, optionally `sudo apt install imagemagick`
