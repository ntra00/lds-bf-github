start=$1
limit=$2
commd="$start,$limit"
echo $cmd
sed -n "$commd p" <  batchupdates/bibsrelated.xml > ~/ml4reload.txt
while read line
do
 
echo $line
`$line`
done <~/ml4reload.txt
#nohup ./rbl > ../logs/bibload.txt &

