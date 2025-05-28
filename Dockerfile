# Use Python slim image
FROM python:3.10-slim

# Set environment vars to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies and wkhtmltopdf (clean and error-free way)
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    xz-utils \
    fontconfig \
    libxrender1 \
    libxext6 \
    libx11-6 \
    libssl-dev \
    libfontconfig1 \
    && wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.6/wkhtmltox_0.12.6-1.buster_amd64.deb \
    && apt-get install -y ./wkhtmltox_0.12.6-1.buster_amd64.deb \
    && rm wkhtmltox_0.12.6-1.buster_amd64.deb

# Set working directory
WORKDIR /app

# Copy all files
COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose the port (Railway default is 8000 or your own)
EXPOSE 8000

# Start your app (adjust if needed for FastAPI or Flask)
CMD ["python", "main.py"]
