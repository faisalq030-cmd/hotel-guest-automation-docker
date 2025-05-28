FROM python:3.12-slim

# Install system dependencies for wkhtmltopdf
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    xorg \
    libssl-dev \
    libxrender1 \
    libxext6 \
    libfontconfig1 \
    libx11-dev \
    wget && \
    wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.6/wkhtmltox_0.12.6-1.buster_amd64.deb && \
    dpkg -i wkhtmltox_0.12.6-1.buster_amd64.deb && \
    apt-get install -f -y && \
    rm wkhtmltox_0.12.6-1.buster_amd64.deb

# Set working directory
WORKDIR /app

# Copy files
COPY . /app

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose port
EXPOSE 8080

# Run FastAPI with gunicorn
CMD ["gunicorn", "-b", "0.0.0.0:8080", "main:app"]
