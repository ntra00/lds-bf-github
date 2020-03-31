# curl examples, grep for 404, list results
rm  batchupdates/example-urls.out.xml

while read x; 
do
 sleep .1
z=$(curl -I "$x" |grep ' 404') 
echo "$x : $z" >> batchupdates/example-urls.out.xml

done < batchupdates/example-urls.txt

cat  batchupdates/example-urls.out.xml

