import requests
import psycopg2
from datetime import datetime

# Kết nối đến cơ sở dữ liệu
conn = psycopg2.connect(
    dbname="your_dbname",
    user="your_user",
    password="your_password",
    host="your_host",
    port="your_port"
)

def fetch_indicator_value(indicator):
    # Fetch giá trị chỉ báo từ API (ví dụ)
    url = f"https://api.example.com/indicator/{indicator}"
    response = requests.get(url)
    data = response.json()
    return data['value']

def check_thresholds():
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM alerts")
    alerts = cursor.fetchall()
    
    for alert in alerts:
        id, bot_token, chat_id, indicator, threshold_value, threshold_unit, scan_interval, interval_unit, created_at = alert
        
        current_value = fetch_indicator_value(indicator)
        if should_send_alert(current_value, threshold_value, threshold_unit):
            message = f"Chỉ báo {indicator} hiện tại là {current_value}, vượt ngưỡng {threshold_value} {threshold_unit}"
            send_telegram_alert(bot_token, chat_id, message)

def should_send_alert(current_value, threshold_value, threshold_unit):
    # Chuyển đổi threshold_value theo đơn vị threshold_unit
    if threshold_unit == 'k':
        threshold_value *= 1000
    elif threshold_unit == 'm':
        threshold_value *= 1000000
    elif threshold_unit == 'b':
        threshold_value *= 1000000000
    
    return current_value >= threshold_value

def send_telegram_alert(bot_token, chat_id, message):
    url = f"https://api.telegram.org/bot{bot_token}/sendMessage"
    payload = {
        'chat_id': chat_id,
        'text': message
    }
    response = requests.post(url, json=payload)
    return response.json()

# Lập lịch để chạy check_thresholds() theo interval định kỳ
import time

while True:
    check_thresholds()
    time.sleep(60)  # Chạy lại sau 60 giây
