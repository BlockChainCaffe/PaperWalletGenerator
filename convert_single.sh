#!/bin/bash

# Esample imput file generated form
#
# Private key:  3973e022e93220f9212c18d0d0c543ae7c309e46640da93a4a0314de999f5112
# Public key:   035C6A3B83FB834519EECAE1681EE2118F55EFC28C2AA705251ACBC1BD4D241E09
# KeyHash:      155526cebaefaed1da3fedaa11aade823d9b62a4 (ripmed160(sha256(pub)))
# WIF:          cPWP7WfbF5f883qk5VPyAmQiqs5nEJaV8qxFUFvDFwxKLsSsyHjB
# Address:      mhTkVX3TyVsnJNu1xR6sY6rtysj68d1oSg  (P2PKH)
# SegWit Addr:  2N9Q1C7rUPqCMJxdaheg9P3GpAM5cmSSvRY
# Bech32 Addr:  tb1qz42jdn46a7hdrk3lak4pr2k7sg7ekc4y9zquxc

INPUT=$1

# PRV=$(echo $line | cut -d';' -f1)
# PUB=$(echo $line | cut -d';' -f2)
# WIF=$(echo $line | cut -d';' -f3)
# ADD=$(echo $line | cut -d';' -f4)

PRV=$(cat $INPUT | grep 'Private key:' | cut -d':' -f2 | sed "s:^ +::")
PUB=$(cat $INPUT | grep 'Public key: ' | cut -d':' -f2 | sed "s:^ +::")
KHS=$(cat $INPUT | grep 'KeyHash:    ' | cut -d':' -f2 | sed "s:^ +::")
WIF=$(cat $INPUT | grep 'WIF:        ' | cut -d':' -f2 | sed "s:^ +::")
ADD=$(cat $INPUT | grep 'Address:    ' | cut -d':' -f2 | sed "s:^ +::")
SEG=$(cat $INPUT | grep 'SegWit Addr:' | cut -d':' -f2 | sed "s:^ +::")
BEC=$(cat $INPUT | grep 'Bech32 Addr:' | cut -d':' -f2 | sed "s:^ +::")


# Search & replace
cat template.html | \
    sed "s:%%KHS%%:$KHS:" | \
    sed "s:%%SEG%%:$SEG:" | \
    sed "s:%%BEC%%:$BEC:" | \
    sed "s:%%PRV%%:$PRV:" | \
    sed "s:%%PUB%%:$PUB:" | \
    sed "s:%%WIF%%:$WIF:" | \
    sed "s:%%ADD%%:$ADD:" > wallet.html

# Generate QRs
qrencode -o add.png -m 2 -l M -s 5 $ADD
qrencode -o wif.png -m 2 -l M -s 5 $WIF

# Generate PDF with Chrome / Chromium
#chromium-browser --headless --print-to-pdf="wallet.pdf" wallet.html
brave-browser --headless --print-to-pdf="wallet.pdf" wallet.html

# Get Just first page
pdfseparate -l 1 wallet.pdf w2.pdf

# Add page to whole document 
if [[ -f wallets.pdf ]]; then
    pdfunite w2.pdf wallets.pdf tmp.pdf
    rm wallets.pdf
    mv tmp.pdf wallets.pdf
else
    mv w2.pdf wallets.pdf
fi 

# Clean
rm wallet.html wallet.pdf wif.png add.png w2.pdf 

mv wallets.pdf wallets-$(date "+%H%M%S").pdf

### FIX PDF for PRINT
#
# gs -o wallets-new.pdf -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress wallets-163031.pdf
#
