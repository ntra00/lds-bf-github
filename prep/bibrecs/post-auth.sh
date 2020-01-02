lccn=$1
cd ../auths/

#./load_nametitles_lccn_mlcp.sh  $lccn
./load_auth_yaz.sh $lccn
cd ../bibrecs/

