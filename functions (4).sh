#!/bin/bash

function AddTest { #function that adds a new entry to medicalRecord.txt

    echo "please provide patient id:"
    read IDadd

    #check if the provided ID is not exactly 7 digits
    if ! echo "$IDadd" | grep -qE '^[0-9]{7}$'
    then
        echo "invalid ID! please insert an ID of exactly 7 digits"
        return
    fi

    echo "please provide test abbreviation (LDL/Hgb/BGT/systole/diastole):"
    read TestAb

    #set the unit for the test based on the abbreviation
    case $TestAb in
        LDL) TestUnit="mg/dL" 
        ;;
        Hgb) TestUnit="g/dL"
         ;;
        BGT) TestUnit="mg/dL"
         ;;
        systole) TestUnit="mm Hg" 
        ;;
        diastole) TestUnit="mm Hg" 
        ;;
        *) echo "invalid test abbreviation!"
           return 
           ;;
    esac
    if grep -q "^$IDadd: $TestAb" medicalRecord.txt
    	then 
     	   echo "Entry for patient $IDadd and test $TestAb already exists! please select option 5 to update info."
     	   return
     	   fi

    echo "please provide the date of test (in the YYYY-MM format)"
    read TestDate

    #extract the year from the provided date
    yearval=$(echo "$TestDate" | cut -d '-' -f1)

    #check if the year is within the acceptable range
    if [ "$yearval" -lt 2000 ] || [ "$yearval" -gt 2024 ]
     then
        echo "outdated year! year must be between 2000 and 2024."
        return
    fi

    #extract the month from the provided date
    monthval=$(echo "$TestDate" | cut -d '-' -f2)

    #check if the month is valid
    if [ "$monthval" -lt 01 ] || [ "$monthval" -gt 12 ]
     then
        echo "invalid month! month must be between 01 and 12."
        return
    fi

    echo "please provide test value:"
    read TestVal

    echo "please provide the status of test (pending/completed/reviewed)"
    read TestStatus

    #convert the status to lowercase
    statusval=$(echo "$TestStatus" | tr '[A-Z]' '[a-z]')

    #check if the status is one of the accepted values
    if [ "$statusval" != "pending" ] && [ "$statusval" != "completed" ] && [ "$statusval" != "reviewed" ]
    then
        echo "invalid test status!"
        return
    fi

    #append the new test entry to medicalRecord.txt
    echo "$IDadd: $TestAb, $TestDate, $TestVal, $TestUnit,$statusval" >> medicalRecord.txt
    echo "new test added successfully!"
}

function PatientID { #function to handle patient-specific operations

 	if [ ! -e medicalRecord.txt ]
 	then #check if the file medicalRecord.txt exists
        	echo "File medicalRecord.txt does not exist."
       	 return 
   	 fi
   i=1

    echo "Enter the patient ID"
    read id
    if echo "$id" | grep -qE '^[0-9]{7}$'
     then #check if the ID is exactly 7 digits
     echo "Patient menu"
     echo ""
     echo "1- Retrieve all patient tests"
     echo "2- Retrieve all abnormal patient tests"
     echo "3- Retrieve all patient tests in a given specific period"
     echo "4- Retrieve all patient tests based on test status"
     read choice2

     case $choice2 in

        1) cat medicalRecord.txt | grep $id ;; #retrieve all tests for the given patient ID

        2) #retrieve all abnormal tests for the given patient ID
            count=$(cat medicalRecord.txt  | grep "$id" | wc -l)
            while [ $i -le $count ]
             do
                val=$(cat medicalRecord.txt | grep "$id" | cut -d ' ' -f2 | cut -d ',' -f1 | sed -n "${i}p")
                #check if the test has a single range (< or >) or a range between two numbers (< and >)
                count2=$(cat medicalTest.txt | grep $val | grep -o '[0-9]*[.]*[0-9]*' | wc -l)
                if [ $count2 -eq 1 ]
                 then
                    range=$(cat medicalTest.txt | grep $val | grep -o '[0-9]*[.]*[0-9]*' | sed -n '1p')
                    MedicalExaminationResult=$(cat medicalRecord.txt | cut -d' ' -f4 | sed -n "${i}p" | cut -d ',' -f1)
                    cat medicalTest.txt | grep '<' > /dev/null #check if the test result should be less than a value
                    if [ $? -eq 0 ]
                     then
                        if [ $(echo "$MedicalExaminationResult > $range" |bc ) -eq 1 ]
                         then #check if the test result is greater than the range
                            cat medicalRecord.txt | sed -n "${i}p" #print the line
                        fi
                    elif [ $? -ne 0 ]
                    then
                        if [ $(echo "$MedicalExaminationResult < $range" |bc ) -eq 1 ]
                         then #check if the test result is less than the range
                            cat medicalRecord.txt | sed -n "${i}p"
                        fi
                    fi
                elif [ $count2 -eq 2 ]
                then #handle the case where the range is between two numbers
                    MedicalExaminationResult=$(cat medicalRecord.txt | cut -d' ' -f4 | sed -n "${i}p" | cut -d ',' -f1)
                    num1=$(cat medicalTest.txt | grep $val | grep -o '[0-9]*[.]*[0-9]*' | sed -n '1p') #first range number
                    num2=$(cat medicalTest.txt | grep $val | grep -o '[0-9]*[.]*[0-9]*' | sed -n '2p') #second range number

                    #check if the range is inverted ( num2 < num1)
                    if [ $(echo "$num2 < $num1" |bc ) -eq 1 ]
                     then
                        if [ $(echo "$MedicalExaminationResult < $num2" | bc) -eq 1 ] || [ $(echo "$MedicalExaminationResult >  $num1" | bc) -eq 1 ]; then
                            cat medicalRecord.txt | sed -n "${i}p"
                        fi
                    elif [ $(echo "$num1 < $num2" |bc ) -eq 1 ]
                     then
                        if [ $(echo "$MedicalExaminationResult > $num2" | bc) -eq 1 ] || [ $(echo "$MedicalExaminationResult <  $num1" | bc) -eq 1 ]; then
                            cat medicalRecord.txt | sed -n "${i}p"
                        fi
                    fi
                fi
                i=$((i+1))
            done
        ;;

        3) #retrieve all tests for the given patient ID within a specific period
            cat medicalRecord.txt | grep $id > temp.txt
            flag=0
            while [ $flag -ne 1 ]
            do
                echo "Please provide the specific period"
                echo "First Date (in the YYYY-MM format):"
                read Date
                echo "Second Date (in the YYYY-MM format):"
                read Date2
                
                #extract year and month from the dates
                year1=$(echo $Date | cut -d '-' -f1 )
                if [ $(echo $Date | cut -d '-' -f2 | cut -c1) -eq 0 ]
                then
                    month1=$(echo $Date | cut -d '-' -f2 | cut -d '0' -f2)
                else
                    month1=$(echo $Date | cut -d '-' -f2 | cut -c1)
                fi
                year2=$(echo $Date2 | cut -d '-' -f1 )
                if [ $(echo $Date | cut -d '-' -f2 | cut -c1) -eq 0 ]
                 then
                    month2=$(echo $Date2 | cut -d '-' -f2 | cut -d '0' -f2)
                else
                    month2=$(echo $Date2 | cut -d '-' -f2 | cut -c1)
                fi

                #swap years if year1 is greater than year2
                if [ $year1 -gt $year2 ]
                then
                    temp=$year1
                    year2=$year1
                    year1=$temp
                fi

                #validate the months and years
                if [ $month1 -gt 12 ] || [ $month1 -lt 1 ] || [ $month2 -gt 12 ] || [ $month2 -lt 1 ]; then
                    continue
                elif [ $(echo -n $year1 | wc -c)  -ne 4 ] || [ $(echo -n $year2 | wc -c)  -ne 4 ]; then
                    continue
                else
                    flag=1
                fi
            done

            countOfDates=$(cat temp.txt | grep $id | wc -l)
            ind2=1
            while [ $ind2 -le $countOfDates ]
             do
                #get the year and month for each line
                YearOfMedTest=$(cat temp.txt |cut -d ' ' -f3 | cut -d '-' -f1 | sed -n "${ind2}p")
                MonthOfMedTest=$(cat temp.txt |cut -d ' ' -f3 | cut -d '-' -f2 | cut -d '0' -f2 | cut -d ',' -f1 | sed -n "${ind2}p")
                
                #check if the date falls within the specified period
                if [ $YearOfMedTest -lt $year2 ] && [ $YearOfMedTest -gt $year1 ]
                 then
                    cat temp.txt | sed -n "${ind2}p"
                elif [ $year1 -eq  $year2 ]
                 then
                    if [ $month1 -gt $month2 ]
                     then 
                        temp=$month1
                        month1=$month2
                        month2=$temp
                    fi
                    if [ $MonthOfMedTest -ge $month1 ] && [ $MonthOfMedTest -le $month2 ]
                     then
                        cat temp.txt | sed -n "${ind2}p"
                    fi
                elif [ $YearOfMedTest -eq $year1 ]
                 then
                    if [ $MonthOfMedTest -ge $month1 ]
                     then
                        cat temp.txt | sed -n "${ind2}p"
                    fi
                elif [ $YearOfMedTest -eq $year2 ]
                 then
                    if [ $MonthOfMedTest -le $month2 ]
                     then
                        cat temp.txt | sed -n "${ind2}p"
                    fi
                fi
                ind2=$((ind2+1))
            done
        ;;

        4) #retrieve all tests for the given patient ID based on test status
            cat medicalRecord.txt | grep $id > temp.txt
            flag=0
            
            #loop until the user enters a valid status
            while [ $flag -eq 0 ]
             do
                echo "Enter 1 for completed"
                echo "Enter 2 for pending"
                echo "Enter 3 for reviewed"
                read status 
                if [ $status -eq 1 ]
                 then
                    cat temp.txt | grep "completed"
                    flag=1
                elif [ $status -eq 2 ]
                 then 
                    cat  temp.txt | grep "pending"
                    flag=1
                elif [ $status -eq 3 ]
                 then
                    cat temp.txt | grep "reviewed"
                    flag=1
                else 
                    continue
                fi
            done
        ;;
     esac

   else
       echo "Invalid ID! Please insert an ID of exactly 7 digits"
   fi
}

function upNormalForALLPatients { #function that prints only upnormal test values of all patients 

 	if [ ! -e medicalRecord.txt ]
 	then #check if the file medicalRecord.txt exists
        	echo "File medicalRecord.txt does not exist."
       	 return 
   	 fi
    #initialize the line index to 1
    i=1

    #get the total number of lines in the file medicalRecord.txt
    count=$( cat medicalRecord.txt | wc -l )

    #loop through each line in the file
    while [ $i -le $count ]
     do
         #extract the test abbreviation from the current line (LDL, Hgb, etc ..)
         val=$(cat medicalRecord.txt | cut -d ' ' -f2 | cut -d ',' -f1 | sed -n "${i}p")
         
         #count the number of numeric ranges associated with the test in medicalTest.txt
         count2=$(cat medicalTest.txt | grep $val | grep -o '[0-9]*[.]*[0-9]*' | wc -l)
         
         #if there is only one range (e.g., a single number without a range)
         if [ $count2 -eq 1 ]
         then
             #get the range value for the test
             range=$(cat medicalTest.txt | grep $val | grep -o '[0-9]*[.]*[0-9]*' | sed -n '1p')
             
             #get the test result value from the current line in medicalRecord.txt
             MedicalExaminationResult=$(cat medicalRecord.txt | cut -d' ' -f4 | sed -n "${i}p" | cut -d ',' -f1)
             
             #check if the test condition is less than (<) in medicalTest.txt
             cat medicalTest.txt | grep '<' > \dev\null
             
             #if the condition is '<', check if the result is greater than the range
             if [ $? -eq 0 ]
             then
                 if [ $(echo "$MedicalExaminationResult > $range" | bc ) -eq 1  ]
                 then
                     #if the result is greater, print the current line
                     cat medicalRecord.txt | sed -n "${i}p"
                 fi
             #if the condition is '>', check if the result is less than the range
             elif [ $? -ne 0 ]
             then
                 if [ $(echo "$MedicalExaminationResult < $range" | bc ) -eq 1 ]
                 then
                     #if the result is less, print the current line
                     cat medicalRecord.txt | sed -n "${i}p"
                 fi
             fi
         #if there are two ranges (e.g., a range of values)
         elif [ $count2 -eq 2 ]
         then
             #get the first and second range values
             num1=$(cat medicalTest.txt | grep $val | grep -o '[0-9]*[.]*[0-9]*' | sed -n '1p')
             num2=$(cat medicalTest.txt | grep $val | grep -o '[0-9]*[.]*[0-9]*' | sed -n '2p')
             
             #compare the range values to determine the condition
             if [ $(echo "$num2 < $num1" |bc ) -eq 1 ]
             then
                 #if the result is outside the range, print the current line
                 if [ $(echo "$MedicalExaminationResult < $num2" | bc) -eq 1 ] || [ $(echo "$MedicalExaminationResult >  $num1" | bc) -eq 1  ]
                 then
                     cat medicalRecord.txt | sed -n "${i}p"
                 fi
             elif [ $(echo "$num1 < $num2" |bc ) -eq 1 ]
             then
                 #if the result is within the range, print the current line
                 if [ $(echo "$MedicalExaminationResult > $num2" | bc) -eq 1 ] || [ $(echo "$MedicalExaminationResult <  $num1" | bc) -eq 1 ]
                 then
                     cat medicalRecord.txt | sed -n "${i}p"
                 fi
             fi
         fi
         #increment the line index
         i=$((i+1))

    done

}

function AverageValues { #function that calculates average values for each test

   #check if the file medicalRecord.txt exists
    if [ ! -e medicalRecord.txt ]
    then
        echo "File medicalRecord.txt does not exist."
        return 
    fi

    #loop through each unique test abbreviation found in medicalRecord.txt
    for TestAb in $(cut -d ',' -f1 medicalRecord.txt | cut -d ' ' -f2 | sort | uniq)
    do
        #initialize total and count variables for calculating the average
        total=0
        count=0

        #read each line from medicalRecord.txt
        while read -r Myline
        do 
            #extract the test abbreviation and test value from the current line
            TestAbLine=$(echo "$Myline" | cut -d ',' -f1 | cut -d ' ' -f2)
            TestVal=$(echo "$Myline" | cut -d',' -f3)
            
            #if the test abbreviation matches, add the value to total and increment the count
            if [ "$TestAb" = "$TestAbLine" ]
            then
                total=$(echo "$total + $TestVal" | bc)
                count=$((count + 1))
            fi

        #process the file medicalRecord.txt line by line
        done < medicalRecord.txt

        #compute and print the average if count is greater than 0
        if [ "$count" -gt 0 ]
        then
            average=$(echo "scale=2; $total / $count" | bc)
            echo "The average value for $TestAb test is: $average"
        else
            echo "No valid values for test: $TestAb"
        fi

    done

}
function UpdateTest { #funcion that updates existing entry to new value and current date

    #check if the file medicalRecord.txt exists
    if [ ! -e medicalRecord.txt ]
    then
        echo "File medicalRecord.txt does not exist."
        return 
    fi

    #prompt user to provide patient id
    echo "Please provide patient id:"
    read ID

    #validate the provided id to ensure it is exactly 7 digits
    if ! echo "$ID" | grep -qE '^[0-9]{7}$'  
    then
        echo "Invalid ID! Please insert an ID of exactly 7 digits"
        return
    fi

    #prompt user to provide test abbreviation
    echo "Please provide test abbreviation (LDL/Hgb/BGT/systole/diastole):"
    read TestAb

    #determine the unit of measurement based on the test abbreviation
    case $TestAb in
        LDL) TestUnit="mg/dL"
        ;;
        Hgb) TestUnit="g/dL"
        ;;
        BGT) TestUnit="mg/dL"
        ;;
        systole) TestUnit="mm Hg"
        ;;
        diastole) TestUnit="mm Hg"
        ;;
        *) echo "Invalid test abbreviation!"
           return
        ;;
    esac

    #check if the record exists for the given patient ID and test abbreviation
    if grep -q "^$ID: $TestAb" medicalRecord.txt
    then
        #record exists, proceed to update
        echo "Please provide the new test result value:"
        read NewValue

        #prompt user to provide the new status of the test
        echo "Please provide the new status of the test (pending/completed/reviewed):"
        read NewStatus

        #convert the status to lowercase
        statusval=$(echo "$NewStatus" | tr '[A-Z]' '[a-z]')

        #validate the new test status
        if [ "$statusval" != "pending" ] && [ "$statusval" != "completed" ] && [ "$statusval" != "reviewed" ]
        then
            echo "Invalid test status!"
            return
        fi

        #extract the old record details
        OldRecord=$(grep "^$ID: $TestAb" medicalRecord.txt)
        OldDate=$(echo "$OldRecord" | cut -d ',' -f2 | cut -d ' ' -f2)
        OldResult=$(echo "$OldRecord" | cut -d ',' -f3 | cut -d ' ' -f2)
        OldStatus=$(echo "$OldRecord" | cut -d ',' -f5)
        NewDate=$(date +%Y-%m)

        #update the old record with new values
        grep "^$ID: $TestAb" medicalRecord.txt | sed -i "s/$OldDate/$NewDate/" medicalRecord.txt
        grep "^$ID: $TestAb" medicalRecord.txt | sed -i "s/$OldResult/$NewValue/" medicalRecord.txt
        grep "^$ID: $TestAb" medicalRecord.txt | sed -i "s/$OldStatus/$NewStatus/" medicalRecord.txt

        echo "Test result updated successfully."
    else
        #record does not exist
        echo "Record not found for patient ID $ID and/or test abbreviation $TestAb."
    fi
}
function DeleteTest { #function that deletes outdated or incorrect entries

    #check if the file medicalRecord.txt exists
    if [ ! -e medicalRecord.txt ]
    then
        echo "File medicalRecord.txt does not exist."
        return 
    fi

    #prompt user to select an option for deletion
    echo "Enter 1 to delete outdated tests"
    echo "Enter 2 to delete incorrect tests"
    read status 

    if [ $status -eq 1 ]
    then
        #extract the current year and month
        year=$(date +"%Y")   #extracting the full year 
        month=$(date +"%m")  #extracting the month as a 2 digit number
        month=$((10#$month)) #convert month to integer (to prevent octal base error)

        touch temp.txt

        while read -r Myline
        do
            #extract year and month from the record
            medRecYear=$(echo "$Myline" | cut -d ' ' -f3 | cut -d '-' -f1)
            medRecMonth=$(echo "$Myline" | cut -d ' ' -f3 | cut -d '-' -f2 | cut -d ',' -f1)
            medRecMonth=$((10#$medRecMonth)) #convert month to integer

            #calculate the difference in years and months
            if [ $((year - medRecYear)) -gt 1 ] || { [ $((year - medRecYear)) -eq 1 ] && [ $((month - medRecMonth + 12)) -gt 12 ]; }
            then
                continue
            fi

            #write non-outdated records to the temp file
            echo "$Myline" >> temp.txt
        done < medicalRecord.txt

        #replace the original file with the updated file
        mv temp.txt medicalRecord.txt
        echo "File deletion of outdated entries successful!"

    elif [ $status -eq 2 ]
    then
        touch tmpfile.txt

        while read -r Myline
        do
            flag=0

            #extract fields from the line using cut
            ID=$(echo "$Myline" | cut -d ' ' -f1 | cut -d ':' -f1)
            TestAb=$(echo "$Myline" | cut -d ' ' -f2 | cut -d ',' -f1)
            TestDate=$(echo "$Myline" | cut -d ',' -f2)
            TestVal=$(echo "$Myline" | cut -d ',' -f3)
            TestUnit=$(echo "$Myline" | cut -d ',' -f4)
            TestStatus=$(echo "$Myline" | cut -d ',' -f5)

            #validate the ID
            if ! echo "$ID" | grep -qE '^[0-9]{7}$'
            then
                echo "Invalid ID detected!"
                flag=1
            fi

            #validate the test abbreviation
            case $TestAb in
                LDL) 
                ;;
                Hgb) 
                ;;
                BGT) 
                ;;
                systole) 
                ;;
                diastole) 
                ;;
                *) echo "Invalid test abbreviation detected!"
                   flag=1
                ;;
            esac

            #validate the year in the test date
            yearval=$(echo "$TestDate" | cut -d '-' -f1)
            if [ "$yearval" -lt 2000 ] || [ "$yearval" -gt 2024 ]
            then
                echo "Outdated year detected!"
                flag=1
            fi

            #validate the month in the test date
            monthval=$(echo "$TestDate" | cut -d '-' -f2)
            if [ "$monthval" -lt 01 ] || [ "$monthval" -gt 12 ]
            then
                echo "Invalid month detected!"
                flag=1
            fi

            #validate the test status
            statusval=$(echo "$TestStatus" | tr '[A-Z]' '[a-z]')
            if [ "$statusval" != "pending" ] && [ "$statusval" != "completed" ] && [ "$statusval" != "reviewed" ]
            then
                echo "Invalid test status detected!"
                flag=1
            fi

            #write valid records to the temp file
            if [ "$flag" -eq 0 ]
            then
                echo "$Myline" >> tmpfile.txt
            fi
        done < medicalRecord.txt

        mv tmpfile.txt medicalRecord.txt
        echo "File deletion of incorrect entries successful!"

    else 
        #handle invalid option
        echo "Invalid option! Please select 1 or 2"
    fi
}

i=1 #this is a flag for the main menu to run
echo "Welcome to Our Medical Test Management System!"

while [ $i -ne -1 ]
do
echo "Main Menu"
echo ""
echo "1- Add a new medical test record: "
echo ""
echo "2- Search for a test by patient ID: "
echo ""
echo "3- Search for upnormal tests for all patients: "
echo ""
echo "4- Print average test value: "
echo ""
echo "5- Update an existing test result:"
echo ""
echo "6- Delete outdated or incorrect test result: "
echo ""
echo "7- Exit System"

read choice 
case $choice in 
1) AddTest
;;
2) PatientID
;;
3) upNormalForALLPatients
;;
4) AverageValues
;;
5) UpdateTest
;;
6) DeleteTest
;;
7) i=-1
   echo "Thank you for using our system! Goodbye."
;;
*) echo "Invalid number! Please select a valid option. (1-7)"
;;
esac
done
