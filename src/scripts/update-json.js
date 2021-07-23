const fs = require('fs');
const csv = require('csv-parser');

module.exports = {
  updateJson: () => {
    console.log('running update-json');
    let updatedJsonData = [];
    //The directory where the JSON files live
    let sourceFileDirectory = 'src/split-to-300k/original-300k-files/';
    //The directory where the updated JSON files will go.
    let updatedFileDirectory = 'src/split-to-300k/300k-done/';
    let count = 0;
    let numberOfJsonFiles;

    // Get the number of files dynamically
    fs.readdir(sourceFileDirectory, async (err, files) => {
      if (err) {
        console.log('There was an error reading the number of files');
        return;
      }
      
      numberOfJsonFiles = files.length;
      console.log('files length', numberOfJsonFiles);

      // Promise used to ensure the prior process is complete before moving on to the next
      await Promise.all(files.map((file, idx) => {
        try {
          const rawData = fs.readFileSync(
            sourceFileDirectory + file
          );

          const jsonData = JSON.parse(rawData);

          const newJsonData = jsonData.map((item) => {
            // Search the JSON in each user for the app_metadata key
            // If it is not there, create it and fill it with the data
            if (!item.app_metadata) {
              item.app_metadata = {
                tng_id: item.app_metadata_tng_id,
              };

              delete item.app_metadata_tng_id;
            }

            return item;
          });

          updatedJsonData = newJsonData;

          console.log('Writing to new file:', jsonData);

          const humanReadableJson = JSON.stringify(newJsonData, null, 2);

          //Create new files and add them to the specified directory
          fs.writeFileSync(
            `${updatedFileDirectory}${file}`,
            humanReadableJson
          );

          console.log('Files updated:', idx+1);
        } catch (err) {
          console.log('An Error happend while updating the file', err);
        }

      }));
    });
  },
};
