# Auth0 User Migration Process

## Steps:

Before you begin, make sure that you have updated the

```
auth0_upload_variables.txt
```

file with the desired values for the **TENANT_URL** and the **BEARER_TOKEN**.
These values are read by the process within the curl-users.sh file. You can get a new token from Auth0 and add it as the value for BEARER_TOKEN.

## Step 1:

Using a Database Client such as DBeaver, connect to the DB and run the following SQL:

#### **NOTE: This will be updated to include social media information**

```
SQL STUFF GOES HERE
```

## Step 2:

Export the resulting files as JSON. Set the file export size to no more than 300k. Be sure to point the exported
files to the **_split-to-300K/original-300K-files/_** directory.

## Step 3:

In terminal, be sure to make the following files executable with chmod + x:
**curl-users.sh**
**replaceInline.sh**
**initMigration.sh**

## Step 4:

Run the **initMigration.sh** script in terminal (_./initMigration.sh_) and sit back and relax.

## NOTE:

The cURL process in the curl-users.sh file is set to cURL every 2 minutes until all the files in the directory have been uploaded. If you feel brave, you can lower the time to 1 minute but I would not go below that since Auth0 uploads for exporting a user takes a bit.
