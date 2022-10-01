#!/bin/bash
shopt -s extglob
dbpath=$1
#get the name of table
echo "please enter the name of table"
read 
y=$(find -name "$REPLY" < $dbpath | wc -l )
if [ $y -eq 0 ]
then 
	echo "not exist"
else
	tbname=$REPLY
	#geting show display , primary key , its place ,type
	pk=$(head -1 $dbpath/$tbname) 
	echo "$pk"

	dispattern=$(sed -n '3p' $dbpath/$tbname | sed 's/,/:/g')
	echo $dispattern

	coltype=($(sed -n '2p' $dbpath/$tbname | awk 'BEGIN{RS=","}{print $0}'))
	echo ${coltype[@]}

	colname=($(sed -n '3p' $dbpath/$tbname | sed 's/,/ /g'))
	
	echo "enter you condition by writing col:value and app will check existence of that value then deleted"
	echo "app will ingore spaces so wrie char , as space in string value"
	read

	#using sed to remove space
	repnospaces=$(echo $REPLY | sed 's/ //g')
	echo "reply with no spaces $repnospaces"

	#checking pattern of inputr
	condnew=0
	condnew=$(echo $repnospaces |awk -F":" '{if(NF!=2){print 1;exit;}}' |wc -l)

	echo "print check input value"
	echo $condnew
	
	if [ $condnew -eq 0 ]
	then
		
		inputname=$(echo $repnospaces |awk -F":" '{print $1}')
		inputvalue=$(echo $repnospaces |awk -F":" '{print $2}')

		#get the palce of that name
		i=0
		inputplace=0
		while [ $i -lt ${#colname[@]} ] 
		do
			if [ ${colname[$i]} = $inputname ]
			then
				inputplace=$(($i+1))
			fi
			i=$(($i+1))
		done

		if [ $inputplace -gt 0 ]
		then
			echo "start proces"
			newvalue=0
			if [ ${coltype[$inputplace-1]} = "str" ]
			then
				newvalue=$(echo "$inputvalue" | sed 's/,/ /g')
				echo "$newvalue"
			else
				newvalue=$inputvalue 
			fi
			
			echo "that data are going to be deleted"
			sed '1,3d' $dbpath/$tbname | awk -F"," -v inpl="$inputplace" -v inval="$newvalue" '{if($inpl==inval){print $0}}' 
			

			touch $dbpath/tempdelete.sh
			awk -F"," -v inpl="$inputplace" -v inval="$newvalue" '{if(NR>3){if($inpl!=inval){print $0}}else print$0}' $dbpath/$tbname > $dbpath/tempdelete.sh

			#removing table and rename the new one
			rm $dbpath/$tbname
			mv $dbpath/tempdelete.sh $dbpath/$tbname
		
		else
			echo "no col with that name"
		fi
	else
		echo "data not in right pattern"
		
	fi
fi
