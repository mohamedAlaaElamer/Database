echo "table in that database"
echo $dbpath
dbpath=$1
tables=$(ls ./$dbpath)

for i in ${tables[@]}
do 
	echo $i
	echo "--------------------"
	echo "name   |   type"
	echo "--------------------"
	colname=($(sed -n '3p' $dbpath/$i | sed 's/,/ /g' ))
	coltype=($(sed -n '2p' $dbpath/$i| sed 's/,/ /g' ))
	pk=$(sed -n '1p' $dbpath/$i)
	rows=$(sed '1,3d' $dbpath/$i |awk -F"," '{print 1;}' | wc -l)
	col=0
	while [ $col -lt ${#colname[@]} ]
	do
		echo "${colname[col]}   :   ${coltype[col]}"
		col=$(($col+1))
	done
	echo "pk   :   ${pk}"
	echo "rows   :   ${rows}"
	echo "____________________"
done

