# Optionally edit: 
STACK=s3-analytics-athena

# Required edit
DEPLOY_BUCKET=werberm-sandbox            # must already exist
ANALYTICS_BUCKET=werberm-s3-tests-logs   # must already exist
ANALYTICS_KEY_PREFIX="s3_analytics"      # leave off trailing slash, this should be whatever proceeds "/bucket=bucket123" in your analysis config

echo 'Creating CloudFormation package...'
aws cloudformation package \
  --template-file template.yaml \
  --s3-bucket $DEPLOY_BUCKET \
  --output-template-file packaged-template.yaml

# Deploy our changes
echo 'Deploying CloudFormation package...'
aws cloudformation deploy \
  --template-file packaged-template.yaml \
  --stack-name $STACK \
  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
  --parameter-overrides AnalyticsBucket="$ANALYTICS_BUCKET" AnalyticsKeyPrefix="$ANALYTICS_KEY_PREFIX"

  aws s3 cp template.yaml