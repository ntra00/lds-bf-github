# reload any query from /marklogic/backups/reload.txt
start=$1
limit=$2
commd="$start,$limit"
echo $cmd
sed -n "$commd p" <  /marklogic/id/natlibcat/admin/bfi/bibrecs/batchupdates/reload.txt > ~/ml4reload.txt
while read line
do
 
echo $line
`$line`
done <~/ml4reload.txt

