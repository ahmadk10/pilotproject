APPID=$(aws amplify list-apps --region us-east-2 --query "apps[*].{name:name, appId:appId}" --output text | grep -i "Next" | cut -f1)
BRANCH=master

echo "Deploying app $APPID branch $BRANCH"

JOB_ID=$(aws amplify list-jobs --app-id $APPID --branch-name $BRANCH --max-items 1 | jq -r [.[]][0][].jobId)
echo $JOB_ID
# Get job status till success
while [[ "$(aws amplify get-job --app-id $APPID --branch-name $BRANCH --job-id $JOB_ID | jq -r '.job.summary.status')" =~ ^(PENDING|RUNNING)$ ]]; do sleep 1; done
JOB_STATUS="$(aws amplify get-job --app-id $APPID --branch-name $BRANCH --job-id $JOB_ID | jq -r '.job.summary.status')"
if [ -z "$JOB_STATUS" ]; then
    exit 1
fi
echo "Job finished"
echo "Job status is $JOB_STATUS"
if [ $JOB_STATUS == 'FAILED'  ]; then
    exit 1
fi
