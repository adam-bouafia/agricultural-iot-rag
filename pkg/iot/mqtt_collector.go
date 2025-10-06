// pkg/iot/mqtt_collector.go
package iot

import (
	"context"
	"encoding/json"
	"log"

	mqtt "github.com/eclipse/paho.mqtt.golang"
	"agricultural-iot-rag/internal/models"
)

type MQTTCollector struct {
	client   mqtt.Client
	dataChan chan models.SensorReading
}

func NewMQTTCollector(broker string, dataChan chan models.SensorReading) *MQTTCollector {
	opts := mqtt.NewClientOptions()
	opts.AddBroker(broker)
	opts.SetClientID("iot-collector")
	opts.SetAutoReconnect(true)
	opts.SetCleanSession(false)

	client := mqtt.NewClient(opts)

	return &MQTTCollector{
		client:   client,
		dataChan: dataChan,
	}
}

func (m *MQTTCollector) Start(ctx context.Context) error {
	if token := m.client.Connect(); token.Wait() && token.Error() != nil {
		return token.Error()
	}

	log.Println("Connected to MQTT broker")

	// Subscribe to sensor topics
	topics := []string{
		"sensors/soil/+/data",
		"sensors/weather/+/data",
		"sensors/crop/+/data",
	}

	for _, topic := range topics {
		if token := m.client.Subscribe(topic, 0, m.messageHandler); token.Wait() && token.Error() != nil {
			log.Printf("Failed to subscribe to %s: %v", topic, token.Error())
		} else {
			log.Printf("Subscribed to topic: %s", topic)
		}
	}

	<-ctx.Done()
	m.client.Disconnect(250)
	log.Println("Disconnected from MQTT broker")
	return nil
}

func (m *MQTTCollector) messageHandler(client mqtt.Client, msg mqtt.Message) {
	var reading models.SensorReading
	if err := json.Unmarshal(msg.Payload(), &reading); err != nil {
		log.Printf("Error unmarshaling sensor data: %v", err)
		return
	}

	select {
	case m.dataChan <- reading:
		log.Printf("Received sensor data from device %s", reading.DeviceID)
	default:
		log.Printf("Data channel full, dropping message from device %s", reading.DeviceID)
	}
}

// Publish publishes a message to a topic
func (m *MQTTCollector) Publish(topic string, payload interface{}) error {
	data, err := json.Marshal(payload)
	if err != nil {
		return err
	}

	token := m.client.Publish(topic, 0, false, data)
	token.Wait()
	return token.Error()
}
