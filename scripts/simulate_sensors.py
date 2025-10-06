#!/usr/bin/env python3
"""
MQTT Sensor Simulator for Agricultural IoT System
Simulates various agricultural sensors sending data
"""

import json
import random
import time
from datetime import datetime
import paho.mqtt.client as mqtt

# MQTT Configuration
MQTT_BROKER = "localhost"
MQTT_PORT = 1883

# Field configuration
FIELDS = [
    {"id": "field_001", "crop": "potato", "lat": 40.7128, "lon": -74.0060},
    {"id": "field_002", "crop": "tomato", "lat": 40.7282, "lon": -73.9942},
    {"id": "field_003", "crop": "corn", "lat": 40.7589, "lon": -73.9851},
]

def generate_soil_sensor_data(field):
    """Generate realistic soil sensor data"""
    return {
        "id": f"reading_{int(time.time())}",
        "device_id": f"soil_sensor_{field['id']}",
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "location": {
            "latitude": field["lat"] + random.uniform(-0.001, 0.001),
            "longitude": field["lon"] + random.uniform(-0.001, 0.001),
            "field_id": field["id"],
            "crop_type": field["crop"]
        },
        "measurements": {
            "soil_moisture": {
                "value": round(random.uniform(30.0, 80.0), 2),
                "unit": "%",
                "quality": "good"
            },
            "soil_temperature": {
                "value": round(random.uniform(15.0, 28.0), 2),
                "unit": "°C",
                "quality": "good"
            },
            "soil_ph": {
                "value": round(random.uniform(6.0, 7.5), 2),
                "unit": "pH",
                "quality": "good"
            },
            "soil_ec": {
                "value": round(random.uniform(0.5, 2.0), 2),
                "unit": "dS/m",
                "quality": "good"
            }
        },
        "device_status": {
            "battery_level": random.randint(60, 100),
            "signal_strength": random.randint(-80, -40),
            "last_calibration": (datetime.utcnow().isoformat() + "Z")
        }
    }

def generate_weather_sensor_data(field):
    """Generate realistic weather sensor data"""
    return {
        "id": f"reading_{int(time.time())}",
        "device_id": f"weather_sensor_{field['id']}",
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "location": {
            "latitude": field["lat"],
            "longitude": field["lon"],
            "field_id": field["id"],
            "crop_type": field["crop"]
        },
        "measurements": {
            "air_temperature": {
                "value": round(random.uniform(18.0, 32.0), 2),
                "unit": "°C",
                "quality": "good"
            },
            "humidity": {
                "value": round(random.uniform(40.0, 85.0), 2),
                "unit": "%",
                "quality": "good"
            },
            "wind_speed": {
                "value": round(random.uniform(0.0, 15.0), 2),
                "unit": "m/s",
                "quality": "good"
            },
            "rainfall": {
                "value": round(random.uniform(0.0, 5.0), 2),
                "unit": "mm",
                "quality": "good"
            },
            "solar_radiation": {
                "value": round(random.uniform(200.0, 1000.0), 2),
                "unit": "W/m²",
                "quality": "good"
            }
        },
        "device_status": {
            "battery_level": random.randint(70, 100),
            "signal_strength": random.randint(-75, -45),
            "last_calibration": (datetime.utcnow().isoformat() + "Z")
        }
    }

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("✓ Connected to MQTT broker")
    else:
        print(f"✗ Connection failed with code {rc}")

def main():
    print("🌾 Agricultural IoT Sensor Simulator")
    print("=" * 50)
    
    # Create MQTT client
    client = mqtt.Client(client_id="sensor_simulator")
    client.on_connect = on_connect
    
    # Connect to broker
    try:
        client.connect(MQTT_BROKER, MQTT_PORT, 60)
        client.loop_start()
    except Exception as e:
        print(f"✗ Failed to connect to MQTT broker: {e}")
        return
    
    print(f"📡 Simulating sensors for {len(FIELDS)} fields...")
    print("Press Ctrl+C to stop\n")
    
    try:
        while True:
            for field in FIELDS:
                # Send soil sensor data
                soil_data = generate_soil_sensor_data(field)
                topic = f"sensors/soil/{field['id']}/data"
                client.publish(topic, json.dumps(soil_data))
                print(f"📤 Sent soil data for {field['id']} (Moisture: {soil_data['measurements']['soil_moisture']['value']}%)")
                
                # Send weather sensor data
                weather_data = generate_weather_sensor_data(field)
                topic = f"sensors/weather/{field['id']}/data"
                client.publish(topic, json.dumps(weather_data))
                print(f"📤 Sent weather data for {field['id']} (Temp: {weather_data['measurements']['air_temperature']['value']}°C)")
            
            print()
            time.sleep(10)  # Send data every 10 seconds
            
    except KeyboardInterrupt:
        print("\n\n🛑 Stopping simulator...")
        client.loop_stop()
        client.disconnect()
        print("✓ Disconnected from MQTT broker")

if __name__ == "__main__":
    main()
