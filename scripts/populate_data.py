#!/usr/bin/env python3
"""
Populate the Agricultural IoT system with realistic sensor data
This script sends historical and current sensor readings via API
"""

import json
import requests
import random
from datetime import datetime, timedelta

API_BASE = "http://localhost:8081/api/v1"

# Define multiple fields with different crops
FIELDS = {
    "field_001": {"crop": "potato", "location": {"lat": 40.7128, "lon": -74.0060}},
    "field_002": {"crop": "tomato", "location": {"lat": 40.7580, "lon": -73.9855}},
    "field_003": {"crop": "corn", "location": {"lat": 40.7489, "lon": -73.9680}},
}

def generate_sensor_data(field_id, crop_type, timestamp, trend="normal"):
    """Generate realistic sensor data based on crop type and trend"""
    
    # Base values for different crops
    base_values = {
        "potato": {"moisture": 65, "temp": 18, "humidity": 70, "ph": 6.2},
        "tomato": {"moisture": 70, "temp": 24, "humidity": 65, "ph": 6.5},
        "corn": {"moisture": 75, "temp": 26, "humidity": 60, "ph": 6.8},
    }
    
    base = base_values.get(crop_type, base_values["potato"])
    
    # Apply trend variations
    if trend == "dry":
        moisture_adj = -15
        temp_adj = 3
    elif trend == "wet":
        moisture_adj = 10
        temp_adj = -2
    elif trend == "hot":
        moisture_adj = -8
        temp_adj = 5
    else:  # normal
        moisture_adj = 0
        temp_adj = 0
    
    # Add some randomness
    return {
        "device_id": f"sensor_{field_id.split('_')[1]}",
        "field_id": field_id,
        "timestamp": timestamp.isoformat() + "Z",
        "measurements": {
            "soil_moisture": max(20, min(95, base["moisture"] + moisture_adj + random.uniform(-5, 5))),
            "temperature": max(10, min(40, base["temp"] + temp_adj + random.uniform(-2, 2))),
            "humidity": max(30, min(95, base["humidity"] + random.uniform(-5, 5))),
            "soil_ph": max(5.5, min(7.5, base["ph"] + random.uniform(-0.2, 0.2))),
            "light_intensity": max(0, min(100000, random.uniform(20000, 80000))),
            "ec": random.uniform(0.5, 2.5),  # Electrical conductivity
        },
        "location": FIELDS[field_id]["location"]
    }

def send_sensor_data(data):
    """Send sensor data to the API"""
    try:
        response = requests.post(f"{API_BASE}/sensors/data", json=data, timeout=5)
        if response.status_code == 200 or response.status_code == 201:
            return True
        else:
            print(f"❌ Failed: {response.status_code} - {response.text}")
            return False
    except Exception as e:
        print(f"❌ Error sending data: {e}")
        return False

def populate_historical_data():
    """Generate and send historical data (last 7 days)"""
    print("📊 Generating historical sensor data (last 7 days)...")
    print("")
    
    now = datetime.utcnow()
    count = 0
    
    # Generate hourly readings for each field for the past week
    for days_ago in range(7, 0, -1):
        for hour in range(0, 24, 3):  # Every 3 hours
            timestamp = now - timedelta(days=days_ago, hours=hour)
            
            # Simulate different conditions on different days
            if days_ago >= 5:
                trend = "normal"
            elif days_ago >= 3:
                trend = "dry"
            else:
                trend = "hot"
            
            for field_id, field_info in FIELDS.items():
                data = generate_sensor_data(
                    field_id, 
                    field_info["crop"], 
                    timestamp,
                    trend
                )
                
                if send_sensor_data(data):
                    count += 1
                    if count % 10 == 0:
                        print(f"✓ Sent {count} readings...")
    
    print(f"\n✅ Historical data complete! {count} readings sent.")
    return count

def populate_current_data():
    """Generate and send current readings"""
    print("\n📡 Generating current sensor data...")
    print("")
    
    now = datetime.utcnow()
    count = 0
    
    for field_id, field_info in FIELDS.items():
        # Current reading with realistic conditions
        data = generate_sensor_data(
            field_id,
            field_info["crop"],
            now,
            "normal"
        )
        
        if send_sensor_data(data):
            count += 1
            print(f"✓ {field_id} ({field_info['crop']}): Moisture={data['measurements']['soil_moisture']:.1f}%, Temp={data['measurements']['temperature']:.1f}°C")
    
    print(f"\n✅ Current data sent! {count} readings.")
    return count

def test_decision_endpoint():
    """Test the AI decision endpoint with current data"""
    print("\n🤖 Testing AI Decision Endpoint...")
    print("")
    
    test_questions = [
        {
            "field_id": "field_001",
            "crop_type": "potato",
            "question": "Should I irrigate my potato field? Current moisture seems low."
        },
        {
            "field_id": "field_002",
            "crop_type": "tomato",
            "question": "What fertilizer should I apply to my tomato plants?"
        },
        {
            "field_id": "field_003",
            "crop_type": "corn",
            "question": "Is the temperature suitable for corn growth right now?"
        }
    ]
    
    for i, question_data in enumerate(test_questions, 1):
        print(f"\n{'='*70}")
        print(f"Question {i}: {question_data['question']}")
        print(f"Field: {question_data['field_id']} | Crop: {question_data['crop_type']}")
        print(f"{'='*70}")
        
        try:
            response = requests.post(
                f"{API_BASE}/decision",
                json=question_data,
                timeout=30
            )
            
            if response.status_code == 200:
                result = response.json()
                print(f"\n🌾 AI Recommendation:")
                print(f"   {result.get('recommendation', 'No recommendation')[:200]}...")
                print(f"\n   Confidence: {result.get('confidence', 0):.2f}")
                if result.get('actions'):
                    print(f"   Actions: {', '.join(result['actions'])}")
            else:
                print(f"❌ Error: {response.status_code}")
                print(f"   {response.text[:200]}")
        except Exception as e:
            print(f"❌ Failed to get decision: {e}")

def main():
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║         📊 Agricultural IoT Data Population Tool                    ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print("")
    print("This will populate your system with:")
    print("  • Historical sensor data (7 days, 3-hour intervals)")
    print("  • Current sensor readings")
    print("  • Test AI decision recommendations")
    print("")
    
    # Check if server is running
    try:
        response = requests.get(f"{API_BASE.replace('/api/v1', '')}/health", timeout=2)
        if response.status_code != 200:
            print("❌ Server not responding. Please start the server first:")
            print("   cd /home/neo/Documents/agurotech/agricultural-iot-rag")
            print("   make run")
            return
    except:
        print("❌ Cannot connect to server at http://localhost:8081")
        print("   Make sure the server is running!")
        return
    
    print("✅ Server is running!\n")
    
    # Populate data
    hist_count = populate_historical_data()
    curr_count = populate_current_data()
    
    # Test AI
    test_decision_endpoint()
    
    print("\n" + "="*70)
    print("✅ DATA POPULATION COMPLETE!")
    print("="*70)
    print(f"   Historical readings: {hist_count}")
    print(f"   Current readings: {curr_count}")
    print("")
    print("📊 View your data:")
    print(f"   • Grafana: http://localhost:3000")
    print(f"   • Prometheus: http://localhost:9090")
    print(f"   • Query API: curl http://localhost:8081/api/v1/sensors/field_001")
    print("")

if __name__ == "__main__":
    main()
