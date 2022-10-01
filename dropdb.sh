echo 'please enter the name of databse you want to delete it' 
read
echo $REPLY
y=$(find -name "$REPLY" | wc -l)
if [ $y -eq 1 ] 
then
	echo 'exist'
	rm -r dbcontainer/$REPLY
	echo "that has been deleted"
else
	echo 'not exist'
fi

