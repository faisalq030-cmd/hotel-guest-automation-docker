FROM minidocks/wkhtmltopdf:0.12

# Install Python and pip
RUN apk add --no-cache python3 py3-pip

# Set working directory
WORKDIR /app

# Copy requirements and install
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy your app code
COPY . .

CMD ["python3", "main.py"]
