// internal/services/knowledge.go
package services

import (
	"context"
	"fmt"

	"agricultural-iot-rag/internal/models"
	"agricultural-iot-rag/pkg/rag"

	pb "github.com/qdrant/go-client/qdrant"
)

type KnowledgeService struct {
	vectorStore *rag.VectorStore
	embeddings  *rag.EmbeddingService
}

func NewKnowledgeService(vectorStore *rag.VectorStore, embeddings *rag.EmbeddingService) *KnowledgeService {
	return &KnowledgeService{
		vectorStore: vectorStore,
		embeddings:  embeddings,
	}
}

func (ks *KnowledgeService) SearchKnowledge(ctx context.Context, query string, sensorData *models.SensorReading) ([]string, error) {
	// Enhance query with sensor context
	enhancedQuery := ks.enhanceQueryWithSensorData(query, sensorData)

	// Get embedding for the query
	queryEmbedding, err := ks.embeddings.GetEmbedding(ctx, enhancedQuery)
	if err != nil {
		return nil, fmt.Errorf("failed to get query embedding: %w", err)
	}

	// Search vector database
	results, err := ks.vectorStore.Search(ctx, queryEmbedding, 5)
	if err != nil {
		return nil, fmt.Errorf("failed to search knowledge base: %w", err)
	}

	// Extract relevant documents
	var documents []string
	for _, result := range results {
		if result.Payload != nil {
			if contentVal, ok := result.Payload["content"]; ok {
				if content, ok := contentVal.GetKind().(*pb.Value_StringValue); ok {
					documents = append(documents, content.StringValue)
				}
			}
		}
	}

	return documents, nil
}

func (ks *KnowledgeService) enhanceQueryWithSensorData(query string, sensorData *models.SensorReading) string {
	if sensorData == nil {
		return query
	}

	context := fmt.Sprintf("Field context: Location %s, ", sensorData.Location.FieldID)

	if soilMoisture, ok := sensorData.Measurements["soil_moisture"]; ok {
		context += fmt.Sprintf("Soil moisture: %v%s, ", soilMoisture.Value, soilMoisture.Unit)
	}

	if temp, ok := sensorData.Measurements["soil_temperature"]; ok {
		context += fmt.Sprintf("Soil temperature: %v%s, ", temp.Value, temp.Unit)
	}

	if sensorData.Location.CropType != "" {
		context += fmt.Sprintf("Crop type: %s, ", sensorData.Location.CropType)
	}

	return context + "Question: " + query
}

// AddKnowledge adds a new knowledge document to the vector store
func (ks *KnowledgeService) AddKnowledge(ctx context.Context, id, text string, metadata map[string]interface{}) error {
	embedding, err := ks.embeddings.GetEmbedding(ctx, text)
	if err != nil {
		return fmt.Errorf("failed to get embedding: %w", err)
	}

	return ks.vectorStore.AddDocument(ctx, id, text, embedding, metadata)
}
