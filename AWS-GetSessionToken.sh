#!/bin/bash
#Author: n33dle

echo "This script will set a valid AWS Access ID, Secret Key and Session Token for AWS CLI use"
echo " "
echo "Make sure you run this in the current user context, to keep env vars after execution"
echo "run using either:"
echo ". ./AWS-GetSessionToken.sh"
echo "or"
echo "source ./AWS-GetSessionToken.sh"
echo " "

echo -n "[?} Do you want to clear your current AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and AWS_SESSION_TOKEN environmental variables (y/n)? "
read answer

# if echo "$answer" | grep -iq "^y" ;then

if [ "$answer" != "${answer#[Yy]}" ] ;then
    unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
else
    echo "Ok boomer"
fi

echo " "
echo "Enter your AWS Access ID"
read aws_access_id
export AWS_ACCESS_KEY_ID="$aws_access_id"

echo " "
echo "Enter your AWS Secret Key"
read aws_secret_key
export AWS_SECRET_ACCESS_KEY="$aws_secret_key"

echo " "
echo "Enter your username ARN"
read aws_user_arn

echo " "
echo "Enter your MFA code"
read aws_mfa_code

echo " "
echo "[-] Authenticating to client environment to retreive a session token"
aws sts get-session-token --duration-seconds 3600 --serial-number $aws_user_arn --token-code $aws_mfa_code > temp-mfacreds-json

echo " "
echo "[-] Setting new tokens and keys"

unset AWS_SECRET_ACCESS_KEY AWS_SECRET_KEY AWS_SESSION_TOKEN

sed -i 's/\"//g;s/\,//g' temp-mfacreds-json

export AWS_SECRET_ACCESS_KEY=`cat temp-mfacreds-json | grep SecretAccessKey | awk '{print $2}'`
export AWS_ACCESS_KEY_ID=`cat temp-mfacreds-json | grep AccessKeyId | awk '{print $2}'`
export AWS_SESSION_TOKEN=`cat temp-mfacreds-json | grep SessionToken | awk '{print $2}'`
rm temp-mfacreds-json

echo " "
echo "[-] Done. The following environment variables have been set:"

echo " "
export | grep AWS | awk '{print $3}'
