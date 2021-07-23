#!/bin/bash
# Usage  Just call this without any arguments.  It uses the auth0_upload_variables.txt file
# to supply the tenant, connection_id and the token for the cURL to Auth0
# Example call:
# ./curl-users.sh
# Be sure to replace the Bearer token with a fresh one from Auth0
# Be sure to update the tenant url to point to the correct auth0 tenant

count=0;
targetFolder=../split-to-300k/original-300k-files;
# Import variables from this file.  Update the varibales in this file with different tenants and a new token from Auth0 if needed
source auth0_upload_variables.txt;

function curlUsersToAuth0 () {
  json_file=$1;

  if [ -f curl_erros.txt ]; 
    then
      rm curl_erros.txt
  fi

  # If the file exists, proceed to cURL the data to Auth0
  if [ -f $json_file ];
  then
    echo "Sending users to Auth0 from file: $json_file...";
  curl --request POST \
    --url '"'"$TENANT_URL"'"' \
    --header 'authorization: Bearer' "$BEARER_TOKEN"'' \
    --form users=@"$json_file" \
    --form connection_id=$CONNECTION_ID
  else
    touch curl_erros.txt;

    echo "Not such file $json_file.  No users have been migrated from this file.";
    echo "Not such file $json_file.  No users have been migrated from this file." >> curl_erros.txt;
    echo "You need to provide actual JSON files for this process to work.";
    exit 1;
  fi
  
  count=`expr $count + 1`;
}

#Make sure this can be called with watch functon if needed.  Not needed so far.
export -f curlUsersToAuth0;

function startUserUpload () {
  # Loop to upload each file every 2 minutes to Auth0
  for json_file in $targetFolder/*; do
    curlUsersToAuth0 $json_file
    sleep 2m
  done
  echo "The Process has finished. $count files have been uploaded to Auth0.";
  # watch -n 3 -x bash -c curlUsersToAuth0;
}

startUserUpload

