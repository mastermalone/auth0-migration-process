const fs = require('fs');

module.exports = {
  updateJson: () => {
    console.log('running update-json');
    let updatedJsonData = [];
    // The directory where the JSON files live
    let sourceFileDirectory = 'src/split-to-300k/original-300k-files/';
    // The directory where the updated JSON files will go.
    let updatedFileDirectory = 'src/split-to-300k/300k-done/';
    let numberOfJsonFiles;

    // Read the source files directory
    fs.readdir(sourceFileDirectory, async (err, files) => {
      if (err) {
        console.log(
          `There was an error reading the ${sourceFileDirectory} directory.`
        );
        return;
      }

      // Useful info for the dev
      numberOfJsonFiles = files.length;
      console.log('Number of files to update:', numberOfJsonFiles);

      // Promise used to ensure the prior process is complete before moving on to the next
      await Promise.all(
        files.map((file, idx) => {
          try {
            const rawData = fs.readFileSync(sourceFileDirectory + file);

            const jsonData = JSON.parse(rawData);

            const newJsonData = jsonData.map((item) => {
              // Create the app_metadata object.  Search the JSON in each user for the app_metadata_tng_id key
              // Add the tng_id key to the app_metadata object and assign the app_metadata_tng_id value
              if (!item.app_metadata) {
                item.app_metadata = {};
                item.app_metadata.tng_id = item.app_metadata_tng_id;

                // If there are social login ID's, or the universal ID add them
                if (
                  typeof item.app_metadata_facebook_ids !== 'object' &&
                  typeof item.app_metadata_facebook_ids.length
                ) {
                  item.app_metadata.facebook_ids =
                    item.app_metadata_facebook_ids.split(',');
                }
                if (
                  typeof item.app_metadata_twitter_ids !== 'object' &&
                  typeof item.app_metadata_twitter_ids.length
                ) {
                  item.app_metadata.twitter_ids =
                    item.app_metadata_twitter_ids.split(',');
                }

                item.app_metadata_tng_universal_id !== null &&
                  (item.app_metadata.tng_universal_id =
                    item.app_metadata_tng_universal_id);

                delete item.app_metadata_tng_id;
                delete item.app_metadata_facebook_ids;
                delete item.app_metadata_twitter_ids;
                delete item.app_metadata_tng_universal_id;
              }

              //Add new, custom_password_hash key and provide in the values
              if (!item.custom_password_hash) {
                item.custom_password_hash = {
                  algorithm: 'md5',
                  hash: {
                    value: item.hashed_password,
                    encoding: 'hex',
                  },
                  salt: {
                    value: item.salt_value,
                    encoding: 'utf8',
                    position: 'prefix',
                  },
                };

                delete item.hashed_password;
                delete item.salt_value;
              }

              //If these keys are empty, null or full of empty space, delete them.
              !/[a-zA-Z]/.test(item.name) && delete item.name;
              !/[a-zA-Z]/.test(item.given_name) && delete item.given_name;
              !/[a-zA-Z]/.test(item.family_name) && delete item.family_name;
              typeof item.name === 'object' && delete item.name;
              typeof item.given_name === 'object' && delete item.given_name;
              typeof item.family_name === 'object' && delete item.family_name;

              return item;
            });

            updatedJsonData = newJsonData;

            console.log('Writing to new file:', file);

            const humanReadableJSON = JSON.stringify(newJsonData, null, 2);

            //Create new files, fill them with the updated data and add them to the specified directory
            fs.writeFileSync(
              `${updatedFileDirectory}${file}`,
              humanReadableJSON
            );

            console.log('Files updated:', idx + 1);
          } catch (err) {
            console.log('An Error ocurred while updating the file', err);
          }
        })
      );
    });
  },
};
