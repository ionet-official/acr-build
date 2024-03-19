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

if [ "$INPUT_GIT_ACCESS_TOKEN" = "local" ]; then
        echo "Building Docker image ${INPUT_REPOSITORY}${IMAGE_PART}:${INPUT_TAG} from local using context ${INPUT_FOLDER} ; and pushing it to ${INPUT_REGISTRY} Azure Container Registry"
        cd ${INPUT_FOLDER}
        BUILD_URI="."
else
        if [ -n "$INPUT_GIT_ACCESS_TOKEN" ]; then
                GIT_ACCESS_TOKEN_FLAG="${INPUT_GIT_ACCESS_TOKEN}@"
        fi
        echo "Building Docker image ${INPUT_REPOSITORY}${IMAGE_PART}:${INPUT_TAG} from ${GITHUB_REPOSITORY} on ${INPUT_BRANCH} and using context ${INPUT_FOLDER} ; and pushing it to ${INPUT_REGISTRY} Azure Container Registry"
        BUILD_URI="https://${GIT_ACCESS_TOKEN_FLAG}github.com/${GITHUB_REPOSITORY}.git#${INPUT_BRANCH}:${INPUT_FOLDER}"
fi

echo "Logging into azure.."
az login --service-principal -u ${INPUT_SERVICE_PRINCIPAL} -p ${INPUT_SERVICE_PRINCIPAL_PASSWORD} --tenant ${INPUT_TENANT}

echo "Sending build job to ACR.."
az acr build -r ${INPUT_REGISTRY} ${BUILD_ARGS} -f ${INPUT_DOCKERFILE} -t ${INPUT_REPOSITORY}${IMAGE_PART}:${INPUT_TAG} "${BUILD_URI}"
