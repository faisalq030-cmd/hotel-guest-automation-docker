# Use official Python image
FROM python:3.10-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install dependencies for wkhtmltopdf
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    xorg \
    libssl-dev \
    libxrender1 \
    libxext6 \
    libfontconfig1 \
    libx11-dev \
    wget \
    curl \
    gnupg \
    ca-certificates && \
    curl -sS https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.6/wkhtmltox_0.12.6-1.buster_amd64.deb && \
    apt install -y ./wkhtmltox_0.12.6-1.buster_amd64.deb && \
    rm wkhtmltox_0.12.6-1.buster_amd64.deb

# Create app directory
WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app files
COPY . .

# Run the app
CMD ["python", "main.py"]
