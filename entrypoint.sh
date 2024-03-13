#!/usr/bin/env bash
set -e

INPUT_DOCKERFILE=${INPUT_DOCKERFILE:-Dockerfile}
INPUT_TAG=${INPUT_TAG:-${GITHUB_SHA::8}}
INPUT_BRANCH=${INPUT_BRANCH:-master}
IMAGE_PART=""
if [ -n "$INPUT_BUILD_ARGS" ]; then
        BUILD_ARGS=`echo -n $INPUT_BUILD_ARGS | jq -j '.[] | to_entries[] | "--build-arg \(.key)=\"\(.value)\" "'`
fi

if [ "$INPUT_IMAGE" != "" ]; then
        IMAGE_PART="/${INPUT_IMAGE}"
fi

echo "Logging into azure.."
az login --service-principal -u ${INPUT_SERVICE_PRINCIPAL} -p ${INPUT_SERVICE_PRINCIPAL_PASSWORD} --tenant ${INPUT_TENANT}

echo "Sending build job to ACR.."
echo "az acr build -r ${INPUT_REGISTRY} ${BUILD_ARGS} -f ${INPUT_DOCKERFILE} -t ${INPUT_REPOSITORY}${IMAGE_PART}:${INPUT_TAG} ${INPUT_FOLDER}"
cd ${INPUT_FOLDER}
az acr build -r ${INPUT_REGISTRY} ${BUILD_ARGS} -f ${INPUT_DOCKERFILE} -t ${INPUT_REPOSITORY}${IMAGE_PART}:${INPUT_TAG} .
