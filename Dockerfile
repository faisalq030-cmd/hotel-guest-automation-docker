# Dockerfile
FROM python:3.12-slim

# Install dependencies and wkhtmltopdf
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    gnupg \
    fontconfig \
    libxrender1 \
    libxext6 \
    libx11-6 \
    libjpeg62-turbo \
    xfonts-base \
    xfonts-75dpi \
    && wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.buster_amd64.deb \
    && dpkg -i wkhtmltox_0.12.6-1.buster_amd64.deb \
    && rm wkhtmltox_0.12.6-1.buster_amd64.deb \
    && apt-get clean

# Set working directory
WORKDIR /app

# Copy code
COPY . /app

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Run the app
CMD ["gunicorn", "main:app", "--bind", "0.0.0.0:8000"]
