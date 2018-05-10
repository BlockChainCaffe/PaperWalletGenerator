#!/bin/bash
while read line; do
	# get params
	echo $line
	PRV=$(echo $line | cut -d';' -f1)
	PUB=$(echo $line | cut -d';' -f2)
	WIF=$(echo $line | cut -d';' -f3)
	ADD=$(echo $line | cut -d';' -f4)

	# Search & replace
	cat template.html | sed "s:%%PRV%%:$PRV:" |sed "s:%%PUB%%:$PUB:" |sed "s:%%WIF%%:$WIF:" |sed "s:%%ADD%%:$ADD:" > wallet.html

	# Generate QRs
	qrencode -o add.png -m 2 -l M -s 5 $ADD
	qrencode -o wif.png -m 2 -l M -s 5 $WIF

	# Generate PDF with Chrome / Chromium
	chromium-browser --headless --print-to-pdf="wallet.pdf" wallet.html

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
done < $1
mv wallets.pdf wallets-$(date "+%H%M%S").pdf


