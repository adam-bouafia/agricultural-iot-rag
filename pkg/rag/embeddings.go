// pkg/rag/embeddings.go
package rag

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
)

type EmbeddingService struct {
	apiURL string
	model  string
}

func NewEmbeddingService(apiURL, model string) *EmbeddingService {
	return &EmbeddingService{
		apiURL: apiURL,
		model:  model,
	}
}

type OllamaEmbeddingRequest struct {
	Model  string `json:"model"`
	Prompt string `json:"prompt"`
}

type OllamaEmbeddingResponse struct {
	Embedding []float32 `json:"embedding"`
}

func (es *EmbeddingService) GetEmbedding(ctx context.Context, text string) ([]float32, error) {
	req := OllamaEmbeddingRequest{
		Model:  es.model,
		Prompt: text,
	}

	jsonData, err := json.Marshal(req)
	if err != nil {
		return nil, err
	}

	httpReq, err := http.NewRequestWithContext(ctx, "POST", es.apiURL+"/api/embeddings", bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, err
	}

	httpReq.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(httpReq)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("embedding API returned status %d", resp.StatusCode)
	}

	var embedResp OllamaEmbeddingResponse
	if err := json.NewDecoder(resp.Body).Decode(&embedResp); err != nil {
		return nil, err
	}

	if len(embedResp.Embedding) == 0 {
		return nil, fmt.Errorf("no embedding returned")
	}

	return embedResp.Embedding, nil
}

// GetEmbeddings gets embeddings for multiple texts in batch
func (es *EmbeddingService) GetEmbeddings(ctx context.Context, texts []string) ([][]float32, error) {
	embeddings := make([][]float32, len(texts))
	for i, text := range texts {
		emb, err := es.GetEmbedding(ctx, text)
		if err != nil {
			return nil, fmt.Errorf("failed to get embedding for text %d: %w", i, err)
		}
		embeddings[i] = emb
	}
	return embeddings, nil
}
