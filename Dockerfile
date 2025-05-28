FROM python:3.10-bullseye

RUN apt-get update && apt-get install -y \
    build-essential \
    xorg \
    libssl-dev \
    libxrender1 \
    libxext6 \
    libfontconfig1 \
    libx11-dev \
    wget \
    && wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.6/wkhtmltox_0.12.6-1.buster_amd64.deb \
    && apt install -y ./wkhtmltox_0.12.6-1.buster_amd64.deb \
    && rm wkhtmltox_0.12.6-1.buster_amd64.deb

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

CMD ["python", "main.py"]
