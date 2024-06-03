from flask import Flask, jsonify, request
from flask_cors import CORS
import pyodbc
import mysql.connector

app = Flask(__name__)
CORS(app)  # This will enable CORS for all routes

alerts = []

# Kết nối đến cơ sở dữ liệu SQL Server
conn_sql_server = pyodbc.connect(
    'Driver={ODBC Driver 17 for SQL Server};'
    'SERVER=LEQUANGVU;'
    'DATABASE=chungkhoan_db;'
    'Trusted_Connection=yes;'
)

# Kết nối tới cơ sở dữ liệu MySQL
mydb = mysql.connector.connect(
    host="10.168.6.106",
    user="acc_etl",
    password="Vnpt123456",
    database="dtm_stock_v2"
)

@app.route('/api/alerts', methods=['GET'])
def get_alerts():
    cursor = conn_sql_server.cursor()
    cursor.execute("SELECT * FROM alerts")
    alerts = cursor.fetchall()

    alert_list = []
    for alert in alerts:
        alert_dict = {
            'id': alert.id,
            'bot_token': alert.bot_token,
            'chat_id': alert.chat_id,
            'indicator': alert.indicator,
            'threshold_value': alert.threshold_value,
            'threshold_unit': alert.threshold_unit,
            'scan_interval': alert.scan_interval,
            'interval_unit': alert.interval_unit,
            'created_at': alert.created_at.strftime('%Y-%m-%d %H:%M:%S')
        }
        alert_list.append(alert_dict)
    
    return jsonify(alert_list)


@app.route('/api/alerts', methods=['POST'])
def create_alert():
    data = request.json
    new_alert = {
        "id": len(alerts) + 1,  # Simple ID generation logic
        "bot_token": data['bot_token'],
        "chat_id": data['chat_id'],
        "created_at": data['created_at'],  # Ensure to handle date properly in production
        "indicator": data['indicator'],
        "interval_unit": data['interval_unit'],
        "scan_interval": data['scan_interval'],
        "threshold_unit": data['threshold_unit'],
        "threshold_value": data['threshold_value']
    }
    alerts.append(new_alert)
    print(alerts)
    return jsonify(new_alert), 201


@app.route('/api/login', methods=['POST'])
def login():
    data = request.json
    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({'message': 'Missing username or password'}), 400

    cursor = conn_sql_server.cursor()
    cursor.execute("SELECT * FROM users WHERE username = ? AND password = ?", (username, password))
    user = cursor.fetchone()
    cursor.close()

    if not user:
        return jsonify({'message': 'Invalid username or password'}), 401

    user_data = {
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'created_at': user.created_at
    }

    return jsonify({'message': 'Login successful', 'user': user_data})

@app.route('/api/indicator_values', methods=['GET'])
def get_indicator_values():
    mycursor = mydb.cursor()
    sql = "SELECT stocksymbol, indicator_value FROM fact_stock_indicator"
    mycursor.execute(sql)

    # Fetch all results
    results = mycursor.fetchall()

    # Format the results as a list of dictionaries
    indicator_values = [
        {"stocksymbol": row[0], "indicator_value": row[1]} for row in results
    ]

    # Close the cursor
    mycursor.close()

    # Return the results as a JSON response
    return jsonify(indicator_values)

if __name__ == '__main__':
    app.run(debug=True)
