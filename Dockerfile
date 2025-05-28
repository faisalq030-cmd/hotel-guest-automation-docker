FROM python:3.10-bullseye

# Install basic packages
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    xfonts-base \
    xfonts-75dpi \
    fontconfig \
    libjpeg62-turbo \
    libxrender1 \
    libxext6 \
    libfontconfig1 \
    libfreetype6 \
    libx11-6 \
    && rm -rf /var/lib/apt/lists/*

# Install wkhtmltopdf from official static binary (not .deb)
RUN wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.6/wkhtmltox-0.12.6-1-linux-generic-amd64.tar.xz && \
    tar -xf wkhtmltox-0.12.6-1-linux-generic-amd64.tar.xz && \
    cp -r wkhtmltox/bin/* /usr/local/bin/ && \
    rm -rf wkhtmltox*

# Set working directory
WORKDIR /app

# Install Python requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app code
COPY . .

CMD ["python", "main.py"]
