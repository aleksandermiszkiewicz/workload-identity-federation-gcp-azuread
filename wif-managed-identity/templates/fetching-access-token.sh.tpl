#!/bin/bash

# login as a service principal
az login --identity

# fetching Azure JWT
jwt=$(az account get-access-token --resource=api://${azure_application_id} --query accessToken --output tsv)

echo "Azure JWT:"
echo $jwt
echo

# fetching access token from Security Token Service
STS_TOKEN=$(curl https://sts.googleapis.com/v1/token \
    --data-urlencode "audience=//iam.googleapis.com/${gcp_workload_identity_pool_provider_name}" \
    --data-urlencode "grant_type=urn:ietf:params:oauth:grant-type:token-exchange" \
    --data-urlencode "requested_token_type=urn:ietf:params:oauth:token-type:access_token" \
    --data-urlencode "scope=https://www.googleapis.com/auth/cloud-platform" \
    --data-urlencode "subject_token_type=urn:ietf:params:oauth:token-type:jwt" \
    --data-urlencode "subject_token=$jwt" | jq -r .access_token)

echo "Security Token Service access token:"
echo $STS_TOKEN
echo


# fetching final token from IAM Service Account Credentials API
ACCESS_TOKEN=$(curl -0 -X POST https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/${gcp_service_account_email}:generateAccessToken \
    -H "Content-Type: text/json; charset=utf-8" \
    -H "Authorization: Bearer $STS_TOKEN" \
    -d @- <<EOF | jq -r .accessToken
    {
        "scope": [ "https://www.googleapis.com/auth/cloud-platform" ]
     }
EOF
)

echo "IAM Credentials access token:"
echo $ACCESS_TOKEN
