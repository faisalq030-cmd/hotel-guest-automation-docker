# Use Python base image
FROM python:3.12-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    gnupg \
    ca-certificates \  # Critical for SSL verification
    xfonts-75dpi \
    xfonts-base \
    fontconfig \
    libxrender1 \
    libxext6 \
    libjpeg62-turbo \
    libx11-6 \
    xz-utils \
    && wget --no-verbose https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.6/wkhtmltox-0.12.6_linux-generic-amd64.tar.xz \
    && tar -xJf wkhtmltox-0.12.6_linux-generic-amd64.tar.xz \
    && mv wkhtmltox/bin/wkhtmltopdf /usr/local/bin/ \
    && rm -rf wkhtmltox* \  # Cleanup both tarball and extracted dir
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /app

# Copy project
COPY . /app

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Run app
CMD ["gunicorn", "main:app", "--bind", "0.0.0.0:8000"]