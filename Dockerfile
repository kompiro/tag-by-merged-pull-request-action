FROM debian:9.6-slim

LABEL "com.github.actions.name"="Tag by merged pull request"
LABEL "com.github.actions.description"="Automatically create a tag based on merged pull request"
LABEL "com.github.actions.icon"="tag"
LABEL "com.github.actions.color"="gray-dark"

LABEL version="1.0.0"
LABEL repository="http://github.com/kompiro/tag-by-merged-pull-request-action"
LABEL homepage="http://github.com/kompiro/tag-by-merged-pull-request-action"
LABEL maintainer="Hiroki Kondo <kompiro@gmail.com>"

RUN apt-get update && apt-get install -y \
    curl \
    jq

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
