// internal/handlers/decision.go
package handlers

import (
	"fmt"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"

	"agricultural-iot-rag/internal/services"
	"agricultural-iot-rag/pkg/llm"
)

type DecisionHandler struct {
	knowledgeService *services.KnowledgeService
	llmClient        *llm.OllamaClient
}

func NewDecisionHandler(ks *services.KnowledgeService, llmClient *llm.OllamaClient) *DecisionHandler {
	return &DecisionHandler{
		knowledgeService: ks,
		llmClient:        llmClient,
	}
}

type DecisionRequest struct {
	Query      string                 `json:"query" binding:"required"`
	FieldID    string                 `json:"field_id"`
	SensorData map[string]interface{} `json:"sensor_data,omitempty"`
}

type DecisionResponse struct {
	Recommendation string   `json:"recommendation"`
	Confidence     float64  `json:"confidence"`
	Sources        []string `json:"sources"`
	Actions        []string `json:"actions"`
}

func (dh *DecisionHandler) GetDecision(c *gin.Context) {
	var req DecisionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Retrieve relevant knowledge
	documents, err := dh.knowledgeService.SearchKnowledge(c.Request.Context(), req.Query, nil)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve knowledge"})
		return
	}

	// Prepare context for LLM
	context := "You are an agricultural expert. Based on the following agricultural knowledge and sensor data, provide recommendations:\n\n"
	for i, doc := range documents {
		context += fmt.Sprintf("Document %d: %s\n\n", i+1, doc)
	}

	context += fmt.Sprintf("Question: %s\n\nProvide practical recommendations with specific actions.", req.Query)

	// Get LLM response
	messages := []llm.Message{
		{Role: "system", Content: "You are an expert agricultural advisor. Provide practical, actionable recommendations based on sensor data and agricultural knowledge."},
		{Role: "user", Content: context},
	}

	response, err := dh.llmClient.Chat(c.Request.Context(), messages, nil)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate recommendation"})
		return
	}

	// Parse and structure the response
	recommendation := DecisionResponse{
		Recommendation: response.Message.Content,
		Confidence:     0.85, // You can implement confidence scoring
		Sources:        documents,
		Actions:        parseActions(response.Message.Content),
	}

	c.JSON(http.StatusOK, recommendation)
}

func parseActions(content string) []string {
	actions := []string{}
	lowerContent := strings.ToLower(content)

	if strings.Contains(lowerContent, "irrigate") || strings.Contains(lowerContent, "water") {
		actions = append(actions, "irrigation_recommended")
	}
	if strings.Contains(lowerContent, "fertilize") || strings.Contains(lowerContent, "nutrient") {
		actions = append(actions, "fertilization_recommended")
	}
	if strings.Contains(lowerContent, "pest") || strings.Contains(lowerContent, "spray") {
		actions = append(actions, "pest_control_recommended")
	}
	if strings.Contains(lowerContent, "harvest") {
		actions = append(actions, "harvest_recommended")
	}

	return actions
}
