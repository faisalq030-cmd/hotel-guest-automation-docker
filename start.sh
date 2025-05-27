#!/bin/bash

# Install wkhtmltopdf
apt-get update && apt-get install -y wkhtmltopdf

# Start Gunicorn server
exec gunicorn -b 0.0.0.0:8080 main:app
