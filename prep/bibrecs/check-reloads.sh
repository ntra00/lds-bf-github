echo "--------------------------------------------------------------------"
echo singleloads contains yazzed content ready for reload
echo  watch-singles-i.sh runs every 3 minutes to copy them to loadrdf
echo from which we run rbl to load to database
echo
echo "--------------------------------------------------------------------"
echo singleloads:
 ls -l singleload/|wc -l
echo loadrdf:
 ls -l loadrdf/|wc -l
currentrec=$(ps -ef|grep rbc|grep bash| cut -d "." -f2-3 | cut -d " " -f2)
if  [[ $currentrec != "" ]] ; then
echo current rec $currentrec

filepos=$(cat batchupdates/reload.txt |grep -n $currentrec)
start=$(ps -ef|grep reload-generic |grep sh| cut -d "." -f2-3| cut -d " " -f2)

f=$(echo $filepos|cut -d ":" -f1)
echo progress:
echo `expr $f - $start`
fi



