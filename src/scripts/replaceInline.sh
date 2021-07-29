#!/bin/bash
# Loops through the files in the target directory and replaces the specified lines that match the variables
# NOTE:  If the script seems like it's not updating the files, check the JSON fiels for the targeted keys and their values.  They must match exactly
# Version update:  Removes the need for the .csv file
file=$1;
char=['!:@#$%^&*()_+'];
# endOfTheLine=$mline | awk '{print $2}';
email0Line='"email_verified" : 0';
email0Update='"email_verified": false';
email1Line='"email_verified" : 1';
email1Update='"email_verified": true';
pictureLine='"picture" : null,';
pictureUpdate='"picture": "https://path/to/image.jpg",';
yellow=`tput setaf 3`;
nc=`tput sgr0`;

openingBracket="[";
closingBracket="]";
unnecessaryLine="SELECT";
emptyLine="";
erroneousFinalClosingBracket="]}";

targetFolder=($(dirname "$PWD")/split-to-300k/original-300k-files);

function replaceInline() {
  echo "Starting replace inline process...";

  fileCount=0;
  linesUpdated=0;
  
  #Remove log files if they exist
  if [[ -f results.txt ]];
  then
    rm results.txt;
  fi

  if [[ -f result-errors.txt ]];
  then
    rm result-errors.txt;
  fi

  # Start Updated script which correctly opens and closes the exported JSON files
  if [[ -d $targetFolder ]];
  then
    echo "Found the $targetFolder directory";

    count=0;

    for json_file in $targetFolder/*; 
    do
      count=0
      if [[ -f $json_file ]];
      then
        echo ${yellow}"Working on $json_file ...."${nc};
        firstLine="$(head -n 1 $json_file)";

        #Replace the first line in the file with an opening bracket
        sed -i "0,/$firstLine/s//$openingBracket/" $json_file;
        # Remove the erroneous line at the end of the last file created by Dbeaver.
        sed -i "/$erroneousFinalClosingBracket/d" $json_file;
        
        # Read the file line by line
        while IFS=$'\n' read -r mline || [[ $mline ]];
        do
          if [[ "$mline" =~ $unnecessaryLine ]];
          then
            # Remove the unnecessary line from the first generated JSON file
            sed -i "/$unnecessaryLine/d" $json_file;
            echo "FOUND THE SELECT statement and removed it.";
            linesUpdated=`expr $linesUpdated + 1`;
          fi

          # Replace email verified: 0 with email verified: false
          if [[ "$mline" =~ $email0Line ]];
          then
            # echo "found a match for email verified 0: $mline";
            # the @ before the 's' is the delimiter.  It can be anything you want such as a |
            # This was done to prevent the script from choking on values that contained double quotes
            sed -i "s@$mline@$email0Update@" $json_file;
            linesUpdated=`expr $linesUpdated + 1`;
          fi

          # Replace email verified: 1 with email verified: true
          if [[ "$mline" =~ $email1Line ]];
          then
            # echo "found a match for email verified 1: $mline";
            sed -i "s@$mline@$email1Update@" $json_file;
            linesUpdated=`expr $linesUpdated + 1`;
          fi

          # Replace the value of picture keys with a null value
          if [[ "$mline" =~ $pictureLine ]];
          then
            # echo "found a picture: $mline";
            sed -i "s@$mline@$pictureUpdate@" $json_file;
            linesUpdated=`expr $linesUpdated + 1`;
          fi
          # echo "";
        done < $json_file
        wait
        touch results.txt;
        echo "The process has finished with a total of $linesUpdated lines updated including the $json_file file";
        echo "The process has finished with a total of $linesUpdated lines updated including the $json_file file" >> results.txt;
      else
        echo ${yellow}"No JSON files found.  Be sure that the $targetFolder contains the exported JSON files."${nc};
        exit 0;
      fi
      # Insert closing bracket at end of file
      echo $closingBracket >> $json_file;
    done
    wait
  else
    echo ${yellow}"ERROR: The $targetFolder directory does not exist"${nc};
  fi

  # End Updated script
}

replaceInline