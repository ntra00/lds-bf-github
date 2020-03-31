#cts:collection-query("/bibframe-process/2018-06-13/")    
# reload instances
start=$1
limit=$2
commd="$start,$limit"
echo $cmd
sed -n "$commd p" <  batchupdates/reloadphotos.txt > ~/ml4reloadi.txt
while read line
do
 
echo $line
`$line`
done <~/ml4reloadi.txt

