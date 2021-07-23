#!/bin/bash
targetFolder=../split-to-300k/original-300k-files;
function init_migration () {
  echo "Initiating User Migration Process to Auth0";
  
  first_directory_to_clean=../split-to-300k/300k-done;

  # Remove any prevously generated files from the 300k-done directory
  if [ "$(ls -A $first_directory_to_clean)" ];
    then
      echo "The directory is not empty";
      cleanDirectory $first_directory_to_clean;
  fi

  # Step 1: Clean up exported JSON files and replace specififed values
  # Step 2: Generate the updated files which include the app_metadata key and values
  # Step 3: Finally, cURL the files to Auth0
  ./replaceInline.sh && npm run generate && ./curl-users.sh
}

function cleanDirectory () {
  directory=$1;
  rm $directory/*;
  echo "Cleaned out any previously generated JSON files from a prior run..";
}

init_migration