#!/bin/bash

		# -e SECRET_KEY_BASE="b5ba8dbad4f0ec1d9f17adb71e96bb9f" \
podman build -t cv_builder:latest .
podman image save cv_builder:latest -o cv_builder.image
