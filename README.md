# Amazon S3 Analytics Reporting With Amazon Athena

If you enable [S3 Analytics](https://docs.aws.amazon.com/AmazonS3/latest/dev/analytics-storage-class.html) on a given Amazon S3 bucket, then the S3 service will show you an analysis including but not limited to object counts and data retrieval by storage class, object age, etc. 

You can view this analysis in the S3 web console and optionally choose to deliver the analysis as a CSV file to an S3 bucket and prefix of your choosing. 

This is great for one-off bucket analysis, but what if you want reporting in aggregate?

This project let's you do just that!

# Architecture

This project creates an AWS Glue database and table in the Glue catalog and then creates and runs a crawler that populates the table with new partitions each time an analytics report is delivered. 

Once the catalog table is populated, you may then query the table using Amazon Redshift Spectrum, Amazon QuickSight, Amazon Athena, or Amazon EMR.

# Pre-requisites

1. You have enabled S3 Analytics on one or more existing source buckets

2. You have an existing S3 bucket to use for your CloudFormation deployment artifacts

2. Your analytics reports must be configured with a prefix as follows: 

  ```
  s3://my_bucket/s3_analytics/bucket=bucket_abc/bucket_abc_analytics-config.csv
  ```

  In the example above:

  * `my_bucket` is any existing bucket of your choosing where your analytics will be sent

  * `s3_analytics/bucket=bucket_abc` is the prefix specified in the S3 Analytics config of each bucket. Note that you can change the value of `s3_analytics/`, but if you do, it must be the same for all buckets' analytics configurations. The `bucket=bucket_abc` is required for Glue/Athena to properly read the bucket name. Obviously, you need to replace `bucket_abc` with the actual bucket name. 

  * `bucket_abc_analytics-config.csv` is the object that the S3 Analytics service will deliver for you. You don't need to create this file or worry about its name. 

  3. When specifiying the prefix values above, be sure to only use **lowercase** characters.

# Deployment

1. Open `template.yaml` and edit the following values as needed:

  ```sh
  DEPLOY_BUCKET=werberm-sandbox
  ANALYTICS_BUCKET=werberm-s3-tests-logs   
  ANALYTICS_KEY_PREFIX="s3_analytics"   # Do not include the "/bucket=" portion
  ```

  * `DEPLOY_BUCKET` is where your CloudFormation template will be uploaded. 
  * `ANALYTICS_BUCKET` is where you've already configured your analytics reports to be sent
  * `ANALYTICS_KEY_PREFIX` is the prefix you configured in your analytics reports, **EXCLUDING** the `/bucket=` portion!

2. Run `./deploy.sh` to deploy the stack

# Querying Athena

1. Open the [Athena Console](https://console.aws.amazon.com/athena/home)

2. Select the `s3_analytics_db` on the left side of the screen

3. Run the command below and verify that at least one partition is present. If no partitions are present, there are neither no S3 Analytics reports delivered yet *or* there's a problem somewhere in your configuration or my project code. 

  ```SQL
  show partitions s3_analytics;
  ``` 

4. If at least one partition was present, run the following command to view a sample of results: 

  ```SQL
  select * from s3_analytics limit 50;
  ```