podman image load --input cv_builder.image

podman pod stop cv-builder-pod

podman rm cv_builder

podman run -d \
  --pod cv-builder-pod \
  --name cv_builder \
  --user "${UID:-1000}:${GID:-1000}" \
  -v cv_builder_data:/rails/storage \
  -e RAILS_ENV=production \
  -e RAILS_MASTER_KEY="${RAILS_MASTER_KEY}" \
  -e SECRET_KEY_BASE="${SECRET_KEY_BASE}" \
  -e BIND=0.0.0.0 \
  -e LATEX_SERVICE_URL=http://localhost:3001 \
  cv_builder

podman pod start cv-builder-pod
