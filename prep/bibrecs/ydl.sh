#!/bin/bash
# reload today's or a given dates; is this just daily_4?

# just redo the whole day:

./loadrdf.sh $1

echo "done ydl for  $1 "
cat ../logs/ydl.log | grep split |cut -d ":" -f5|sort|uniq



