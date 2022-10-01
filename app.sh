select option in 'Create Database' 'List Database' 'Connect to Database' 'Drop Database' exit
do
case $option in 
exit)echo you is exit
break
;;
'Create Database')echo 'you is create'
. ./createdb.sh
;;
'List Database')echo 'you is list'
. ./listdb.sh
;;
'Connect to Database')echo 'you is connect'
. ./connectdb.sh
;;
'Drop Database')echo 'you drop'
. ./dropdb.sh
esac
echo '1) Create Database	3) Connect to Database	5) exit 
2) List Database	4) Drop Database'
done
