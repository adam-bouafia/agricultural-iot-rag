// pkg/llm/ollama.go
package llm

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
)

type OllamaClient struct {
	baseURL string
	model   string
}

func NewOllamaClient(baseURL, model string) *OllamaClient {
	return &OllamaClient{
		baseURL: baseURL,
		model:   model,
	}
}

type ChatRequest struct {
	Model    string    `json:"model"`
	Messages []Message `json:"messages"`
	Stream   bool      `json:"stream"`
	Tools    []Tool    `json:"tools,omitempty"`
}

type Message struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type Tool struct {
	Type     string       `json:"type"`
	Function ToolFunction `json:"function"`
}

type ToolFunction struct {
	Name        string      `json:"name"`
	Description string      `json:"description"`
	Parameters  interface{} `json:"parameters"`
}

type ChatResponse struct {
	Message   Message    `json:"message"`
	ToolCalls []ToolCall `json:"tool_calls,omitempty"`
	Done      bool       `json:"done"`
}

type ToolCall struct {
	Function struct {
		Name      string                 `json:"name"`
		Arguments map[string]interface{} `json:"arguments"`
	} `json:"function"`
}

func (c *OllamaClient) Chat(ctx context.Context, messages []Message, tools []Tool) (*ChatResponse, error) {
	req := ChatRequest{
		Model:    c.model,
		Messages: messages,
		Stream:   false,
		Tools:    tools,
	}

	jsonData, err := json.Marshal(req)
	if err != nil {
		return nil, err
	}

	httpReq, err := http.NewRequestWithContext(ctx, "POST", c.baseURL+"/api/chat", bytes.NewBuffer(jsonData))
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
		return nil, fmt.Errorf("ollama API returned status %d", resp.StatusCode)
	}

	var chatResp ChatResponse
	if err := json.NewDecoder(resp.Body).Decode(&chatResp); err != nil {
		return nil, err
	}

	return &chatResp, nil
}

// Generate generates a completion for a single prompt
func (c *OllamaClient) Generate(ctx context.Context, prompt string) (string, error) {
	messages := []Message{
		{Role: "user", Content: prompt},
	}

	resp, err := c.Chat(ctx, messages, nil)
	if err != nil {
		return "", err
	}

	return resp.Message.Content, nil
}
