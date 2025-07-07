#!/bin/bash
docker exec gitlab-runner gitlab-runner register \
  --non-interactive \
  --url "https://gitlab.com/" \
  --token "<your_registration_token>" \
  --executor "docker" \
  --docker-image "docker:24.0.5" \
  --description "docker-runner" \
  --tag-list "docker,ci" \
  --run-untagged="true" \
  --locked="false" \
  --docker-volumes "/var/run/docker.sock:/var/run/docker.sock"
