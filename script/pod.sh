#!/bin/bash

# Create a pod with exposed ports
podman pod create \
  --name cv-builder-pod \
  -p 3000:3000 \
  -p 3001:3001

# Run latex service in the pod
podman run -d \
  --pod cv-builder-pod \
  --name latex-compiler \
  --user "${UID:-1000}:${GID:-1000}" \
  latex-compiler

# Create volume if it doesn't exist
podman volume create cv_builder_data

# Run web service in the pod
podman run -d \
  --pod cv-builder-pod \
  --name cv_builder \
  --user "${UID:-1000}:${GID:-1000}" \
  -v cv_builder_data:/app/storage \
  -e RAILS_ENV=production \
  -e RAILS_MASTER_KEY="${RAILS_MASTER_KEY}" \
  -e SECRET_KEY_BASE="${SECRET_KEY_BASE}" \
  -e BIND=0.0.0.0 \
  -e LATEX_SERVICE_URL=http://localhost:3001 \
  cv_builder

# Commands to manage the pod:
# podman pod start cv-builder-pod
# podman pod stop cv-builder-pod
# podman pod rm cv-builder-pod
# podman pod logs cv-builder-pod
