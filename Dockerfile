FROM ghcr.io/openlabs/docker-wkhtmltopdf:0.12.6

# Install Python
RUN apt-get update && apt-get install -y python3 python3-pip

# Set workdir
WORKDIR /app

# Copy requirements and install
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy app
COPY . .

CMD ["python3", "main.py"]
