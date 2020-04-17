#!/bin/bash

# export vars for extrapolation
set -a

# CMD Line Input:
WORK_DIR=$1
SSH_KEY=$2

cd ${WORK_DIR-.}

# Check ENV
if [ -z "$DEPLOY_NAME" ]; then echo "No DEPLOY_NAME Provided"; exit 1; fi
if [ -z "$SSH_KEY" ]; then echo "No SSH_KEY Provided"; exit 1; fi
if [ -z "$MATURITY" ]; then echo "No MATURITY Provided"; exit 1; fi
if [ -z "$AWS_PROFILE" ]; then echo "No AWS_PROFILE Provided"; exit 1; fi
if [ -z "$AWS_REGION" ]; then echo "No AWS_REGION Provided"; exit 1; fi

AWSENV="--profile=$AWS_PROFILE --region=$AWS_REGION"
export AWS_ACCOUNT_ID=`aws sts get-caller-identity --output text --query 'Account'`

# Stack Setup
STACKNAME=${DEPLOY_NAME}-cumulus-${MATURITY}
echo "Stack name: ${STACKNAME}"
API=$(aws apigateway $AWSENV get-rest-apis --query "items[?ends_with(name, '${STACKNAME}-archive')].id" --output=text)
if [ ${#API} -le 4 ]; then echo "Could not figure out API AWS for $STACKNAME using profile $AWS_PROFILE" ; exit 1; fi
CUMULUS_BASEURL=$(echo "https://${API}.execute-api.${AWS_REGION}.amazonaws.com/${MATURITY}")
echo "API is $CUMULUS_BASEURL"

# Grab the landing SNS:
# SNSTOPIC=$(aws $AWSENV cloudformation describe-stacks --stack-name $STACKNAME --query "Stacks[0].Outputs[?OutputKey=='LandingTopic'].OutputValue" --output=text)
# echo SNSTOPIC is $SNSTOPIC

# set up SSH tunnel through bastion to allow us to talk to private API Gateway
export BASTION=$(aws ec2 $AWSENV describe-instances --filters "Name=tag:Name,Values=NGAP SSH Bastion" --query "Reservations[0].Instances[0].NetworkInterfaces[0].Association.PublicDnsName" --output=text)
if [ ${#BASTION} -le 20 ]; then echo "Could not determine Bastion host"; exit 1; fi
ssh-keygen -f "/home/kbeam/.ssh/known_hosts" -R $BASTION
ssh -i $SSH_KEY -fN -D localhost:8001 ec2-user@$BASTION
if [ ! $? -eq 0 ]; then echo "Could not establish proxy SSH connection"; exit 1; fi
SSH=$(pgrep -f 'ssh -fN -D localhost:8001')
export PROXY='--proxy socks5h://localhost:8001'

# Get the token URL
ORIGIN=$(dirname $CUMULUS_BASEURL)
LOGIN_URL="$CUMULUS_BASEURL/token"
BACKEND_URL="$CUMULUS_BASEURL/v1"
echo "Origin: ${ORIGIN}"

# create a base64 hash of your login credentials

if [ -z "$EARTHDATA_USERNAME" ]; then echo "No EARTHDATA_USERNAME Provided"; exit 1; fi
if [ -z "$EARTHDATA_PASSWORD" ]; then echo "No EARTHDATA_PASSWORD Provided"; exit 1; fi
AUTH=$(printf "$EARTHDATA_USERNAME:$EARTHDATA_PASSWORD" | base64)
echo "Auth: ${AUTH}"

# Request the Earthdata url with client id and redirect uri to use with Cumulus
echo ">>> Attempting auth @ ${LOGIN_URL}"
echo $PROXY
echo $LOGIN_URL
AUTHORIZE_URL=$(curl $PROXY -s -i ${LOGIN_URL} | grep location | sed -e "s/^location: //");
if [ -z "$AUTHORIZE_URL" ]; then echo "Could not contact Auth API; CHECK VPN!"; exit 1; fi
echo "Authorize url: ${AUTHORIZE_URL}"

# Request an authorization grant code
echo "curl $PROXY -s -i -X POST \
  -F "credentials=${AUTH}" \
  -H "Origin: ${ORIGIN}" \
  ${AUTHORIZE_URL%$'\r'}"

TOKEN_URL=$(curl $PROXY -s -i -X POST \
  -F "credentials=${AUTH}" \
  -H "Origin: ${ORIGIN}" \
  ${AUTHORIZE_URL%$'\r'} | grep Location | sed -e "s/^Location: //")
echo "Token url: ${TOKEN_URL}"

# Validate there is a `code` redirect
if [[ ! $TOKEN_URL =~ "code=" ]]; then echo "Could not get token redirect, check URS App Redirect URI for $CUMULUS_BASEURL/token"; exit 1; fi

# Request the token through the CUMULUS API url that's returned from Earthdata
TOKEN=$(curl $PROXY -s ${TOKEN_URL%$'\r'} | sed 's/.*\"token\"\:\"\(.*\)\".*/\1/')
if [ ${#TOKEN} -le 10 ]; then echo "Could not get TOKEN for API Access" ; exit 1; fi
TH="--header 'Authorization: Bearer $TOKEN'"
echo ">>> Bearer token was: ${TOKEN:0:10}..."

for TYPE in providers collections rules; do
    T_PATH=$TYPE/
    echo ">>> Processing $TYPE from $T_PATH"
    for OBJECT in `ls -1 $T_PATH`; do
        echo ">>> checking out ${TYPE}: $OBJECT"

        # Figure out the unique id
        if [[ $TYPE =~ .*providers.* ]]; then
            ID=$(cat ${T_PATH}$OBJECT | grep '"id"' | sed 's/.*\"id\"\:[^\"]*\"\([^\"]*\)\".*/\1/')
        else
            ID=$(cat ${T_PATH}$OBJECT | grep '"name"' | sed 's/.*\"name\"\:[^\"]*\"\([^\"]*\)\".*/\1/' | head -1)
        fi

        if [[ $TYPE =~ .*collection.* ]]; then
            # need to know the Version for collections
            VERSION=$(cat ${T_PATH}$OBJECT | grep '"version"' | sed 's/.*\"version\"\:[^\"]*\"\([^\"]*\)\".*/\1/')
            ID="${ID}/${VERSION}"
        fi

        URL=$BACKEND_URL/$TYPE/$ID

        # Check if this Object exists
        echo "Checking if object exist.... "
        CREATED=$(eval $( echo curl $PROXY -s $TH ${URL} ) )

        echo " >>> Created value was $CREATED"

        if [[ $CREATED =~ .*createdAt.* ]]; then
            # Do an update
            URL=$BACKEND_URL/$TYPE/$ID
            echo "ID IS >>>>$ID<<<<<"
            echo ">>> Updating $TYPE ID:${ID} @ $BACKEND_URL/$TYPE/$ID"
            TH2='--header "Content-Type: application/json"'
            # echo curl $PROXY -s --request PUT $TH $TH2 $URL -d @${T_PATH}$OBJECT

            # extrapolate ENV Vars inside the json
            perl -pe 's/\$([_A-Z]+)/$ENV{$1}/g' < ${T_PATH}$OBJECT > /tmp/$OBJECT
            echo ">>> Wrote filtered object /tmp/$OBJECT"
            echo "RUNNING UPDATE>>> curl $PROXY -s --request PUT $TH $TH2 $URL -d @/tmp/$OBJECT"
            UPDATEDOBJECT=$(eval $( echo curl $PROXY -s --request PUT $TH $TH2 $URL -d @/tmp/$OBJECT ) )

            if [[ $UPDATEDOBJECT =~ .*createdAt.* ]]; then
                echo ">>> $ID Successfully Updated: $UPDATEDOBJECT"
            else
                echo ">>> Failed to update $TYPE $ID: $UPDATEDOBJECT"
                exit 1;
            fi
        else
            # Do a Put
            echo ">>> Creating $TYPE $ID"
            URL=$BACKEND_URL/$TYPE
            TH2='--header "Content-Type: application/json"'
            # echo curl $PROXY -s --request POST $TH $TH2 $URL -d @${T_PATH}$OBJECT

            # extrapolate ENV Vars inside the json
            perl -pe 's/\$([_A-Z]+)/$ENV{$1}/g' < ${T_PATH}$OBJECT > /tmp/$OBJECT
            echo ">>> Wrote filtered object /tmp/$OBJECT"
            echo "RUNNING CREATE>>> curl $PROXY -s --request POST $TH $TH2 $URL -d @/tmp/$OBJECT"
            NEWOBJECT=$(eval $( echo curl $PROXY -s --request POST $TH $TH2 $URL -d @/tmp/$OBJECT ) )

            if [[ $NEWOBJECT =~ .*(createdAt|Record saved).* ]]; then
                echo ">>> $ID Successfully Created: $NEWOBJECT"
            else
                echo ">>> Failed to create $TYPE $ID: $NEWOBJECT"
                echo curl $PROXY -s --request POST $TH $TH2 $URL -d @${T_PATH}$OBJECT
                exit 1;
            fi
        fi
    done
done

kill -9 $SSH
