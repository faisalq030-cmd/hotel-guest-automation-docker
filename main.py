from flask import Flask, render_template_string, send_from_directory
from notion_client import Client
import os
import qrcode
from datetime import datetime
import threading
import time
import urllib.parse
import pdfkit

app = Flask(__name__)
app.config['STATIC_FOLDER'] = 'static'
app.config['QR_FOLDER'] = os.path.join(app.config['STATIC_FOLDER'], 'qrcodes')
app.config['PDF_FOLDER'] = os.path.join(app.config['STATIC_FOLDER'], 'pdfs')

os.makedirs(app.config['QR_FOLDER'], exist_ok=True)
os.makedirs(app.config['PDF_FOLDER'], exist_ok=True)

# 📌 Replace this with your own Notion API key and database ID
notion = Client(auth="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")
DATABASE_ID = "1f095662fbd7805da4d3cefe15d8ba9d"

# 🌐 Railway deployment URL fallback
RAILWAY_URL = os.getenv("RAILWAY_URL", "http://127.0.0.1:5000")

# ✅ Configure pdfkit to use wkhtmltopdf path (modified as requested)
PDFKIT_CONFIG = pdfkit.configuration(wkhtmltopdf="/usr/local/bin/wkhtmltopdf")

GUEST_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <title>Welcome {{ guest_name }}</title>
    <style>
        body { font-family: Arial, text-align: center; padding: 50px; background-color: #f7f7f7; }
        .card { background: #fff; padding: 40px; border-radius: 20px; box-shadow: 0 0 10px rgba(0,0,0,0.1); display: inline-block; }
        h1 { color: #333; }
        .info { font-size: 18px; margin-top: 10px; color: #555; }
    </style>
</head>
<body>
    <div class="card">
        <h1>Welcome, {{ guest_name }}!</h1>
        <p class="info">Room Number: {{ room_number }}</p>
        <p class="info">Room Type: {{ room_type }}</p>
        <p class="info">Phone Number: {{ phone_number }}</p>
        <p class="info">Guest Status: {{ guest_status }}</p>
        <p class="info">Check-in Date: {{ checkin_date }}</p>
        <p class="info">Check-out Date: {{ checkout_date }}</p>
    </div>
</body>
</html>
"""

def check_and_update_guests():
    while True:
        try:
            response = notion.databases.query(database_id=DATABASE_ID)
            for page in response.get("results", []):
                props = page["properties"]
                guest_name_prop = props.get("Guest Name", {}).get("title", [])
                if not guest_name_prop:
                    continue
                guest_name = guest_name_prop[0]["text"]["content"]

                checkin = props.get("Check-in Date", {}).get("date", {})
                checkout = props.get("Check-Out Date", {}).get("date", {})
                created_time = page.get("created_time", "")
                created_timestamp = datetime.strptime(created_time, "%Y-%m-%dT%H:%M:%S.%fZ")
                created_key = created_timestamp.strftime("%Y%m%d%H%M%S")

                # Skip if already processed or no checkout date
                if props.get("Welcome Page URL", {}).get("url") and props.get("QR Code URL", {}).get("url"):
                    continue
                if not checkout:
                    continue

                guest_url = f"{RAILWAY_URL}/guest/{urllib.parse.quote(guest_name)}/{created_key}"
                qr_img_path = os.path.join(app.config['QR_FOLDER'], f"{guest_name}_{created_key}.png")
                qrcode.make(guest_url).save(qr_img_path)

                notion.pages.update(page["id"], properties={
                    "Welcome Page URL": {"url": guest_url},
                    "QR Code URL": {"url": f"{RAILWAY_URL}/static/qrcodes/{guest_name}_{created_key}.png"}
                })

                print(f"✅ Guest '{guest_name}' processed. Page: {guest_url}")

                # 📄 Generate PDF using PDFKit
                pdf_path = os.path.join(app.config['PDF_FOLDER'], f"{guest_name}_{created_key}.pdf")
                pdfkit.from_url(guest_url, pdf_path, configuration=PDFKIT_CONFIG)
                print(f"📄 PDF saved: {pdf_path}")

        except Exception as e:
            print(f"❌ Error: {e}")

        time.sleep(10)

@app.route('/guest/<guest_name>/<created_key>')
def guest_page(guest_name, created_key):
    try:
        response = notion.databases.query(database_id=DATABASE_ID)
        for page in response.get("results", []):
            props = page["properties"]
            name_prop = props.get("Guest Name", {}).get("title", [])
            if not name_prop:
                continue
            name_value = name_prop[0]["text"]["content"]
            if name_value != guest_name:
                continue

            created_time = page.get("created_time", "")
            created_timestamp = datetime.strptime(created_time, "%Y-%m-%dT%H:%M:%S.%fZ")
            page_created_key = created_timestamp.strftime("%Y%m%d%H%M%S")

            if created_key != page_created_key:
                continue

            room_number = props.get("Room Number", {}).get("number", "N/A")
            room_type = props.get("Room Type", {}).get("select", {}).get("name", "N/A")
            phone_number = props.get("Guest Phone Number", {}).get("rich_text", [])
            phone_number = phone_number[0]["text"]["content"] if phone_number else "N/A"
            guest_status = props.get("Guest Status", {}).get("multi_select", [])
            guest_status = ", ".join([s.get("name", "") for s in guest_status]) if guest_status else "N/A"
            checkin = props.get("Check-in Date", {}).get("date", {}).get("start", "N/A")
            checkout = props.get("Check-Out Date", {}).get("date", {}).get("start", "N/A")

            return render_template_string(
                GUEST_TEMPLATE,
                guest_name=guest_name,
                room_number=room_number,
                room_type=room_type,
                phone_number=phone_number,
                guest_status=guest_status,
                checkin_date=checkin,
                checkout_date=checkout
            )

        return f"❌ Guest not found for {guest_name} with key {created_key}"

    except Exception as e:
        return f"❌ Error: {str(e)}"

@app.route('/static/<path:filename>')
def static_file(filename):
    return send_from_directory(app.config['STATIC_FOLDER'], filename)

# 🔁 Start background thread when the app is loaded by Gunicorn or Flask
@app.before_first_request
def start_background_thread():
    threading.Thread(target=check_and_update_guests, daemon=True).start()
