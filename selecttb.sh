shopt -s extglob
#get the name of table
dbpath=$1
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

	#row available in that table
	rowav=$(awk -F"," '{if(NR>3)print 1;}' $dbpath/$tbname| wc -l)


	#pattern that are going to hold select command

	

	select option in 'select all' 'select particular cols' 'select on condition' 'select paricular rows' 'exit'
	do
	case $option in 
	exit)echo you is exit
	break
	;;
	'select all')echo 'you is select all'
	sed '1,3d' $dbpath/$tbname |awk -F"," -v colname="${colname[*]}" 'BEGIN{split(colname,nalist," ")}{i=1;print "row ",NR;
	print "----------------";while(i <= NF){print nalist[i]," : ",$i;i++;}print "___________________","\n";}'
	;;
	'select particular cols')echo 'option is particular columns'
	#select particular cols
	echo "please col order num in ${colname[@]} availabe num form 1 to ${#colname[@]} and | as sparate between cols num and app will ignore spaces"
	read

	#using sed to remove space
	repnospaces=$(echo $REPLY | sed 's/ //g')
	echo "reply with no spaces $repnospaces"
	
	ptchk=0
	case $repnospaces in 
	+([0-9|])) ptchk=1
	;;
	*) ptchk=0
	esac
	
	if [ $ptchk -eq 1 ]
	then
	#get the number in array
	inputval=($(echo "$repnospaces" | awk -F" " 'BEGIN{RS="|"} {print $0}'))
	echo "${inputval[@]}"

	#check the range 
	rgchk=0
	for i in ${inputval[@]}
	do
		if [ $i -gt 0 -a $i -le ${#colname[@]} ]
		then
			rgck=1
		else
			rgck=0
			echo "not in range"
			break;
			
		fi
	done
	

	if [ $rgck -eq 1 ]
	then
	#enter select mode
	 sed '1,3d' $dbpath/$tbname| awk -F"," -v colpl="${inputval[*]}" -v colnm="${colname[*]}" 'BEGIN{split(colpl,plac," ");
	 split(colnm,names," ")}{print "row ",NR;
         print "----------------";for(i in plac){print names[plac[i]]," : ",$plac[i];}print "___________________","\n";}'
	else
		echo "not in range"
	fi
	else
		echo "wrong pattern"
	fi
	;;

	'select on condition')echo 'option select on conditionn'
	#select on condition
	echo "please enter colname:value and app will ignore spaces so if string use , char as space"
	read

	#using sed to remove space
	repnospaces=$(echo $REPLY | sed 's/ //g')
	echo "reply with no spaces $repnospaces"
	
	
	numfd=0
	numfd=$(echo $repnospaces|awk -F":" '{if(NF!=2)print 1;}' | wc -l)
	
	if [ $numfd -eq 0 ]
	then
		inval=$(echo $repnospaces|awk -F":" '{print $2; exit;}')
		inname=$(echo $repnospaces|awk -F":" '{print $1; exit;}')
		inplace=0

		#get the place of name
		index=0
		while [ $index -lt ${#colname[@]} ]
		do
			if [ $inname = ${colname[$index]} ]
			then
				inplace=$(($index+1))
				break;
			fi
			index=$(($index+1))
		done
		
		if [ $inplace -gt 0 ]
		then
			
			#check string spaces
			newvalue=0
			if [ ${coltype[$inplace-1]} = "str" ]
			then
				echo "string"
				newvalue=$(echo "$inval"|sed 's/,/ /g')
				echo $newvalue
			else
				echo "not a string"
				newvalue=$inval
				echo $newvalue
			fi



			echo "enter processing"
sed '1,3d' $dbpath/$tbname | awk -F"," -v inpl="$inplace" -v inval="$newvalue" -v colname="${colname[*]}" 'BEGIN{split(colname,nalist," ")}{if($inpl==inval){i=1;print "row ",NR;print "----------------";while(i <= NF){print nalist[i]," : ",$i;i++;}print "___________________","\n";}}' 
		else
			echo "col not exist"
		fi
	else
		echo "wrong pattern"
	fi
	;;

	'select paricular rows')echo 'option is particular rows'
	#select particular rows
	echo "please enter row order num in ${colname[@]} availabe num form 1 to ${rowav} and | as sparate between cols num and app will ignore spaces"
	read

	#using sed to remove space
	repnospaces=$(echo $REPLY | sed 's/ //g')
	echo "reply with no spaces $repnospaces"
	
	ptchk=0
	case $repnospaces in 
	+([0-9|]))ptchk=1
	;;
	*)ptchk=0
	esac
	
	if [ $ptchk -eq 1 ]
	then
	#get the number in array
	inputval=($(echo "$repnospaces" | awk -F" " 'BEGIN{RS="|"} {print $0}'))
	echo "${inputval[@]}"

	#check the range 
	rgchk=0
	for i in ${inputval[@]}
	do
		if [ $i -gt 0 -a $i -le $rowav ]
		then
			rgck=1
		else
			rgck=0
			echo "not in range"
			break;
			
		fi
	done
	if [ $rgck -eq 1 ]
	then
	#enter select mode
	sed '1,3d' $dbpath/$tbname | awk -F"," -v rownum="${inputval[*]}" -v colname="${colname[*]}" 'BEGIN{split(colname,names," ");
	split(rownum,rlist," ")}{for(row in rlist) {if(NR == rlist[row]){i=1;print "row ",NR;print "----------------";
	while(i <= NF){print names[i]," : ",$i;i++;}print "___________________","\n";}}}' 
	else
		echo "not then range"
	fi
	else
		echo "wrong pattern"
	fi
	esac
	echo '1) select all	3) select on condition	5) exit '
	echo '2) select particular cols	4) select paricular rows'
	done


fi

