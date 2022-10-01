echo "please enter table name"
read
dbpath=$1
y=$(find -name "$REPLY" < $dbpath | wc -l)

tbname=$REPLY
echo $y


#cheking the existence of table
if [ $y -ne 1 ]
then
	echo "not exist"
	
else
	rm $dbpath/$tbname

fi


