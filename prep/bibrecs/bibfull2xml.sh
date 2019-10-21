#!/bin/bash

####!/bib/bash
## This is where we'll do our work

cd bibs_full

# Just some utilities if you need them.  This is how many MARC files there are.  Make a directory for each under the marklogic-staging directory to store the many XML files we'll have to create.  There's also a good random string generator if you need dynamic file naming.
#countfiles=`ls -w1 | wc -l`
#for i in `seq 1 $countfiles`; do mkdir -p ../marklogic-staging/$i; done
#random=`openssl rand -base64 32`

# First break up the large MARC 2709 files into smaller chunks, 1000 per file.  Still 2709. 
# Convert from marc8 encoding to UTF-8. Save with a prefix of "split_".  They will write to the same directory as the large 2709 files.

for mrc in $(ls catalog*.mrc)
	do
		directory=$(echo $mrc | cut -d"." -f1)
		mkdir $directory
		cd $directory
		#	yaz-marcdump -f utf8 -t utf8 -C 1000 -s split_{}_ {} > /dev/null"
		# yaz-marcdump -f utf8 -t utf8 -C 1000 -s split_ ../$mrc > /dev/null 
		for f in split*
		do

#			yaz-marcdump  -i marc -o marcxml $f  | /marklogic/applications/natlibcat/admin/bfi/utf-nf.1.0.2.pl -NFC - | xmllint --format --encode UTF-8 - | > $f.xml
			yaz-marcdump  -i marc -o marcxml $f  > $f.tmp
			/marklogic/applications/natlibcat/admin/bfi/utf-nf.1.0.2.pl -NFC < $f.tmp  | xmllint --format --encode UTF-8 - > $mrc_$f.xml

			rm $f.tmp

		done
		cd ..
done

echo "now run test_bibchunck_mlcp.sh instead of whats below..."

# Then convert the smaller 1000 record MARC 2709 to MARCXML UTF-8 as stdout.
# Use xmllint with MARCXML as stdin to format and add XML declaration output, ensuring UTF-8, goes to stdout.
# Use Perl script for UTF-8 NFC normalization, from xmllint stodout coming in via stdin.  Perl output goes to stdout.
# Use curl to HTTP POST normalized MARCXML UTF-8 data from Perl stdout as stdin, and log the output if any errors occur.

#rm /marklogic/id/natlibcat/admin/bfi/logs/work-load.out
#ls split_* | parallel "yaz-marcdump -f marc8 -t utf8 -i marc -o marcxml {} | /marklogic/applications/natlibcat/admin/bfi/utf-nf.1.0.2.pl -NFC - | xmllint --format --encode UTF-8 - |
# curl --digest --retry 20 --retry-delay 10 -X POST -d @- -H 'X-bib2bf-Batch: fullexport' -H 'X-bib2f-DocURI: {}.xml' -H 'Content-Type: text/xml' -u id:pass  http://mlvlp04.loc.gov:8231/admin/bfi/bibrecs/store-marcxml-preprocess.xqy >> /marklogic/id/natlibcat/admin/bfi/logs/work-load.out"

