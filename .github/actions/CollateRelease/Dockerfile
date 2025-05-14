# Container image that runs your code
FROM ruby:3.4-slim

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint /entrypoint

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint"]
