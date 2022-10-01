#!/bin/bash
shopt -s extglob
dbpath=$1
echo "please enter table name _ that is the only sepcial char allowed and must start with at least one alpha"
read
y=$(find -name "$REPLY" < $dbpath | wc -l)

#x variable contain the name of table
x=$REPLY
echo $y
echo $x


#cheking the existence of table
if [ $y -eq 1 ]
then
	echo 'exist'
else
	echo "not exist"
	#cheking the name of table in our pattern shape
	y=1
	case $x in
	@([A-Za-z])*([A-Za-z0-9_])) y=0
	;;
	*) y=1
	;;
	esac
	if [ $y -eq 0 ]
	then
		echo "name in pattern"
		touch $dbpath/$x
	else 
		echo "name not apply the pattern"
	fi
	

fi

if [ $y -eq 0 ]
then
	#ask for table attributes and its type
	echo "please enter colum,type : separator between columns available types(int,float,dat,str) "
	echo "in naming of columns _ that is the only sepcial char allowed and must start with at least one alpha"
	echo "app will ignore the spaces"

	read

	#using sed to remove space
	repnospaces=$(echo $REPLY | sed 's/ //g')
	echo "reply with no spaces $repnospaces"



	#cheking entering in our pattern shape
	checksh=0
	case $repnospaces in
	+([A-Za-z0-9_:,])) checksh=1
	;;
	*) checksh=0
	;;
	esac


	if [ $checksh -eq 1 ]
	then
		echo "printing pattern status $checksh"
		#cheking entering two variable in each field
		eachfd=0
		eachfd=$(printf "$repnospaces" | awk -F"," 'BEGIN{RS=":"}{if(NF!=2){print 1; exit;}}' | wc -l)
		echo "printing each field ${eachfd}"	
		

		if [ $eachfd -eq 0 ]
		then
			#separate name of column and its type in two array
			colname=($(printf "$repnospaces" |awk -F"," 'BEGIN{RS=":"}{print $1}'))
			coltype=($(printf "$repnospaces" |awk -F"," 'BEGIN{RS=":"}{print $2}'))


			echo ${colname[@]}
			echo ${coltype[@]}

			
			#checking the data type existence
			chektype=1
			datatype=(int float dat str)
			for inp in ${coltype[@]}
			do
				chektype=1
				for avty in ${datatype[@]} 
				do
					if [ $inp = $avty ]
					then
						chektype=1
						break;
					else
						chektype=0
					fi
				done
				
				if [ $chektype -eq 0 ]
				then
					echo "wrong datatype inserted"
					break
				fi
			done
			
			#checking name pattern of each colums
			chekname=1
			for var in ${colname[@]}
			do
				chekname=1
				case $var in
				@([A-Za-z])*([A-Za-z0-9_])) chekname=1
				;;
				*) chekname=0;break;
				;;
				esac

			done
			if [ $chekname -eq 0 ]
			then
				echo "wrong pattern in naming the col"
			fi
			
			#enter implementation state
			if [ $chektype -eq 1 -a $chekname -eq 1 ]
			then
				#asking for the primary key of table
				echo "enter the name of column you want to be the primary key"
				read


				#checking if exist and adding the primary as the first line in our table 
				chepk=0
				for i in ${colname[@]}
				do
					if [ $i = $REPLY ]
					then
						chepk=1
					fi
				done



				if [ $chepk -eq 1 ]
				then
					echo "in if "
					printf "$REPLY"  >>$dbpath/$x
					printf "\n" >>$dbpath/$x
					end=$((${#coltype[@]}))
					

					#inserting the type of each columns in the table
					index=0
					while [ $index -lt $end ]
					do
						printf "${coltype[$index]}" >> $dbpath/$x
						if [ $index -ne $(($end-1)) ]
						then
							printf ","  >>$dbpath/$x
						fi
						index=$(($index+1))

					done
					printf "\n" >>$dbpath/$x

					#inserting the name of each columns in the table
					index=0
					while [ $index -lt $end ]
					do
						printf "${colname[$index]}" >> $dbpath/$x
						if [ $index -ne $(($end-1)) ]
						then
							printf ","  >>$dbpath/$x
						fi
						index=$(($index+1))

					done
					printf "\n" >>$dbpath/$x
					

					echo "your table has been created"
				else
					rm $dbpath/$tbname
					echo "no col with that name"

				fi
				


			fi
			
		else
			rm $dbpath/$tbname
			echo "wrong delcaration"
		fi
		
	else
		rm $dbpath/$tbname
		echo "not in the shape pattern"
	fi
fi












