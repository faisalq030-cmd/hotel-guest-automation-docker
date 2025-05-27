#!/bin/bash

# ✅ Update package list and install wkhtmltopdf
apt-get update
apt-get install -y wkhtmltopdf

# ✅ Start the Python app
python3 main.py
