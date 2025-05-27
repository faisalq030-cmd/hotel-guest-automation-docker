# Use Python base image
FROM python:3.12-slim

# Install wkhtmltopdf dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    gnupg \
    xfonts-75dpi \
    xfonts-base \
    fontconfig \
    libxrender1 \
    libxext6 \
    libjpeg62-turbo \
    libx11-6 \
    && wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.buster_amd64.deb \
    && apt install -y ./wkhtmltox_0.12.6-1.buster_amd64.deb \
    && rm wkhtmltox_0.12.6-1.buster_amd64.deb \
    && apt-get clean

# Set work directory
WORKDIR /app

# Copy project
COPY . /app

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Run app
CMD ["gunicorn", "main:app", "--bind", "0.0.0.0:8000"]
