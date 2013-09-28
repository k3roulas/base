i=0
while [ "$i" != "30" ]; do
((i=i+1))
k=`echo $i | awk '{ printf("%2.2d\n",$0 ) }'`
cp x.csv y.$kcsv
done;
