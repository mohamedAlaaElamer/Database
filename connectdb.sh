echo 'please enter the name of database'
read
echo $REPLY
dbname=$REPLY
ckconnect=0
y=$(find -name "$dbname" | wc -l)
if [ $y -eq 1 ] 
then
	echo 'exist'
	dbpath=dbcontainer/$dbname
	echo $dbpath
	echo "app connected to that database"
	ckconnect=1
else
	echo 'not exist'
	ckconnect=0

fi
if [ $ckconnect -eq 1 ]
then
	select option in 'Create Table' 'List Table' 'Drop Table' 'Insert into Table' 'Select from Table' 'Delete from Table' 'Update Table' back
	do
	case $option in 
	back)echo you is back
	break
	;;
	'Create Table')echo 'you is create'
	. ./createtb.sh $dbpath
	;;
	'List Table')echo 'you is list'
	. ./listtb.sh $dbpath
	;;
	'Drop Table')echo 'you is drop'
	. ./droptb.sh $dbpath
	;;
	'Insert into Table')echo 'you is insert'
	. ./inserttb.sh $dbpath
	;;
	'Select from Table')echo 'you is select'
	. ./selecttb.sh $dbpath
	;;
	'Delete from Table')echo 'you is delete'
	. ./deletetb.sh $dbpath
	;;
	'Update Table')echo 'you is update'
	. ./updatetb.sh $dbpath
	esac
	echo '1) Create Table  4) Insert into Table  7) Update Table 2) List Table 
5) Select from Table  8) back 3) Drop Table	6) Delete from Table'
	done
fi

