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
	echo $pkplace
	
	echo "enter you condition by writing col:value and app will check existence of that value then write | separate and colname:newvalue"
	echo "app will ingore spaces so wrie char , as space in string value available cols ${dispattern}"
	read

	#using sed to remove space
	repnospaces=$(echo $REPLY | sed 's/ //g')
	echo "reply with no spaces $repnospaces"

	#checking pattern of inputr
	condnew=0
	condnew=$(echo $repnospaces |awk -F":" 'BEGIN{RS="|"}{if(NF!=2){print 1;exit;}}END{if(NR!=2){print 1; exit;}}' |wc -l)

	echo "print check input value"
	echo $condnew
	
	if [ $condnew -eq 0 ]
	then
		#get the name  of each col and looking for place of each 
		inputname=($(echo $repnospaces |awk -F":" 'BEGIN{RS="|"}{print $1}'))
		inputvalue=($(echo $repnospaces |awk -F":" 'BEGIN{RS="|"}{print $2}'))
		echo ${inputname[@]}
		echo ${inputvalue[@]}

		inputfone=0 
		inputftwo=0
		i=0
		while [ $i -lt ${#colname[@]} ]
		do 
			if [ ${colname[$i]} = ${inputname[0]} ]
			then
				inputfone=$(($i+1)) 
			fi


			if [ ${colname[$i]} = ${inputname[1]} ]
			then
				inputftwo=$(($i+1)) 
			fi
			i=$(($i+1))
		done
		
		if [ $inputfone -gt 0 -a $inputftwo -gt 0 ]
		then
			echo "start process"
			#get the type of col that going to hold new data
			inputtype=${coltype[$inputftwo-1]}
			echo $inputtype
			
			rtype=0
			if [ $inputtype = "str" ]
			then
				if [ ${inputvalue[1]} ]
				then
					rtype=1
				else
					rtype=0
				fi
			elif [ $inputtype = "int" ]
			then
				case ${inputvalue[1]} in
				+([0-9])) rtype=1
				;;
				*) rtype=0
				;;
				esac
			elif [ $inputtype = "dat" ]
			then
				case ${inputvalue[1]} in
				@([0-3])@([0-9])@([-])@([0-2])@([0-9])@([-])@([1-2])@([0-9])@([0-9])@([0-9])) rtype=1
				;;
				*) rtype=0
				;;
				esac
			elif [ $inputtype = "float" ]
			then
				case ${inputvalue[1]} in
				+([0-9])?(?(.)+([0-9]))) rtype=1
				;;
				*) rtype=0
				;;
				esac
			fi
			
			if [ $rtype -eq 1 ]
			then
				if [ $inputtype = "str" ]
				then
					newvalue=$(echo "${inputvalue[1]}" | sed 's/,/ /g' )
					echo "$newvalue"
					
				else
					newvalue=${inputvalue[1]}
					echo "not a string"
				fi
				pkcheck=0
				if [ $inputftwo -eq $pkplace ]
				then


					
 
					echo "you are going the pk of table"
					pkcheck=$(sed '1,3d' $dbpath/$tbname| awk -v pal="$pkplace" -v val="$newvalue" -F"," '{if($pal==val){print $1; 						exit}}'| wc -l)
					
					if [ $pkcheck -eq 1 ]
					then 
						echo "this primary alreay taken"
						
					else
						echo "continue"		
		
					fi
				fi
				
				if [ $pkcheck -eq 0 ]
				then
					

					oldvalue=0
					if [ ${coltype[$inputfone-1]} = "str" ]
					then
						oldvalue=$(echo ${inputvalue[0]} | sed 's/,/ /g')
					else
						oldvalue=${inputvalue[0]}
					fi					

					echo "that are going to be updated"
					sed '1,3d' $dbpath/$tbname| awk -v oldpl="$inputfone" -v oldval="$oldvalue" -v newpl="$inputftwo" -v 						newval="$newvalue" -F"," '{if($oldpl==oldval){i=1;while(i<=NF){if(i==newpl)printf newval;
else printf $i;if(i!=NF)printf ",";i++;}printf "\n";}}'
					
					#update the table
					touch $dbpath/tempupdate.sh
					awk -v oldpl="$inputfone" -v oldval="$oldvalue" -v newpl="$inputftwo" -v newval="$newvalue" -F"," 						'{if(NR<=3)print $0;else{if($oldpl==oldval){i=1;while(i<=NF){if(i==newpl)printf newval;else printf $i;
if(i!=NF)printf ",";i++;}printf "\n";}else print $0;}}' $dbpath/$tbname > $dbpath/tempupdate.sh
					
					#removing table and rename the new one
					rm $dbpath/$tbname
					mv $dbpath/tempupdate.sh $dbpath/$tbname
				
				fi

			else
				echo "new data not in the type of that col"
			fi



		else
			echo "your wrong name of col"
		fi
		

	else
		echo "input in wrong"
	fi
	
fi
