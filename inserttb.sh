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
	
	pkplace="mp"
	i=0
	while [ $i -lt ${#colname[@]} ]
	do
		if [ ${colname[$i]} = $pk ]
		then
			pkplace=$(($i+1))
		fi
		i=$(($i+1))

	done
	echo $| awk -F":" -v num="$colnum"  'BEGIN{RS=" "}{if(NF!=num){print 1;exit}}' |
	
	echo "please enter all table columns values with : separator between them like $dispattern "
	echo "and you can more than one row using | separator app will ignore spaces to enter space in string using , char"
	read

	#using sed to remove space
	repnospaces=$(echo $REPLY | sed 's/ //g')
	echo "reply with no spaces "
	echo $repnospaces
	
		
	#get values of each col in array
	#colvalue=($(printf "$repnospaces" |awk -F"," 'BEGIN{RS=":"}{print $1}'))
	#echo ${colvalue[@]}
	#echo ${#colvalue[@]}
	
	#generat two dimension array to check pk and col number and its type
        wholedata=($(printf "$repnospaces" | awk -F":" 'BEGIN{RS="|"}{print $0}'))
	echo ${wholedata[@]}
	echo ${#wholedata[@]}
	echo "data and its length"
	#check of each row holding the right number of col
	checknum=0
	colnum=${#coltype[@]}
	checknum=$(echo "${wholedata[@]}" | awk -F":" -v num="$colnum"  'BEGIN{RS=" "}{if(NF!=num){print 1;exit}}' | wc -l)
	
	if [ $checknum -eq 0 ]
	then
		echo "all col have been entered"
	else
		echo "missing col"
	fi
	
	#holding row by row
	echo "entering checking mode" 
	alrehere=1
	rtype=0
	echo ${wholedata[@]}
	


	#checking pk of entered data
	echo "checking pk of entered data"
	pkcheckwho=1
	pkofwhole=($(echo ${wholedata[@]} | awk -F":" -v pal=$pkplace 'BEGIN{RS=" "}{print $pal}'))
	echo ${pkofwhole[@]}
	inpk=0
	jnpk=0
	while [ $inpk -lt ${#pkofwhole[@]} ]
	do
		jnpk=$(($inpk+1))
		while [ $jnpk -lt ${#pkofwhole[@]} ]
		do
			echo "printing i and j"
			echo ${pkofwhole[$inpk]}  
			echo ${pkofwhole[$jnpk]}
			if [ ${pkofwhole[$inpk]} = ${pkofwhole[$jnpk]} ]
			then
				pkcheckwho=0
				break;
			fi
			jnpk=$(($jnpk+1))
		done
		if [ $pkcheckwho -eq 0 ]
		then
				break;
		fi
		
		inpk=$(($inpk+1))
		
	done
	if [ $pkcheckwho -eq 0 ]
	then
		echo "that one token is already taken"
	else
		for i in ${wholedata[@]}
		do
		echo "check row $i"
		temprow=($(printf "$i" | sed 's/:/ /g'))
		
		#checking datatype of each row
		gettype=0
		rtype=0
		echo "${temprow[@]}"
		while [ $gettype -lt ${#coltype[@]} ] 
		do
			echo "num of col"
			echo $gettype
			echo "value of field"
			echo ${temprow[$gettype]}
			if [ ${coltype[$gettype]} = "str" ]
			then
				if [ ${temprow[$gettype]} ]
				then
					rtype=1
				else
					rtype=0
				fi
			elif [ ${coltype[$gettype]} = "int" ]
			then
				case ${temprow[$gettype]} in
				+([0-9])) rtype=1
				;;
				*) rtype=0
				;;
				esac
			elif [ ${coltype[$gettype]} = "dat" ]
			then
				case ${temprow[$gettype]} in
				@([0-3])@([0-9])@([-])@([0-2])@([0-9])@([-])@([1-2])@([0-9])@([0-9])@([0-9])) rtype=1
				;;
				*) rtype=0
				;;
				esac
			elif [ ${coltype[$gettype]} = "float" ]
			then
				case ${temprow[$gettype]} in
				+([0-9])?(?(.)+([0-9]))) rtype=1
				;;
				*) rtype=0
				;;
				esac
			fi
			if [ $rtype -eq 0 ]
			then 
				echo "value not in right shape"
				break;
			fi
			gettype=$(($gettype+1))
		done
		if [ $rtype -eq 1 ]
		then 
			#the primary key of each row
			alrehere=0
			echo "check entering of same primary key"
			gvalue=$(echo ${temprow[$pkplace-1]}|sed 's/,/ /g')
			echo $pkplace
			echo "enter checking"
			echo $tbname
			alrehere=$(sed '1,3d' $dbpath/$tbname| awk -v pal="$pkplace" -v val="$gvalue" -F"," '{if($pal==val){print $1; exit}}'  | wc -l)
			echo $alrehere
			echo "printing hold value"
			if [ $alrehere -eq 1 ]
			then 
				echo "second one primary alreay taken"
				break;
			else
				echo "continue"		
		
			fi
				
		fi

		

		#checking num of col
		#chek=0
		#if [ ${#temprow[@]} -ne ${#colname[@]} ]
		#then
			#echo "there is a row in wrong shap"
			#check=1
			#break
		#fi
	done
	echo "second primary key"
	echo $alrehere
	if [ $alrehere -eq 0 ]
	then
		if [ $rtype -eq 1 ]
		then
			echo "cheking insert"
			echo ${wholedata[@]}| sed  's/ /\n/g'| sed  's/,/ /g' |sed  's/:/,/g' >>$dbpath/$tbname
			echo "data has been inserted"

		fi
		
	fi	

	#end of fi 
	fi
	
	
	
	
fi
