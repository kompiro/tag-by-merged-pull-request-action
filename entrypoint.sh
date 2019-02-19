#!/bin/bash
set -eu

if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Set the GITHUB_TOKEN env variable."
  exit 1
fi

if [[ -z "$GITHUB_EVENT_NAME" ]]; then
  echo "Set the GITHUB_EVENT_NAME env variable."
  exit 1
fi

if [[ -z "$GITHUB_REPOSITORY" ]]; then
  echo "Set the GITHUB_REPOSITORY env variable."
  exit 1
fi

if [[ -z "$GITHUB_EVENT_PATH" ]]; then
  echo "Set the GITHUB_EVENT_PATH env variable."
  exit 1
fi

API_HEADER="Accept: application/vnd.github.v3+json; application/vnd.github.antiope-preview+json"
AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"

action=$(jq --raw-output .action "$GITHUB_EVENT_PATH")
number=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")
merged=$(jq --raw-output .pull_request.merged "$GITHUB_EVENT_PATH")
title=$(jq --raw-output .pull_request.title "$GITHUB_EVENT_PATH")
author=$(jq --raw-output .pull_request.user.login "$GITHUB_EVENT_PATH")
merge_commit_sha=$(jq --raw-output .pull_request.merge_commit_sha "$GITHUB_EVENT_PATH")
merged_by=$(jq --raw-output .pull_request.merged_by.login "$GITHUB_EVENT_PATH")

create_tag() {
  message="#${number} ${title} by @${author} merged by @${merged_by}"
  data=$(jq -n \
    --arg TAG "${GITHUB_REPOSITORY}/pr-${number}" \
    --arg MESSAGE "${message}" \
    --arg OBJECT "${merge_commit_sha}" \
    '{tag: $TAG, message: $MESSAGE, object: $OBJECT, type: "commit"}'
  )

  tag_sha=$(curl -sSL \
    -H "Content-Type: application/json" \
    -H "${AUTH_HEADER}" \
    -H "${API_HEADER}" \
    -X "POST" \
    -d "${data}" \
    "https://api.github.com/repos/${GITHUB_REPOSITORY}/git/tags" | jq --raw-output .sha)

  data=$(jq -n \
    --arg REF "refs/tags/${GITHUB_REPOSITORY}/pr-${number}" \
    --arg OBJECT "${tag_sha}" \
    '{ref: $REF, sha: $OBJECT}'
  )

  curl -sSL \
    -H "Content-Type: application/json" \
    -H "${AUTH_HEADER}" \
    -H "${API_HEADER}" \
    -X "POST" \
    -d "${data}" \
    "https://api.github.com/repos/${GITHUB_REPOSITORY}/git/refs" > /dev/null
}

if [[ "$action" == "closed" && "$merged" == "true" ]]; then
  create_tag
else
  echo "Ignoring action ${action}"
  exit 78
fi
